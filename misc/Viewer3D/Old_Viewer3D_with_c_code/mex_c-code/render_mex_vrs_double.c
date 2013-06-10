#include "mex.h"
#include "math.h"

/*  This function shear_vol, will calculate a volumerendered image
 *  using the shearwarp algorithm
 * 
 *  J = render_mex_vrs(I,sizes,Mshear,Mwarp2D,c,alphatable,colortable,L,V,Mview,MaterialType);
 *
 *  Function is written by D.Kroon University of Twente (October 2008)
 */

// get color from certain postion in 3D image
double getcolor2(int x, int y, int sizx, int sizy, double *I) 
{
    if(x<0) { return 0; }
    if(x>(sizx-1)) { return 0; }
    if(y<0) { return 0; }
    if(y>(sizy-1)) { return 0; }
    return I[y*sizx+x];
}

// get color from certain postion in 3D image
double getcolor(int x, int y, int z, int sizx, int sizy, int sizz, double *I) 
{
    return I[x+y*sizx+z*sizy*sizx];
}

// get color from certain postion in 3D image
double getcolor_protected(int x, int y, int z, int sizx, int sizy, int sizz, double *I) 
{
    if(x<0) { x=0; }
    if(x>(sizx-1)) { x=(sizx-1); }
    if(y<0) { y=0; }
    if(y>(sizy-1)) { y=(sizy-1); }
    if(z<0) { z=0; }
    if(z>(sizz-1)) { z=(sizz-1); }
    return I[x+y*sizx+z*sizy*sizx];
}


void calculate_shading(int x, int y, int z, int sizx, int sizy, int sizz, double *I, double *Mview, double *material, double *Ipar, double *L, double *V) 
{
    double S[3]={0,0,0};
    double N[3]={0,0,0};
    double R[3]={0,0,0};
    double length=0;
    double Ia=1;
    double Id;
    double Is;
    // Get the gradient of the voxel
    S[0]=(getcolor_protected(x+1,y,z,sizx,sizy,sizz,I)-getcolor_protected(x-1,y,z,sizx,sizy,sizz,I));
	S[1]=(getcolor_protected(x,y+1,z,sizx,sizy,sizz,I)-getcolor_protected(x,y-1,z,sizx,sizy,sizz,I));
	S[2]=(getcolor_protected(x,y,z+1,sizx,sizy,sizz,I)-getcolor_protected(x,y,z-1,sizx,sizy,sizz,I));
    
    // Rotate the gradient and normalize to get the surface normal in direction of the viewer
    N[0]=Mview[0]*S[0]+Mview[4]*S[1]+Mview[8]*S[2];
    N[1]=Mview[1]*S[0]+Mview[5]*S[1]+Mview[9]*S[2];
    N[2]=Mview[2]*S[0]+Mview[6]*S[1]+Mview[10]*S[2];
    length=sqrt(N[0]*N[0]+N[1]*N[1]+N[2]*N[2])+0.000001;
    N[0]=N[0]/length; N[1]=N[1]/length; N[2]=N[2]/length;

    // Id = dot(N,L);
    Id=N[0]*L[0]+N[1]*L[1]+N[2]*L[2];
    // R = 2.0*dot(N,L)*N - L;
    R[0]=2*Id*N[0]-L[0]; R[1]=2*Id*N[1]-L[1]; R[2]=2*Id*N[2]-L[2];
    // Is = max(pow(dot(R,V),3),0);
    Is=-R[0]*V[0]+R[1]*V[1]+R[2]*V[2]; 
    if(Is<0) { Is=0; } 
    // Specular exponent
    Is=pow(Is,(int)material[3]);
   
    Ipar[0]=material[0]*Ia; Ipar[1]=material[1]*Id; Ipar[2]=material[2]*Is;
}


// The matlab mex function
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    // I is the input image, J the transformed image
    // Tx and Ty images of the translation of every pixel.
    double *Iin, *Iout, *Ibuffer_r,*Ibuffer_g,*Ibuffer_b, *ALPHAbuffer;
    double *sizes, *Mshear, *Mwarp2D, *cd, *alpha, *alpha_m, *color;
    double *color_r, *color_g, *color_b, *Mview, *material;
    double *L, *V;
    
    // index storage
    int indexI;
    
    // shading parameters
    double Ipar[3]={0,0,0};
    
    // Rotate x,y,z variable
    int c=0;
    
    double transx=0; 
    double transy=0;
    // Loop variables (position)
    int z, px, py;
    
    // Offset
    double xd, yd;
    int xdfloor, ydfloor;

    // Warp positions
    double pxreal,pyreal;
    double pxrealt,pyrealt;

    // Size of input volume
    mwSize  Iin_sizex, Iin_sizey, Iin_sizez;
    const mwSize *dims;
    
    
    // Size of output image
    mwSize  Iout_sizex, Iout_sizey;
    mwSize  Iout_dims[3]={0,0,0};
   
    // Size of shearwarp image buffer
    mwSize  Ibuffer_sizex, Ibuffer_sizey;
    
    // alpha table
    double sizealpha_d;
    int sizealpha;
    int indexAlpha;
    double ALPHApix=0;
    
    // color table
    double sizecolor_d;
    int indexColor;
    
    // Color storage
    double intensity_loc;
    double lengthcor=0;
    
    // Start/end image
    int pxstart,pystart;
    int pxend,pyend;
    
    // interpolation variables;
    double perc[4]={0,0,0,0};
    double intensity_xyz[4]={0,0,0,0};
    int xBas[2]={0,0};
    int yBas[2]={0,0};
    double xCom, yCom;
        
    // Get the sizes of the input image(volume)   
    dims = mxGetDimensions(prhs[0]);  
    Iin_sizex = dims[0];  Iin_sizey = dims[1]; Iin_sizez = dims[2];

    // Get the size of the input Alpha (transparency) table
    dims = mxGetDimensions(prhs[5]);  
    sizealpha_d=(double)(dims[0]+dims[1])-1; 
    sizealpha=(dims[0]+dims[1]);
    
    /* Assign pointers to each input. */
    Iin=mxGetPr(prhs[0]);
    sizes=mxGetPr(prhs[1]);
    Mshear=mxGetPr(prhs[2]);
    Mwarp2D=mxGetPr(prhs[3]);
    cd=mxGetPr(prhs[4]);
    alpha_m=mxGetPr(prhs[5]);
    color=mxGetPr(prhs[6]);
    L=mxGetPr(prhs[7]);
    V=mxGetPr(prhs[8]);
    Mview=mxGetPr(prhs[9]);
    material=mxGetPr(prhs[10]);
    
    //Separate the Color table in two separate R,G,B tables 
    dims = mxGetDimensions(prhs[6]);  
    if(dims[0]>dims[1])
    {
        color_r=(double *)malloc(dims[0]* sizeof(double)); 
        color_g=(double *)malloc(dims[0]* sizeof(double)); 
        color_b=(double *)malloc(dims[0]* sizeof(double)); 
        for (z=0; z<dims[0]; z++)
        { 
            color_r[z]=color[z]; color_g[z]=color[z+dims[0]]; color_b[z]=color[z+dims[0]*2];
        }
        sizecolor_d=(double)(dims[0])-1;
    }
    else
    {
        color_r=(double *)malloc(dims[1]* sizeof(double)); 
        color_g=(double *)malloc(dims[1]* sizeof(double)); 
        color_b=(double *)malloc(dims[1]* sizeof(double)); 
        for (z=0; z<dims[1]; z++)
        { 
            color_r[z]=color[z*3];color_g[z]=color[z*3+1]; color_b[z]=color[z*3+2];
        }
        sizecolor_d=(double)(dims[1])-1;
    }
    
    // Real distance through one voxel
    lengthcor=sqrt(1+(Mshear[8]*Mshear[8]+Mshear[9]*Mshear[9]));
    alpha=(double *)malloc(sizealpha*sizeof(double)); 
    for (z=0; z<sizealpha; z++)
    { 
        alpha[z]=alpha_m[z]*lengthcor;
    }
    
    // set variable with main viewer direction (xyz or zyx or ...) 
    c=(int)cd[0];
    
    // Set sizes output image
    Iout_sizex=(mwSize)sizes[0]; Iout_sizey=(mwSize)sizes[1];
    
    // Calculate temporary image (buffer) for shear process
    Ibuffer_sizex=Iin_sizex;
    if(Ibuffer_sizex<Iin_sizey) { Ibuffer_sizex=Iin_sizey; }
    if(Ibuffer_sizex<Iin_sizez) { Ibuffer_sizex=Iin_sizez; }
    Ibuffer_sizex=(int)(1.7321*(double)Ibuffer_sizex)+1;
    Ibuffer_sizey=Ibuffer_sizex;

    // Create image matrix for the return arguments with the size of input image   
    Iout_dims[0]=Iout_sizex; 
    Iout_dims[1]=Iout_sizey;
    Iout_dims[2]=3;
    plhs[0] = mxCreateNumericArray(3, Iout_dims, mxDOUBLE_CLASS, mxREAL); 
    
    // Also create a tempory image (before shear)
    Ibuffer_r = (double *)malloc( Ibuffer_sizex*Ibuffer_sizey* sizeof(double));  
    Ibuffer_g = (double *)malloc( Ibuffer_sizex*Ibuffer_sizey* sizeof(double));  
    Ibuffer_b = (double *)malloc( Ibuffer_sizex*Ibuffer_sizey* sizeof(double));  
    ALPHAbuffer = (double *)malloc( Ibuffer_sizex*Ibuffer_sizey* sizeof(double));  
    for (z=0; z<Ibuffer_sizex*Ibuffer_sizey; z++)
    { 
        Ibuffer_r[z] = 0; 
        Ibuffer_g[z] = 0; 
        Ibuffer_b[z] = 0;
        ALPHAbuffer[z] = 0;
    }
    
    /* Assign pointer to output image. */
    Iout = mxGetPr(plhs[0]);


    
switch (c)  // Select based on viewer direction.
{
   case 1: 
        for (z=0; z<Iin_sizex; z++)
        {
            // Offset calculation
            xd=(-Ibuffer_sizex/2)+Mshear[8]*(z-Iin_sizex/2)+Iin_sizey/2;    
            yd=(-Ibuffer_sizey/2)+Mshear[9]*(z-Iin_sizex/2)+Iin_sizez/2; 
            xdfloor=(int)floor(xd); ydfloor=(int)floor(yd);
            
            // Linear interpolation constants (percentages)
            xCom=xd-floor(xd);  yCom=yd-floor(yd);
            perc[0]=(1-xCom) * (1-yCom); perc[1]=(1-xCom) * yCom;
            perc[2]=xCom * (1-yCom); perc[3]=xCom * yCom;
            
            // Calculate the coordinates on which a image slice starts and 
            // ends in the temporary shear image (buffer)
            pystart=-ydfloor; if(pystart<0) {pystart=0; }
            pyend=Iin_sizez-ydfloor; if(pyend>Ibuffer_sizey) {pyend=Ibuffer_sizey; }
            pxstart=-xdfloor; if(pxstart<0) {pxstart=0; }
            pxend=Iin_sizey-xdfloor; if(pxend>Ibuffer_sizex) {pxend=Ibuffer_sizex; }
            
            // Loop through the pixel locations of the shear image buffer
            for (py=pystart; py<pyend-1; py++)
            {
                // Determine y coordinates of pixel(s) which will be come current pixel
                yBas[0]=py+ydfloor; yBas[1]=yBas[0]+1;
                for (px=pxstart; px<pxend-1; px++)
                {
                    // Calculate index of current pixel
                    indexI=px+py*Ibuffer_sizex;
                    if(ALPHAbuffer[indexI]<0.95)
                    {
                        // Determine x coordinates of pixel(s) which will be come current pixel
                        xBas[0]=px+xdfloor; xBas[1]=xBas[0]+1;    

                        // Get the intensities
                        intensity_xyz[0]=getcolor(z,xBas[0], yBas[0], Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                        intensity_xyz[1]=getcolor(z,xBas[0], yBas[1], Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                        intensity_xyz[2]=getcolor(z,xBas[1], yBas[0], Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                        intensity_xyz[3]=getcolor(z,xBas[1], yBas[1], Iin_sizex, Iin_sizey, Iin_sizez,Iin); 

                        // Calculate the interpolated intensity
                        intensity_loc=intensity_xyz[0]*perc[0]+intensity_xyz[1]*perc[1]+intensity_xyz[2]*perc[2]+intensity_xyz[3]*perc[3];

                        // Calculate index in alpha transparency look up table
                        indexAlpha=(int)(intensity_loc*sizealpha_d);
                        // Calculate index in color transparency look up table
                        indexColor=(int)(intensity_loc*sizecolor_d);
                        // Update the current pixel in the shear image buffer
                        calculate_shading(z,xBas[0], yBas[0], Iin_sizex, Iin_sizey, Iin_sizez, Iin, Mview, material,Ipar,L,V);
                        ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                        ALPHAbuffer[indexI]+=ALPHApix;
                        Ibuffer_r[indexI]=Ibuffer_r[indexI]+(color_r[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_g[indexI]=Ibuffer_g[indexI]+(color_g[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_b[indexI]=Ibuffer_b[indexI]+(color_b[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                    }
                    
                }
            }
            
            // Process the edges 
            px=pxend-1;
            xBas[0]=px+xdfloor; 
            for (py=pystart; py<pyend-1; py++)
            {
                yBas[0]=py+ydfloor; yBas[1]=yBas[0]+1;
                intensity_xyz[0]=getcolor(z,xBas[0], yBas[0], Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                intensity_xyz[1]=getcolor(z,xBas[0], yBas[1], Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                intensity_loc=intensity_xyz[0]*(perc[0]+perc[2])+intensity_xyz[1]*(perc[1]+perc[3]);
                indexI=px+py*Ibuffer_sizex;
                // Calculate index in alpha transparency look up table
                indexAlpha=(int)(intensity_loc*sizealpha_d);
                // Calculate index in color transparency look up table
                indexColor=(int)(intensity_loc*sizecolor_d);
                        // Update the current pixel in the shear image buffer
                        calculate_shading(z,xBas[0], yBas[0], Iin_sizex, Iin_sizey, Iin_sizez, Iin, Mview, material,Ipar,L,V);
                        ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                        ALPHAbuffer[indexI]+=ALPHApix;
                        Ibuffer_r[indexI]=Ibuffer_r[indexI]+(color_r[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_g[indexI]=Ibuffer_g[indexI]+(color_g[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_b[indexI]=Ibuffer_b[indexI]+(color_b[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
            }
            py=pyend-1;
            yBas[0]=py+ydfloor; 
            for (px=pxstart; px<pxend-1; px++)
            {
                xBas[0]=px+xdfloor; xBas[1]=xBas[0]+1;
                // Calculate index of current pixel
                indexI=px+py*Ibuffer_sizex;
                if(ALPHAbuffer[indexI]<0.95)
                {
                    intensity_xyz[0]=getcolor(z,xBas[0], yBas[0], Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                    intensity_xyz[2]=getcolor(z,xBas[1], yBas[0], Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                    intensity_loc=intensity_xyz[0]*(perc[0]+perc[1])+intensity_xyz[2]*(perc[2]+perc[3]);
                     // Calculate index in alpha transparency look up table
                    indexAlpha=(int)(intensity_loc*sizealpha_d);
                    // Calculate index in color transparency look up table
                    indexColor=(int)(intensity_loc*sizecolor_d);
                        // Update the current pixel in the shear image buffer
                        calculate_shading(z,xBas[0], yBas[0], Iin_sizex, Iin_sizey, Iin_sizez, Iin, Mview, material,Ipar,L,V);
                        ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                        ALPHAbuffer[indexI]+=ALPHApix;
                        Ibuffer_r[indexI]=Ibuffer_r[indexI]+(color_r[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_g[indexI]=Ibuffer_g[indexI]+(color_g[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_b[indexI]=Ibuffer_b[indexI]+(color_b[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                }
            }
            px=pxend-1; py=pyend-1;
            xBas[0]=px+xdfloor;  yBas[0]=py+ydfloor; 
            // Calculate index of current pixel
            indexI=px+py*Ibuffer_sizex;
            if(ALPHAbuffer[indexI]<0.95)
            {
                intensity_loc=getcolor(z,xBas[0], yBas[0], Iin_sizex, Iin_sizey, Iin_sizez,Iin);
                // Calculate index in alpha transparency look up table
                indexAlpha=(int)(intensity_loc*sizealpha_d);
                // Calculate index in color transparency look up table
                indexColor=(int)(intensity_loc*sizecolor_d);
                        // Update the current pixel in the shear image buffer
                        calculate_shading(z,xBas[0], yBas[0], Iin_sizex, Iin_sizey, Iin_sizez, Iin, Mview, material,Ipar,L,V);
                        ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                        ALPHAbuffer[indexI]+=ALPHApix;
                        Ibuffer_r[indexI]=Ibuffer_r[indexI]+(color_r[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_g[indexI]=Ibuffer_g[indexI]+(color_g[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_b[indexI]=Ibuffer_b[indexI]+(color_b[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
            }
        }
    break;

    
    case 2: 
        for (z=0; z<Iin_sizey; z++)
        {
            // Offset calculation
            xd=(-Ibuffer_sizex/2)+Mshear[8]*(z-Iin_sizey/2)+Iin_sizez/2;   
            yd=(-Ibuffer_sizey/2)+Mshear[9]*(z-Iin_sizey/2)+Iin_sizex/2; 
            xdfloor=(int)floor(xd); ydfloor=(int)floor(yd);
            
            // Linear interpolation constants (percentages)
            xCom=xd-floor(xd);  yCom=yd-floor(yd);
            perc[0]=(1-xCom) * (1-yCom); perc[1]=(1-xCom) * yCom;
            perc[2]=xCom * (1-yCom); perc[3]=xCom * yCom;
            
            // Calculate the coordinates on which a image slice starts and 
            // ends in the temporary shear image (buffer)
            pystart=-ydfloor; if(pystart<0) {pystart=0; }
            pyend=Iin_sizex-ydfloor; if(pyend>Ibuffer_sizey) {pyend=Ibuffer_sizey; }
            pxstart=-xdfloor; if(pxstart<0) {pxstart=0; }
            pxend=Iin_sizez-xdfloor; if(pxend>Ibuffer_sizex) {pxend=Ibuffer_sizex; }
                        
            // Loop through the pixel locations of the shear image buffer
            for (py=pystart; py<pyend-1; py++)
            {
                // Determine y coordinates of pixel(s) which will be come current pixel
                yBas[0]=py+ydfloor; yBas[1]=yBas[0]+1;
                for (px=pxstart; px<pxend-1; px++)
                {
                    // Calculate index of current pixel
                    indexI=px+py*Ibuffer_sizex;
                    if(ALPHAbuffer[indexI]<0.95)
                    {
                        // Determine x coordinates of pixel(s) which will be come current pixel
                        xBas[0]=px+xdfloor; xBas[1]=xBas[0]+1;    

                        // Get the intensities
                        intensity_xyz[0]=getcolor(yBas[0], z,xBas[0], Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                        intensity_xyz[1]=getcolor(yBas[1], z,xBas[0], Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                        intensity_xyz[2]=getcolor(yBas[0], z,xBas[1], Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                        intensity_xyz[3]=getcolor(yBas[1], z,xBas[1], Iin_sizex, Iin_sizey, Iin_sizez,Iin); 

                        // Calculate the interpolated intensity
                        intensity_loc=intensity_xyz[0]*perc[0]+intensity_xyz[1]*perc[1]+intensity_xyz[2]*perc[2]+intensity_xyz[3]*perc[3];

                        // Calculate index in alpha transparency look up table
                        indexAlpha=(int)(intensity_loc*sizealpha_d);

                        // Calculate index in color transparency look up table
                        indexColor=(int)(intensity_loc*sizecolor_d);

                        // Calculate index in alpha transparency look up table
                        indexAlpha=(int)(intensity_loc*sizealpha_d);
                        // Calculate index in color transparency look up table
                        indexColor=(int)(intensity_loc*sizecolor_d);
                        // Update the current pixel in the shear image buffer
                        calculate_shading(yBas[0], z,xBas[0], Iin_sizex, Iin_sizey, Iin_sizez, Iin, Mview, material,Ipar,L,V);
                        ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                        ALPHAbuffer[indexI]+=ALPHApix;
                        Ibuffer_r[indexI]=Ibuffer_r[indexI]+(color_r[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_g[indexI]=Ibuffer_g[indexI]+(color_g[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_b[indexI]=Ibuffer_b[indexI]+(color_b[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                    }

                }
            }
            
            // Process edges
            px=pxend-1;
            xBas[0]=px+xdfloor; 
            for (py=pystart; py<pyend-1; py++)
            {
                // Calculate index of current pixel
                indexI=px+py*Ibuffer_sizex;
                if(ALPHAbuffer[indexI]<0.95)
                {
                    yBas[0]=py+ydfloor; yBas[1]=yBas[0]+1;
                    intensity_xyz[0]=getcolor(yBas[0], z,xBas[0], Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                    intensity_xyz[1]=getcolor(yBas[1], z,xBas[0], Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                    intensity_loc=intensity_xyz[0]*(perc[0]+perc[2])+intensity_xyz[1]*(perc[1]+perc[3]);
                    // Calculate index in alpha transparency look up table
                    indexAlpha=(int)(intensity_loc*sizealpha_d);
                    // Calculate index in color transparency look up table
                    indexColor=(int)(intensity_loc*sizecolor_d);
                        // Update the current pixel in the shear image buffer
                        calculate_shading(yBas[0], z,xBas[0], Iin_sizex, Iin_sizey, Iin_sizez, Iin, Mview, material,Ipar,L,V);
                        ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                        ALPHAbuffer[indexI]+=ALPHApix;
                        Ibuffer_r[indexI]=Ibuffer_r[indexI]+(color_r[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_g[indexI]=Ibuffer_g[indexI]+(color_g[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_b[indexI]=Ibuffer_b[indexI]+(color_b[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                }
            }
            py=pyend-1;
            yBas[0]=py+ydfloor; 
            for (px=pxstart; px<pxend-1; px++)
            {
                // Calculate index of current pixel
                indexI=px+py*Ibuffer_sizex;
                if(ALPHAbuffer[indexI]<0.95)
                {

                    xBas[0]=px+xdfloor; xBas[1]=xBas[0]+1;
                    intensity_xyz[0]=getcolor(yBas[0], z,xBas[0], Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                    intensity_xyz[2]=getcolor(yBas[0], z,xBas[1], Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                    intensity_loc=intensity_xyz[0]*(perc[0]+perc[1])+intensity_xyz[2]*(perc[2]+perc[3]);
                     // Calculate index in alpha transparency look up table
                    indexAlpha=(int)(intensity_loc*sizealpha_d);
                    // Calculate index in color transparency look up table
                    indexColor=(int)(intensity_loc*sizecolor_d);
                        // Update the current pixel in the shear image buffer
                        calculate_shading(yBas[0], z,xBas[0], Iin_sizex, Iin_sizey, Iin_sizez, Iin, Mview, material,Ipar,L,V);
                        ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                        ALPHAbuffer[indexI]+=ALPHApix;
                        Ibuffer_r[indexI]=Ibuffer_r[indexI]+(color_r[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_g[indexI]=Ibuffer_g[indexI]+(color_g[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_b[indexI]=Ibuffer_b[indexI]+(color_b[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                }
            }
            px=pxend-1; py=pyend-1;
            // Calculate index of current pixel
            indexI=px+py*Ibuffer_sizex;
            if(ALPHAbuffer[indexI]<0.95)
            {
                xBas[0]=px+xdfloor;  yBas[0]=py+ydfloor; 
                intensity_loc=getcolor(yBas[0], z,xBas[0], Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                 // Calculate index in alpha transparency look up table
                indexAlpha=(int)(intensity_loc*sizealpha_d);
                // Calculate index in color transparency look up table
                indexColor=(int)(intensity_loc*sizecolor_d);
                        // Update the current pixel in the shear image buffer
                        calculate_shading(yBas[0], z,xBas[0], Iin_sizex, Iin_sizey, Iin_sizez, Iin, Mview, material,Ipar,L,V);
                        ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                        ALPHAbuffer[indexI]+=ALPHApix;
                        Ibuffer_r[indexI]=Ibuffer_r[indexI]+(color_r[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_g[indexI]=Ibuffer_g[indexI]+(color_g[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_b[indexI]=Ibuffer_b[indexI]+(color_b[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
            }
        }
    break;
    
    case 3: //xyz
        for (z=0; z<Iin_sizez; z++)
        {
            // Offset calculation
            xd=(-Ibuffer_sizex/2)+Mshear[8]*(z-Iin_sizez/2)+Iin_sizex/2;    
            yd=(-Ibuffer_sizey/2)+Mshear[9]*(z-Iin_sizez/2)+Iin_sizey/2; 
            xdfloor=(int)floor(xd); ydfloor=(int)floor(yd);
            
            // Linear interpolation constants (percentages)
            xCom=xd-floor(xd);  yCom=yd-floor(yd);
            perc[0]=(1-xCom) * (1-yCom); perc[1]=(1-xCom) * yCom;
            perc[2]=xCom * (1-yCom); perc[3]=xCom * yCom;
            
            // Calculate the coordinates on which a image slice starts and 
            // ends in the temporary shear image (buffer)
            pystart=-ydfloor; if(pystart<0) {pystart=0; }
            pyend=Iin_sizey-ydfloor; if(pyend>Ibuffer_sizey) {pyend=Ibuffer_sizey; }
            pxstart=-xdfloor; if(pxstart<0) {pxstart=0; }
            pxend=Iin_sizex-xdfloor; if(pxend>Ibuffer_sizex) {pxend=Ibuffer_sizex; }
            for (py=pystart; py<pyend-1; py++)
            {
                // Determine y coordinates of pixel(s) which will be come current pixel
                yBas[0]=py+ydfloor; yBas[1]=yBas[0]+1;
                for (px=pxstart; px<pxend-1; px++)
                {
                    // Calculate index of current pixel
                    indexI=px+py*Ibuffer_sizex;
                    if(ALPHAbuffer[indexI]<0.95)
                    {                    
                        // Determine x coordinates of pixel(s) which will be come current pixel
                        xBas[0]=px+xdfloor; xBas[1]=xBas[0]+1;    

                        // Get the intensities
                        intensity_xyz[0]=getcolor(xBas[0], yBas[0], z, Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                        intensity_xyz[1]=getcolor(xBas[0], yBas[1], z, Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                        intensity_xyz[2]=getcolor(xBas[1], yBas[0], z, Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                        intensity_xyz[3]=getcolor(xBas[1], yBas[1], z, Iin_sizex, Iin_sizey, Iin_sizez,Iin); 

                        // Calculate the interpolated intensity
                        intensity_loc=intensity_xyz[0]*perc[0]+intensity_xyz[1]*perc[1]+intensity_xyz[2]*perc[2]+intensity_xyz[3]*perc[3];

                        // Calculate index in alpha transparency look up table
                        indexAlpha=(int)(intensity_loc*sizealpha_d);

                        // Calculate index in color transparency look up table
                        indexColor=(int)(intensity_loc*sizecolor_d);

                        // Calculate index in alpha transparency look up table
                        indexAlpha=(int)(intensity_loc*sizealpha_d);
                        // Calculate index in color transparency look up table
                        indexColor=(int)(intensity_loc*sizecolor_d);
                        // Update the current pixel in the shear image buffer
                        calculate_shading(xBas[0], yBas[0], z, Iin_sizex, Iin_sizey, Iin_sizez, Iin, Mview, material,Ipar,L,V);
                        ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                        ALPHAbuffer[indexI]+=ALPHApix;
                        Ibuffer_r[indexI]=Ibuffer_r[indexI]+(color_r[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_g[indexI]=Ibuffer_g[indexI]+(color_g[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_b[indexI]=Ibuffer_b[indexI]+(color_b[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                    }
                }
            }


            // Process edges
            px=pxend-1;
            xBas[0]=px+xdfloor; 
            for (py=pystart; py<pyend-1; py++)
            {
                // Calculate index of current pixel
                indexI=px+py*Ibuffer_sizex;
                if(ALPHAbuffer[indexI]<0.95)
                {
                    yBas[0]=py+ydfloor; yBas[1]=yBas[0]+1;
                    intensity_xyz[0]=getcolor(xBas[0], yBas[0], z, Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                    intensity_xyz[1]=getcolor(xBas[0], yBas[1], z, Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                    intensity_loc=intensity_xyz[0]*(perc[0]+perc[2])+intensity_xyz[1]*(perc[1]+perc[3]);
                    // Calculate index in alpha transparency look up table
                    indexAlpha=(int)(intensity_loc*sizealpha_d);
                    // Calculate index in color transparency look up table
                    indexColor=(int)(intensity_loc*sizecolor_d);
                        // Update the current pixel in the shear image buffer
                        calculate_shading(xBas[0], yBas[0], z, Iin_sizex, Iin_sizey, Iin_sizez, Iin, Mview, material,Ipar,L,V);
                        ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                        ALPHAbuffer[indexI]+=ALPHApix;
                        Ibuffer_r[indexI]=Ibuffer_r[indexI]+(color_r[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_g[indexI]=Ibuffer_g[indexI]+(color_g[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_b[indexI]=Ibuffer_b[indexI]+(color_b[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                }
            }
            py=pyend-1;
            yBas[0]=py+ydfloor; 
            for (px=pxstart; px<pxend-1; px++)
            {
                // Calculate index of current pixel
                indexI=px+py*Ibuffer_sizex;
                if(ALPHAbuffer[indexI]<0.95)
                {
                    xBas[0]=px+xdfloor; xBas[1]=xBas[0]+1;
                    intensity_xyz[0]=getcolor(xBas[0], yBas[0], z, Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                    intensity_xyz[2]=getcolor(xBas[1], yBas[0], z, Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                    intensity_loc=intensity_xyz[0]*(perc[0]+perc[1])+intensity_xyz[2]*(perc[2]+perc[3]);
                     // Calculate index in alpha transparency look up table
                    indexAlpha=(int)(intensity_loc*sizealpha_d);
                    // Calculate index in color transparency look up table
                    indexColor=(int)(intensity_loc*sizecolor_d);
                        // Update the current pixel in the shear image buffer
                        calculate_shading(xBas[0], yBas[0], z, Iin_sizex, Iin_sizey, Iin_sizez, Iin, Mview, material,Ipar,L,V);
                        ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                        ALPHAbuffer[indexI]+=ALPHApix;
                        Ibuffer_r[indexI]=Ibuffer_r[indexI]+(color_r[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_g[indexI]=Ibuffer_g[indexI]+(color_g[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_b[indexI]=Ibuffer_b[indexI]+(color_b[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                }
            }
            px=pxend-1; py=pyend-1;
            // Calculate index of current pixel
            indexI=px+py*Ibuffer_sizex;
            if(ALPHAbuffer[indexI]<0.95)
            {
                xBas[0]=px+xdfloor;  yBas[0]=py+ydfloor; 
                intensity_loc=getcolor(xBas[0], yBas[0], z, Iin_sizex, Iin_sizey, Iin_sizez,Iin);
                indexI=px+py*Ibuffer_sizex;
                 // Calculate index in alpha transparency look up table
                indexAlpha=(int)(intensity_loc*sizealpha_d);
                // Calculate index in color transparency look up table
                indexColor=(int)(intensity_loc*sizecolor_d);
                        // Update the current pixel in the shear image buffer
                        calculate_shading(xBas[0], yBas[0], z, Iin_sizex, Iin_sizey, Iin_sizez, Iin, Mview, material,Ipar,L,V);
                        ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                        ALPHAbuffer[indexI]+=ALPHApix;
                        Ibuffer_r[indexI]=Ibuffer_r[indexI]+(color_r[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_g[indexI]=Ibuffer_g[indexI]+(color_g[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_b[indexI]=Ibuffer_b[indexI]+(color_b[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
            }
        }
    break;
    
      case 4: 
        for (z=(Iin_sizex-1); z>=0; z--)
        {
            // Offset calculation
            xd=(-Ibuffer_sizex/2)+Mshear[8]*(z-Iin_sizex/2)+Iin_sizey/2;    
            yd=(-Ibuffer_sizey/2)+Mshear[9]*(z-Iin_sizex/2)+Iin_sizez/2; 
            xdfloor=(int)floor(xd); ydfloor=(int)floor(yd);
            
            // Linear interpolation constants (percentages)
            xCom=xd-floor(xd);  yCom=yd-floor(yd);
            perc[0]=(1-xCom) * (1-yCom); perc[1]=(1-xCom) * yCom;
            perc[2]=xCom * (1-yCom); perc[3]=xCom * yCom;
            
            // Calculate the coordinates on which a image slice starts and 
            // ends in the temporary shear image (buffer)
            pystart=-ydfloor; if(pystart<0) {pystart=0; }
            pyend=Iin_sizez-ydfloor; if(pyend>Ibuffer_sizey) {pyend=Ibuffer_sizey; }
            pxstart=-xdfloor; if(pxstart<0) {pxstart=0; }
            pxend=Iin_sizey-xdfloor; if(pxend>Ibuffer_sizex) {pxend=Ibuffer_sizex; }
            
            // Loop through the pixel locations of the shear image buffer
            for (py=pystart; py<pyend-1; py++)
            {
                // Determine y coordinates of pixel(s) which will be come current pixel
                yBas[0]=py+ydfloor; yBas[1]=yBas[0]+1;
                for (px=pxstart; px<pxend-1; px++)
                {
                    // Calculate index of current pixel
                    indexI=px+py*Ibuffer_sizex;
                    if(ALPHAbuffer[indexI]<0.95)
                    {

                        // Determine x coordinates of pixel(s) which will be come current pixel
                        xBas[0]=px+xdfloor; xBas[1]=xBas[0]+1;    

                        // Get the intensities
                        intensity_xyz[0]=getcolor(z,xBas[0], yBas[0], Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                        intensity_xyz[1]=getcolor(z,xBas[0], yBas[1], Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                        intensity_xyz[2]=getcolor(z,xBas[1], yBas[0], Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                        intensity_xyz[3]=getcolor(z,xBas[1], yBas[1], Iin_sizex, Iin_sizey, Iin_sizez,Iin); 

                        // Calculate the interpolated intensity
                        intensity_loc=intensity_xyz[0]*perc[0]+intensity_xyz[1]*perc[1]+intensity_xyz[2]*perc[2]+intensity_xyz[3]*perc[3];

                        // Calculate index in alpha transparency look up table
                        indexAlpha=(int)(intensity_loc*sizealpha_d);

                        // Calculate index in color transparency look up table
                        indexColor=(int)(intensity_loc*sizecolor_d);

                        // Calculate index in alpha transparency look up table
                        indexAlpha=(int)(intensity_loc*sizealpha_d);
                        // Calculate index in color transparency look up table
                        indexColor=(int)(intensity_loc*sizecolor_d);
                        // Update the current pixel in the shear image buffer
                        calculate_shading(z,xBas[0], yBas[0], Iin_sizex, Iin_sizey, Iin_sizez, Iin, Mview, material,Ipar,L,V);
                        ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                        ALPHAbuffer[indexI]+=ALPHApix;
                        Ibuffer_r[indexI]=Ibuffer_r[indexI]+(color_r[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_g[indexI]=Ibuffer_g[indexI]+(color_g[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_b[indexI]=Ibuffer_b[indexI]+(color_b[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                    }
                }
            }
            
            // Process edges
            px=pxend-1;
            xBas[0]=px+xdfloor; 
            for (py=pystart; py<pyend-1; py++)
            {
                // Calculate index of current pixel
                indexI=px+py*Ibuffer_sizex;
                if(ALPHAbuffer[indexI]<0.95)
                {
                    yBas[0]=py+ydfloor; yBas[1]=yBas[0]+1;
                    intensity_xyz[0]=getcolor(z,xBas[0], yBas[0], Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                    intensity_xyz[1]=getcolor(z,xBas[0], yBas[1], Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                    intensity_loc=intensity_xyz[0]*(perc[0]+perc[2])+intensity_xyz[1]*(perc[1]+perc[3]);
                     // Calculate index in alpha transparency look up table
                    indexAlpha=(int)(intensity_loc*sizealpha_d);
                    // Calculate index in color transparency look up table
                    indexColor=(int)(intensity_loc*sizecolor_d);
                        // Update the current pixel in the shear image buffer
                        calculate_shading(z,xBas[0], yBas[0], Iin_sizex, Iin_sizey, Iin_sizez, Iin, Mview, material,Ipar,L,V);
                        ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                        ALPHAbuffer[indexI]+=ALPHApix;
                        Ibuffer_r[indexI]=Ibuffer_r[indexI]+(color_r[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_g[indexI]=Ibuffer_g[indexI]+(color_g[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_b[indexI]=Ibuffer_b[indexI]+(color_b[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                }
            }
            py=pyend-1;
            yBas[0]=py+ydfloor; 
            for (px=pxstart; px<pxend-1; px++)
            {
                // Calculate index of current pixel
                indexI=px+py*Ibuffer_sizex;
                if(ALPHAbuffer[indexI]<0.95)
                {
                    xBas[0]=px+xdfloor; xBas[1]=xBas[0]+1;
                    intensity_xyz[0]=getcolor(z,xBas[0], yBas[0], Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                    intensity_xyz[2]=getcolor(z,xBas[1], yBas[0], Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                    intensity_loc=intensity_xyz[0]*(perc[0]+perc[1])+intensity_xyz[2]*(perc[2]+perc[3]);
                     // Calculate index in alpha transparency look up table
                    indexAlpha=(int)(intensity_loc*sizealpha_d);
                    // Calculate index in color transparency look up table
                    indexColor=(int)(intensity_loc*sizecolor_d);
                        // Update the current pixel in the shear image buffer
                        calculate_shading(z,xBas[0], yBas[0], Iin_sizex, Iin_sizey, Iin_sizez, Iin, Mview, material,Ipar,L,V);
                        ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                        ALPHAbuffer[indexI]+=ALPHApix;
                        Ibuffer_r[indexI]=Ibuffer_r[indexI]+(color_r[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_g[indexI]=Ibuffer_g[indexI]+(color_g[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_b[indexI]=Ibuffer_b[indexI]+(color_b[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                }
            }
            px=pxend-1; py=pyend-1;
            // Calculate index of current pixel
            indexI=px+py*Ibuffer_sizex;
            if(ALPHAbuffer[indexI]<0.95)
            {
                xBas[0]=px+xdfloor;  yBas[0]=py+ydfloor; 
                intensity_loc=getcolor(z,xBas[0], yBas[0], Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                 // Calculate index in alpha transparency look up table
                indexAlpha=(int)(intensity_loc*sizealpha_d);
                // Calculate index in color transparency look up table
                indexColor=(int)(intensity_loc*sizecolor_d);
                        // Update the current pixel in the shear image buffer
                        calculate_shading(z,xBas[0], yBas[0], Iin_sizex, Iin_sizey, Iin_sizez, Iin, Mview, material,Ipar,L,V);
                        ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                        ALPHAbuffer[indexI]+=ALPHApix;
                        Ibuffer_r[indexI]=Ibuffer_r[indexI]+(color_r[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_g[indexI]=Ibuffer_g[indexI]+(color_g[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_b[indexI]=Ibuffer_b[indexI]+(color_b[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
            }
        }
    break;

    
    case 5: 
        for (z=(Iin_sizey-1); z>=0; z--)
        {
            // Offset calculation
            xd=(-Ibuffer_sizex/2)+Mshear[8]*(z-Iin_sizey/2)+Iin_sizez/2;   
            yd=(-Ibuffer_sizey/2)+Mshear[9]*(z-Iin_sizey/2)+Iin_sizex/2; 
            xdfloor=(int)floor(xd); ydfloor=(int)floor(yd);
            
            // Linear interpolation constants (percentages)
            xCom=xd-floor(xd);  yCom=yd-floor(yd);
            perc[0]=(1-xCom) * (1-yCom); perc[1]=(1-xCom) * yCom;
            perc[2]=xCom * (1-yCom); perc[3]=xCom * yCom;
            
            // Calculate the coordinates on which a image slice starts and 
            // ends in the temporary shear image (buffer)
            pystart=-ydfloor; if(pystart<0) {pystart=0; }
            pyend=Iin_sizex-ydfloor; if(pyend>Ibuffer_sizey) {pyend=Ibuffer_sizey; }
            pxstart=-xdfloor; if(pxstart<0) {pxstart=0; }
            pxend=Iin_sizez-xdfloor; if(pxend>Ibuffer_sizex) {pxend=Ibuffer_sizex; }
            
            // Loop through the pixel locations of the shear image buffer
            for (py=pystart; py<pyend-1; py++)
            {
                // Determine y coordinates of pixel(s) which will be come current pixel
                yBas[0]=py+ydfloor; yBas[1]=yBas[0]+1;
                for (px=pxstart; px<pxend-1; px++)
                {
                    // Calculate index of current pixel
                    indexI=px+py*Ibuffer_sizex;
                    if(ALPHAbuffer[indexI]<0.95)
                    {

                        // Determine x coordinates of pixel(s) which will be come current pixel
                        xBas[0]=px+xdfloor; xBas[1]=xBas[0]+1;    

                        // Get the intensities
                        intensity_xyz[0]=getcolor(yBas[0], z,xBas[0], Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                        intensity_xyz[1]=getcolor(yBas[1], z,xBas[0], Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                        intensity_xyz[2]=getcolor(yBas[0], z,xBas[1], Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                        intensity_xyz[3]=getcolor(yBas[1], z,xBas[1], Iin_sizex, Iin_sizey, Iin_sizez,Iin); 

                        // Calculate the interpolated intensity
                        intensity_loc=intensity_xyz[0]*perc[0]+intensity_xyz[1]*perc[1]+intensity_xyz[2]*perc[2]+intensity_xyz[3]*perc[3];

                        // Calculate index in alpha transparency look up table
                        indexAlpha=(int)(intensity_loc*sizealpha_d);

                        // Calculate index in color transparency look up table
                        indexColor=(int)(intensity_loc*sizecolor_d);

                        // Calculate index in alpha transparency look up table
                        indexAlpha=(int)(intensity_loc*sizealpha_d);
                        // Calculate index in color transparency look up table
                        indexColor=(int)(intensity_loc*sizecolor_d);
                        // Update the current pixel in the shear image buffer
                        calculate_shading(yBas[0], z,xBas[0], Iin_sizex, Iin_sizey, Iin_sizez, Iin, Mview, material,Ipar,L,V);
                        ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                        ALPHAbuffer[indexI]+=ALPHApix;
                        Ibuffer_r[indexI]=Ibuffer_r[indexI]+(color_r[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_g[indexI]=Ibuffer_g[indexI]+(color_g[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_b[indexI]=Ibuffer_b[indexI]+(color_b[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                    }
                }
            }
            
            // Process edges
            px=pxend-1;
            xBas[0]=px+xdfloor; 
            for (py=pystart; py<pyend-1; py++)
            {
                // Calculate index of current pixel
                indexI=px+py*Ibuffer_sizex;
                if(ALPHAbuffer[indexI]<0.95)
                {
                    yBas[0]=py+ydfloor; yBas[1]=yBas[0]+1;
                    intensity_xyz[0]=getcolor(yBas[0], z,xBas[0], Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                    intensity_xyz[1]=getcolor(yBas[1], z,xBas[0], Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                    intensity_loc=intensity_xyz[0]*(perc[0]+perc[2])+intensity_xyz[1]*(perc[1]+perc[3]);
                     // Calculate index in alpha transparency look up table
                    indexAlpha=(int)(intensity_loc*sizealpha_d);
                    // Calculate index in color transparency look up table
                    indexColor=(int)(intensity_loc*sizecolor_d);
                        // Update the current pixel in the shear image buffer
                        calculate_shading(yBas[0], z,xBas[0], Iin_sizex, Iin_sizey, Iin_sizez, Iin, Mview, material,Ipar,L,V);
                        ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                        ALPHAbuffer[indexI]+=ALPHApix;
                        Ibuffer_r[indexI]=Ibuffer_r[indexI]+(color_r[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_g[indexI]=Ibuffer_g[indexI]+(color_g[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_b[indexI]=Ibuffer_b[indexI]+(color_b[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                }
            }
            py=pyend-1;
            yBas[0]=py+ydfloor; 
            for (px=pxstart; px<pxend-1; px++)
            {
                // Calculate index of current pixel
                indexI=px+py*Ibuffer_sizex;
                if(ALPHAbuffer[indexI]<0.95)
                {
                    xBas[0]=px+xdfloor; xBas[1]=xBas[0]+1;
                    intensity_xyz[0]=getcolor(yBas[0], z,xBas[0], Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                    intensity_xyz[2]=getcolor(yBas[0], z,xBas[1], Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                    intensity_loc=intensity_xyz[0]*(perc[0]+perc[1])+intensity_xyz[2]*(perc[2]+perc[3]);
                     // Calculate index in alpha transparency look up table
                    indexAlpha=(int)(intensity_loc*sizealpha_d);
                    // Calculate index in color transparency look up table
                        // Update the current pixel in the shear image buffer
                        calculate_shading(yBas[0], z,xBas[0], Iin_sizex, Iin_sizey, Iin_sizez, Iin, Mview, material,Ipar,L,V);
                        ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                        ALPHAbuffer[indexI]+=ALPHApix;
                        Ibuffer_r[indexI]=Ibuffer_r[indexI]+(color_r[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_g[indexI]=Ibuffer_g[indexI]+(color_g[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_b[indexI]=Ibuffer_b[indexI]+(color_b[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                }
            }
            px=pxend-1; py=pyend-1;
            // Calculate index of current pixel
            indexI=px+py*Ibuffer_sizex;
            if(ALPHAbuffer[indexI]<0.95)
            {
                xBas[0]=px+xdfloor;  yBas[0]=py+ydfloor; 
                intensity_loc=getcolor(yBas[0], z,xBas[0], Iin_sizex, Iin_sizey, Iin_sizez,Iin);
                indexI=px+py*Ibuffer_sizex;
                // Calculate index in alpha transparency look up table
                indexAlpha=(int)(intensity_loc*sizealpha_d);
                // Calculate index in color transparency look up table
                indexColor=(int)(intensity_loc*sizecolor_d);
                        // Update the current pixel in the shear image buffer
                        calculate_shading(yBas[0], z,xBas[0],Iin_sizex, Iin_sizey, Iin_sizez, Iin, Mview, material,Ipar,L,V);
                        ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                        ALPHAbuffer[indexI]+=ALPHApix;
                        Ibuffer_r[indexI]=Ibuffer_r[indexI]+(color_r[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_g[indexI]=Ibuffer_g[indexI]+(color_g[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_b[indexI]=Ibuffer_b[indexI]+(color_b[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
            }
        }
    break;
    
    case 6: //xyz
        for (z=(Iin_sizez-1); z>=0; z--)
        {
            // Offset calculation
            xd=(-Ibuffer_sizex/2)+Mshear[8]*(z-Iin_sizez/2)+Iin_sizex/2;    
            yd=(-Ibuffer_sizey/2)+Mshear[9]*(z-Iin_sizez/2)+Iin_sizey/2; 
            xdfloor=(int)floor(xd); ydfloor=(int)floor(yd);
            
            // Linear interpolation constants (percentages)
            xCom=xd-floor(xd);  yCom=yd-floor(yd);
            perc[0]=(1-xCom) * (1-yCom); perc[1]=(1-xCom) * yCom;
            perc[2]=xCom * (1-yCom); perc[3]=xCom * yCom;
            
            // Calculate the coordinates on which a image slice starts and 
            // ends in the temporary shear image (buffer)
            pystart=-ydfloor; if(pystart<0) {pystart=0; }
            pyend=Iin_sizey-ydfloor; if(pyend>Ibuffer_sizey) {pyend=Ibuffer_sizey; }
            pxstart=-xdfloor; if(pxstart<0) {pxstart=0; }
            pxend=Iin_sizex-xdfloor; if(pxend>Ibuffer_sizex) {pxend=Ibuffer_sizex; }
            for (py=pystart; py<pyend-1; py++)
            {
                // Determine y coordinates of pixel(s) which will be come current pixel
                yBas[0]=py+ydfloor; yBas[1]=yBas[0]+1;
                for (px=pxstart; px<pxend-1; px++)
                {
                    // Calculate index of current pixel
                    indexI=px+py*Ibuffer_sizex;
                    if(ALPHAbuffer[indexI]<0.95)
                    {                    
                        // Determine x coordinates of pixel(s) which will be come current pixel
                        xBas[0]=px+xdfloor; xBas[1]=xBas[0]+1;    

                        // Get the intensities
                        intensity_xyz[0]=getcolor(xBas[0], yBas[0], z, Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                        intensity_xyz[1]=getcolor(xBas[0], yBas[1], z, Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                        intensity_xyz[2]=getcolor(xBas[1], yBas[0], z, Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                        intensity_xyz[3]=getcolor(xBas[1], yBas[1], z, Iin_sizex, Iin_sizey, Iin_sizez,Iin); 

                        // Calculate the interpolated intensity
                        intensity_loc=intensity_xyz[0]*perc[0]+intensity_xyz[1]*perc[1]+intensity_xyz[2]*perc[2]+intensity_xyz[3]*perc[3];

                        // Calculate index in alpha transparency look up table
                        indexAlpha=(int)(intensity_loc*sizealpha_d);

                        // Calculate index in color transparency look up table
                        indexColor=(int)(intensity_loc*sizecolor_d);

                        // Calculate index in alpha transparency look up table
                        indexAlpha=(int)(intensity_loc*sizealpha_d);
                        // Calculate index in color transparency look up table
                        indexColor=(int)(intensity_loc*sizecolor_d);
                        // Update the current pixel in the shear image buffer
                        calculate_shading(xBas[0], yBas[0], z, Iin_sizex, Iin_sizey, Iin_sizez, Iin, Mview, material,Ipar,L,V);
                        ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                        ALPHAbuffer[indexI]+=ALPHApix;
                        Ibuffer_r[indexI]=Ibuffer_r[indexI]+(color_r[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_g[indexI]=Ibuffer_g[indexI]+(color_g[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_b[indexI]=Ibuffer_b[indexI]+(color_b[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                    }
                }
            }


            // Process edges
            px=pxend-1;
            xBas[0]=px+xdfloor; 
            for (py=pystart; py<pyend-1; py++)
            {
                // Calculate index of current pixel
                indexI=px+py*Ibuffer_sizex;
                if(ALPHAbuffer[indexI]<0.95)
                {
                    yBas[0]=py+ydfloor; yBas[1]=yBas[0]+1;
                    intensity_xyz[0]=getcolor(xBas[0], yBas[0], z, Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                    intensity_xyz[1]=getcolor(xBas[0], yBas[1], z, Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                    intensity_loc=intensity_xyz[0]*(perc[0]+perc[2])+intensity_xyz[1]*(perc[1]+perc[3]);
                    // Calculate index in alpha transparency look up table
                    indexAlpha=(int)(intensity_loc*sizealpha_d);
                    // Calculate index in color transparency look up table
                    indexColor=(int)(intensity_loc*sizecolor_d);
                        // Update the current pixel in the shear image buffer
                        calculate_shading(xBas[0], yBas[0], z, Iin_sizex, Iin_sizey, Iin_sizez, Iin, Mview, material,Ipar,L,V);
                        ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                        ALPHAbuffer[indexI]+=ALPHApix;
                        Ibuffer_r[indexI]=Ibuffer_r[indexI]+(color_r[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_g[indexI]=Ibuffer_g[indexI]+(color_g[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_b[indexI]=Ibuffer_b[indexI]+(color_b[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                }
            }
            py=pyend-1;
            yBas[0]=py+ydfloor; 
            for (px=pxstart; px<pxend-1; px++)
            {
                // Calculate index of current pixel
                indexI=px+py*Ibuffer_sizex;
                if(ALPHAbuffer[indexI]<0.95)
                {
                    xBas[0]=px+xdfloor; xBas[1]=xBas[0]+1;
                    intensity_xyz[0]=getcolor(xBas[0], yBas[0], z, Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                    intensity_xyz[2]=getcolor(xBas[1], yBas[0], z, Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                    intensity_loc=intensity_xyz[0]*(perc[0]+perc[1])+intensity_xyz[2]*(perc[2]+perc[3]);
                     // Calculate index in alpha transparency look up table
                    indexAlpha=(int)(intensity_loc*sizealpha_d);
                    // Calculate index in color transparency look up table
                    indexColor=(int)(intensity_loc*sizecolor_d);
                        // Update the current pixel in the shear image buffer
                        calculate_shading(xBas[0], yBas[0], z, Iin_sizex, Iin_sizey, Iin_sizez, Iin, Mview, material,Ipar,L,V);
                        ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                        ALPHAbuffer[indexI]+=ALPHApix;
                        Ibuffer_r[indexI]=Ibuffer_r[indexI]+(color_r[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_g[indexI]=Ibuffer_g[indexI]+(color_g[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_b[indexI]=Ibuffer_b[indexI]+(color_b[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                }
            }
            px=pxend-1; py=pyend-1;
            // Calculate index of current pixel
            indexI=px+py*Ibuffer_sizex;
            if(ALPHAbuffer[indexI]<0.95)
            {
                xBas[0]=px+xdfloor;  yBas[0]=py+ydfloor; 
                intensity_loc=getcolor(xBas[0], yBas[0], z, Iin_sizex, Iin_sizey, Iin_sizez,Iin);
                indexI=px+py*Ibuffer_sizex;
                 // Calculate index in alpha transparency look up table
                indexAlpha=(int)(intensity_loc*sizealpha_d);
                // Calculate index in color transparency look up table
                indexColor=(int)(intensity_loc*sizecolor_d);
                        // Update the current pixel in the shear image buffer
                        calculate_shading(xBas[0], yBas[0], z, Iin_sizex, Iin_sizey, Iin_sizez, Iin, Mview, material,Ipar,L,V);
                        ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                        ALPHAbuffer[indexI]+=ALPHApix;
                        Ibuffer_r[indexI]=Ibuffer_r[indexI]+(color_r[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_g[indexI]=Ibuffer_g[indexI]+(color_g[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
                        Ibuffer_b[indexI]=Ibuffer_b[indexI]+(color_b[indexColor]*(Ipar[0]+Ipar[1])+Ipar[2])*ALPHApix;
            }
        }
    break;
}


    transx=Mwarp2D[6]+Mshear[12]; 
    transy=Mwarp2D[7]+Mshear[13];

    // Warp (buffer) image from shear process to viewer (output) image
    for (py=0; py<Iout_sizey; py++)
    {
        for (px=0; px<Iout_sizex; px++)
        {
            pxreal=(px-Iout_sizex/2); 
            pyreal=(py-Iout_sizey/2);
            pxrealt=Mwarp2D[0]*pxreal+Mwarp2D[3]*pyreal+((double)Ibuffer_sizex)/2+transx; 
            pyrealt=Mwarp2D[1]*pxreal+Mwarp2D[4]*pyreal+((double)Ibuffer_sizey)/2+transy;
            
            // Determine the coordinates of the pixel(s) which will be come the current pixel
            // (using linear interpolation)  
            xBas[0]=(int)floor(pxrealt); yBas[0]=(int)floor(pyrealt);
            xBas[1]=xBas[0]+1;           yBas[1]=yBas[0]+1;

            // Linear interpolation constants (percentages)
            xCom=pxrealt-floor(pxrealt); yCom=pyrealt-floor(pyrealt);
            perc[0]=(1-xCom) * (1-yCom);
            perc[1]=(1-xCom) * yCom;
            perc[2]=xCom * (1-yCom);
            perc[3]=xCom * yCom;

            // Pixel index
            indexI=px+py*Iout_sizex;
            
            // Get the intensities
            intensity_xyz[0]=getcolor2(xBas[0], yBas[0], Ibuffer_sizex, Ibuffer_sizey, Ibuffer_r); 
            intensity_xyz[1]=getcolor2(xBas[0], yBas[1], Ibuffer_sizex, Ibuffer_sizey, Ibuffer_r); 
            intensity_xyz[2]=getcolor2(xBas[1], yBas[0], Ibuffer_sizex, Ibuffer_sizey, Ibuffer_r); 
            intensity_xyz[3]=getcolor2(xBas[1], yBas[1], Ibuffer_sizex, Ibuffer_sizey, Ibuffer_r); 
            intensity_loc=intensity_xyz[0]*perc[0]+intensity_xyz[1]*perc[1]+intensity_xyz[2]*perc[2]+intensity_xyz[3]*perc[3];
            // Range [0 1]
            if(intensity_loc>1){ intensity_loc=1;} if(intensity_loc<0){ intensity_loc=0;}
            Iout[indexI]=intensity_loc;
            
            indexI=px+py*Iout_sizex+Iout_sizex*Iout_sizey;
            // Get the intensities
            intensity_xyz[0]=getcolor2(xBas[0], yBas[0], Ibuffer_sizex, Ibuffer_sizey, Ibuffer_g); 
            intensity_xyz[1]=getcolor2(xBas[0], yBas[1], Ibuffer_sizex, Ibuffer_sizey, Ibuffer_g); 
            intensity_xyz[2]=getcolor2(xBas[1], yBas[0], Ibuffer_sizex, Ibuffer_sizey, Ibuffer_g); 
            intensity_xyz[3]=getcolor2(xBas[1], yBas[1], Ibuffer_sizex, Ibuffer_sizey, Ibuffer_g); 
            intensity_loc=intensity_xyz[0]*perc[0]+intensity_xyz[1]*perc[1]+intensity_xyz[2]*perc[2]+intensity_xyz[3]*perc[3];
            // Range [0 1]
            if(intensity_loc>1){ intensity_loc=1;} if(intensity_loc<0){ intensity_loc=0;}
            Iout[indexI]=intensity_loc;
                 
            indexI=px+py*Iout_sizex+2*Iout_sizex*Iout_sizey;
            // Get the intensities
            intensity_xyz[0]=getcolor2(xBas[0], yBas[0], Ibuffer_sizex, Ibuffer_sizey, Ibuffer_b); 
            intensity_xyz[1]=getcolor2(xBas[0], yBas[1], Ibuffer_sizex, Ibuffer_sizey, Ibuffer_b); 
            intensity_xyz[2]=getcolor2(xBas[1], yBas[0], Ibuffer_sizex, Ibuffer_sizey, Ibuffer_b); 
            intensity_xyz[3]=getcolor2(xBas[1], yBas[1], Ibuffer_sizex, Ibuffer_sizey, Ibuffer_b); 
            intensity_loc=intensity_xyz[0]*perc[0]+intensity_xyz[1]*perc[1]+intensity_xyz[2]*perc[2]+intensity_xyz[3]*perc[3];
            // Range [0 1]
            if(intensity_loc>1){ intensity_loc=1;} if(intensity_loc<0){ intensity_loc=0;}
            Iout[indexI]=intensity_loc;

        }
    }
}   

