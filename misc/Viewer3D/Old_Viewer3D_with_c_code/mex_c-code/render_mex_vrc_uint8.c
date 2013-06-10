#include "mex.h"
#include "math.h"

/*  This function shear_vol, will calculate a volumerendered image
 *  using the shearwarp algorithm
 * 
 *  J = render_mex_vrc(I,sizes,Mshear,Mwarp2D,c,alphatable,colortable);
 *
 *  Function is written by D.Kroon University of Twente (October 2008)
 */

typedef unsigned char uint8_t;

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
double getcolor(int x, int y, int z, int sizx, int sizy, int sizz, uint8_t *I) 
{
    return ((double)I[x+y*sizx+z*sizy*sizx])/255;
}

// The matlab mex function
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    // I is the input image, J the transformed image
    // Tx and Ty images of the translation of every pixel.
    double *Iout, *Ibuffer_r,*Ibuffer_g,*Ibuffer_b, *ALPHAbuffer;
    uint8_t *Iin;

    double *sizes, *Mshear, *Mwarp2D, *cd, *alpha, *alpha_m, *color;
    double *color_r, *color_g, *color_b;
    // index storage
    int indexI;
    
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
    Iin=(uint8_t*)mxGetData(prhs[0]);
    sizes=mxGetPr(prhs[1]);
    Mshear=mxGetPr(prhs[2]);
    Mwarp2D=mxGetPr(prhs[3]);
    cd=mxGetPr(prhs[4]);
    alpha_m=mxGetPr(prhs[5]);
    color=mxGetPr(prhs[6]);
    
    // Get the size of the input Color table
//     color_r=(double *)malloc(5* sizeof(double)); 
//     color_g=(double *)malloc(5* sizeof(double)); 
//     color_b=(double *)malloc(5* sizeof(double)); 
//     color_r[0]=0; color_g[0]=1; color_b[0]=1;
//     color_r[1]=0.2; color_g[1]=0.2; color_b[1]=0.2;
//     color_r[2]=0.5; color_g[2]=0.5; color_b[2]=0.5;
//     color_r[3]=0.7; color_g[3]=0.7; color_b[3]=0.7;
//     color_r[4]=1.0; color_g[4]=1.0; color_b[4]=1.0;
//     sizecolor_d=4;          
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
                        ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                        ALPHAbuffer[indexI]+=ALPHApix;
                        Ibuffer_r[indexI]=Ibuffer_r[indexI]+color_r[indexColor]*ALPHApix;
                        Ibuffer_g[indexI]=Ibuffer_g[indexI]+color_g[indexColor]*ALPHApix;
                        Ibuffer_b[indexI]=Ibuffer_b[indexI]+color_b[indexColor]*ALPHApix;
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
                ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                ALPHAbuffer[indexI]+=ALPHApix;
                Ibuffer_r[indexI]=Ibuffer_r[indexI]+color_r[indexColor]*ALPHApix;
                Ibuffer_g[indexI]=Ibuffer_g[indexI]+color_g[indexColor]*ALPHApix;
                Ibuffer_b[indexI]=Ibuffer_b[indexI]+color_b[indexColor]*ALPHApix;
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
                    ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                    ALPHAbuffer[indexI]+=ALPHApix;
                    Ibuffer_r[indexI]=Ibuffer_r[indexI]+color_r[indexColor]*ALPHApix;
                    Ibuffer_g[indexI]=Ibuffer_g[indexI]+color_g[indexColor]*ALPHApix;
                    Ibuffer_b[indexI]=Ibuffer_b[indexI]+color_b[indexColor]*ALPHApix;
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
                ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                ALPHAbuffer[indexI]+=ALPHApix;
                Ibuffer_r[indexI]=Ibuffer_r[indexI]+color_r[indexColor]*ALPHApix;
                Ibuffer_g[indexI]=Ibuffer_g[indexI]+color_g[indexColor]*ALPHApix;
                Ibuffer_b[indexI]=Ibuffer_b[indexI]+color_b[indexColor]*ALPHApix;
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
                        ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                        ALPHAbuffer[indexI]+=ALPHApix;
                        Ibuffer_r[indexI]=Ibuffer_r[indexI]+color_r[indexColor]*ALPHApix;
                        Ibuffer_g[indexI]=Ibuffer_g[indexI]+color_g[indexColor]*ALPHApix;
                        Ibuffer_b[indexI]=Ibuffer_b[indexI]+color_b[indexColor]*ALPHApix;
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
                    ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                    ALPHAbuffer[indexI]+=ALPHApix;
                    Ibuffer_r[indexI]=Ibuffer_r[indexI]+color_r[indexColor]*ALPHApix;
                    Ibuffer_g[indexI]=Ibuffer_g[indexI]+color_g[indexColor]*ALPHApix;
                    Ibuffer_b[indexI]=Ibuffer_b[indexI]+color_b[indexColor]*ALPHApix;
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
                    ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                    ALPHAbuffer[indexI]+=ALPHApix;
                    Ibuffer_r[indexI]=Ibuffer_r[indexI]+color_r[indexColor]*ALPHApix;
                    Ibuffer_g[indexI]=Ibuffer_g[indexI]+color_g[indexColor]*ALPHApix;
                    Ibuffer_b[indexI]=Ibuffer_b[indexI]+color_b[indexColor]*ALPHApix;
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
                ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                ALPHAbuffer[indexI]+=ALPHApix;
                Ibuffer_r[indexI]=Ibuffer_r[indexI]+color_r[indexColor]*ALPHApix;
                Ibuffer_g[indexI]=Ibuffer_g[indexI]+color_g[indexColor]*ALPHApix;
                Ibuffer_b[indexI]=Ibuffer_b[indexI]+color_b[indexColor]*ALPHApix;
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
                        ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                        ALPHAbuffer[indexI]+=ALPHApix;
                        Ibuffer_r[indexI]=Ibuffer_r[indexI]+color_r[indexColor]*ALPHApix;
                        Ibuffer_g[indexI]=Ibuffer_g[indexI]+color_g[indexColor]*ALPHApix;
                        Ibuffer_b[indexI]=Ibuffer_b[indexI]+color_b[indexColor]*ALPHApix;
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
                    ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                    ALPHAbuffer[indexI]+=ALPHApix;
                    Ibuffer_r[indexI]=Ibuffer_r[indexI]+color_r[indexColor]*ALPHApix;
                    Ibuffer_g[indexI]=Ibuffer_g[indexI]+color_g[indexColor]*ALPHApix;
                    Ibuffer_b[indexI]=Ibuffer_b[indexI]+color_b[indexColor]*ALPHApix;
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
                    ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                    ALPHAbuffer[indexI]+=ALPHApix;
                    Ibuffer_r[indexI]=Ibuffer_r[indexI]+color_r[indexColor]*ALPHApix;
                    Ibuffer_g[indexI]=Ibuffer_g[indexI]+color_g[indexColor]*ALPHApix;
                    Ibuffer_b[indexI]=Ibuffer_b[indexI]+color_b[indexColor]*ALPHApix;
                }
            }
            px=pxend-1; py=pyend-1;
            // Calculate index of current pixel
            indexI=px+py*Ibuffer_sizex;
            if(ALPHAbuffer[indexI]<0.95)
            {
                xBas[0]=px+xdfloor;  yBas[0]=py+ydfloor; 
                intensity_loc=getcolor(xBas[0], yBas[0], z, Iin_sizex, Iin_sizey, Iin_sizez,Iin); 
                // Calculate index in alpha transparency look up table
                indexAlpha=(int)(intensity_loc*sizealpha_d);
                // Calculate index in color transparency look up table
                indexColor=(int)(intensity_loc*sizecolor_d);
                // Update the current pixel in the shear image buffer
                ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                ALPHAbuffer[indexI]+=ALPHApix;
                Ibuffer_r[indexI]=Ibuffer_r[indexI]+color_r[indexColor]*ALPHApix;
                Ibuffer_g[indexI]=Ibuffer_g[indexI]+color_g[indexColor]*ALPHApix;
                Ibuffer_b[indexI]=Ibuffer_b[indexI]+color_b[indexColor]*ALPHApix;
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
                        ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                        ALPHAbuffer[indexI]+=ALPHApix;
                        Ibuffer_r[indexI]=Ibuffer_r[indexI]+color_r[indexColor]*ALPHApix;
                        Ibuffer_g[indexI]=Ibuffer_g[indexI]+color_g[indexColor]*ALPHApix;
                        Ibuffer_b[indexI]=Ibuffer_b[indexI]+color_b[indexColor]*ALPHApix;
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
                    ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                    ALPHAbuffer[indexI]+=ALPHApix;
                    Ibuffer_r[indexI]=Ibuffer_r[indexI]+color_r[indexColor]*ALPHApix;
                    Ibuffer_g[indexI]=Ibuffer_g[indexI]+color_g[indexColor]*ALPHApix;
                    Ibuffer_b[indexI]=Ibuffer_b[indexI]+color_b[indexColor]*ALPHApix;
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
                    ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                    ALPHAbuffer[indexI]+=ALPHApix;
                    Ibuffer_r[indexI]=Ibuffer_r[indexI]+color_r[indexColor]*ALPHApix;
                    Ibuffer_g[indexI]=Ibuffer_g[indexI]+color_g[indexColor]*ALPHApix;
                    Ibuffer_b[indexI]=Ibuffer_b[indexI]+color_b[indexColor]*ALPHApix;
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
                ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                ALPHAbuffer[indexI]+=ALPHApix;
                Ibuffer_r[indexI]=Ibuffer_r[indexI]+color_r[indexColor]*ALPHApix;
                Ibuffer_g[indexI]=Ibuffer_g[indexI]+color_g[indexColor]*ALPHApix;
                Ibuffer_b[indexI]=Ibuffer_b[indexI]+color_b[indexColor]*ALPHApix;
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
                        ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                        ALPHAbuffer[indexI]+=ALPHApix;
                        Ibuffer_r[indexI]=Ibuffer_r[indexI]+color_r[indexColor]*ALPHApix;
                        Ibuffer_g[indexI]=Ibuffer_g[indexI]+color_g[indexColor]*ALPHApix;
                        Ibuffer_b[indexI]=Ibuffer_b[indexI]+color_b[indexColor]*ALPHApix;
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
                    ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                    ALPHAbuffer[indexI]+=ALPHApix;
                    Ibuffer_r[indexI]=Ibuffer_r[indexI]+color_r[indexColor]*ALPHApix;
                    Ibuffer_g[indexI]=Ibuffer_g[indexI]+color_g[indexColor]*ALPHApix;
                    Ibuffer_b[indexI]=Ibuffer_b[indexI]+color_b[indexColor]*ALPHApix;
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
                    ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                    ALPHAbuffer[indexI]+=ALPHApix;
                    Ibuffer_r[indexI]=Ibuffer_r[indexI]+color_r[indexColor]*ALPHApix;
                    Ibuffer_g[indexI]=Ibuffer_g[indexI]+color_g[indexColor]*ALPHApix;
                    Ibuffer_b[indexI]=Ibuffer_b[indexI]+color_b[indexColor]*ALPHApix;
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
                ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                ALPHAbuffer[indexI]+=ALPHApix;
                Ibuffer_r[indexI]=Ibuffer_r[indexI]+color_r[indexColor]*ALPHApix;
                Ibuffer_g[indexI]=Ibuffer_g[indexI]+color_g[indexColor]*ALPHApix;
                Ibuffer_b[indexI]=Ibuffer_b[indexI]+color_b[indexColor]*ALPHApix;
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
                        ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                        ALPHAbuffer[indexI]+=ALPHApix;
                        Ibuffer_r[indexI]=Ibuffer_r[indexI]+color_r[indexColor]*ALPHApix;
                        Ibuffer_g[indexI]=Ibuffer_g[indexI]+color_g[indexColor]*ALPHApix;
                        Ibuffer_b[indexI]=Ibuffer_b[indexI]+color_b[indexColor]*ALPHApix;
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
                    ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                    ALPHAbuffer[indexI]+=ALPHApix;
                    Ibuffer_r[indexI]=Ibuffer_r[indexI]+color_r[indexColor]*ALPHApix;
                    Ibuffer_g[indexI]=Ibuffer_g[indexI]+color_g[indexColor]*ALPHApix;
                    Ibuffer_b[indexI]=Ibuffer_b[indexI]+color_b[indexColor]*ALPHApix;
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
                    ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                    ALPHAbuffer[indexI]+=ALPHApix;
                    Ibuffer_r[indexI]=Ibuffer_r[indexI]+color_r[indexColor]*ALPHApix;
                    Ibuffer_g[indexI]=Ibuffer_g[indexI]+color_g[indexColor]*ALPHApix;
                    Ibuffer_b[indexI]=Ibuffer_b[indexI]+color_b[indexColor]*ALPHApix;
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
                ALPHApix = (1-ALPHAbuffer[indexI])*alpha[indexAlpha];
                ALPHAbuffer[indexI]+=ALPHApix;
                Ibuffer_r[indexI]=Ibuffer_r[indexI]+color_r[indexColor]*ALPHApix;
                Ibuffer_g[indexI]=Ibuffer_g[indexI]+color_g[indexColor]*ALPHApix;
                Ibuffer_b[indexI]=Ibuffer_b[indexI]+color_b[indexColor]*ALPHApix;
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

