#include "mex.h"
#include "math.h"

/*  This function warp,  will warp the shear rendered
 *  buffer image
 * 
 *  J =warp(Ibuffer,sizes,Mshear,Mwarp2D,c);
 *
 *  Function is written by D.Kroon University of Twente ( November 2008)
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

// The matlab mex function
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    // I is the input image, J the transformed image
    // Tx and Ty images of the translation of every pixel.
    double *Iout, *Ibuffer, *sizes, *Mshear, *Mwarp2D, *cd;
    double *Ibuffer_r,*Ibuffer_g,*Ibuffer_b;

    // index storage
    int indexI;
    
    // Rotate x,y,z variable
    int c=0;
    
    double transx=0; 
    double transy=0;
    // Loop variables (position)
    int px, py;
    
    // Warp positions
    double pxreal,pyreal;
    double pxrealt,pyrealt;

    // intensity of pixel
    double intensity_loc;
            
    // Size of input 
    const mwSize *dims;
    mwSize ndims;
    
    mwSize  Ibuffer_sizex, Ibuffer_sizey;
    
    // Size of output image
    mwSize  Iout_sizex, Iout_sizey;
    mwSize  Iout_dims[3]={0,0,0};
  
        
    // interpolation variables;
    double perc[4]={0,0,0,0};
    double intensity_xyz[4]={0,0,0,0};
    int xBas[2]={0,0};
    int yBas[2]={0,0};
    double xCom, yCom;
        
    // Get the sizes of the input image(volume)   
    ndims=mxGetNumberOfDimensions(prhs[0]);
    dims = mxGetDimensions(prhs[0]);  
    Ibuffer_sizex= dims[0];  
    Ibuffer_sizey= dims[1]; 
    
    /* Assign pointers to each input. */
    Ibuffer=mxGetPr(prhs[0]);
    sizes=mxGetPr(prhs[1]);
    Mshear=mxGetPr(prhs[2]);
    Mwarp2D=mxGetPr(prhs[3]);
    cd=mxGetPr(prhs[4]);
    
    // set variable with main viewer direction (xyz or zyx or ...) 
    c=(int)cd[0];
    
    // Set sizes output image
    Iout_sizex=(mwSize)sizes[0]; Iout_sizey=(mwSize)sizes[1];
    
    // Create image matrix for the return arguments with the size of input image   
    Iout_dims[0]=Iout_sizex; 
    Iout_dims[1]=Iout_sizey;
    if(ndims==2) 
    { 
        Iout_dims[2]=1; 
    }
    else
    {
        Iout_dims[2]=3;
        Ibuffer_r=Ibuffer;
        Ibuffer_g=Ibuffer+Ibuffer_sizex*Ibuffer_sizey;
        Ibuffer_b=Ibuffer+2*(Ibuffer_sizex*Ibuffer_sizey);
    }
    plhs[0] = mxCreateNumericArray(3, Iout_dims, mxDOUBLE_CLASS, mxREAL); 

    
    /* Assign pointer to output image. */
    Iout = mxGetPr(plhs[0]);
    
    transx=Mwarp2D[6]+Mshear[12]; 
    transy=Mwarp2D[7]+Mshear[13];

    // Warp (buffer) image from shear process to viewer (output) image
    if(ndims==2) 
    { 
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

                // Get the intensities
                intensity_xyz[0]=getcolor2(xBas[0], yBas[0], Ibuffer_sizex, Ibuffer_sizey, Ibuffer); 
                intensity_xyz[1]=getcolor2(xBas[0], yBas[1], Ibuffer_sizex, Ibuffer_sizey, Ibuffer); 
                intensity_xyz[2]=getcolor2(xBas[1], yBas[0], Ibuffer_sizex, Ibuffer_sizey, Ibuffer); 
                intensity_xyz[3]=getcolor2(xBas[1], yBas[1], Ibuffer_sizex, Ibuffer_sizey, Ibuffer); 

                // Linear interpolation constants (percentages)
                xCom=pxrealt-floor(pxrealt); yCom=pyrealt-floor(pyrealt);
                perc[0]=(1-xCom) * (1-yCom);
                perc[1]=(1-xCom) * yCom;
                perc[2]=xCom * (1-yCom);
                perc[3]=xCom * yCom;
                
                intensity_loc=intensity_xyz[0]*perc[0]+intensity_xyz[1]*perc[1]+intensity_xyz[2]*perc[2]+intensity_xyz[3]*perc[3];
                // Range [0 1]
                if(intensity_loc>1){ intensity_loc=1;} if(intensity_loc<0){ intensity_loc=0;}

                // Set the new pixel
                indexI=px+py*Iout_sizex;
                Iout[indexI]=intensity_loc;
            }
        }
    }   
    else
    {
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
}
