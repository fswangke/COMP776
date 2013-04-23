/*
 * build smooth term
 */

#include "mex.h"
#include <math.h>

double color_distance(double r1, double g1, double b1, double r2, double g2, double b2)
{
    return (r1 - r2) * (r1 - r2) + (g1 - g2) * (g1 - g2) + (b1 - b2) * (b1 - b2);
}

unsigned int index(unsigned row, unsigned col, unsigned height)
{
    return col + ( row ) * height;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    double * pixels; /* N * 3 matrices, column major */
    double * pairwise; /* output sparse matrices*/
    mwSize height;
    mwSize width;
    mwIndex row = 0;
    mwIndex col = 0;

	mwIndex idx_center = 0;
	mwIndex idx_neighbor = 0;
    mwIndex sparse_count = 0;
    
    double result = 0;
    double beta = 0;
    double a = 0;
    int edges = 0;
    double * R = 0;
    double * G = 0;
    double * B = 0;
	mwIndex *ir, *jc;
    
    if ( nrhs != 3)
        mexErrMsgTxt("Usage: buildsmooth(pixels, height, width)");
    else if ( nlhs > 1 )
        mexErrMsgTxt("Too many output arguments.");
    
    height = mxGetScalar(prhs[1]);
    width  = mxGetScalar(prhs[2]);
    
    pixels = mxGetPr(prhs[0]);
    plhs[0] = mxCreateSparse(height * width, height * width, height * width * 4, mxREAL); 
    pairwise = mxGetPr(plhs[0]);
	ir = mxGetIr(plhs[0]);
	jc = mxGetJc(plhs[0]);

    R = pixels + height * width * 0;
    G = pixels + height * width * 1;
    B = pixels + height * width * 2;
    for ( row = 0; row < height; ++row)
    {
        for ( col = 0; col < width; ++ col)
        {
            idx_center = row + col * height;
            if ( row > 0 ) // up
            {
                idx_neighbor = ( row - 1 ) + ( col ) * height;
                result += color_distance(R[idx_center], G[idx_center], B[idx_center], R[idx_neighbor], G[idx_neighbor], B[idx_neighbor]);
                edges ++;
            }
            
            if ( col > 0 ) // left
            {
                idx_neighbor = ( row ) + ( col - 1 ) * height;
                result += color_distance(R[idx_center], G[idx_center], B[idx_center], R[idx_neighbor], G[idx_neighbor], B[idx_neighbor]);
                edges ++;
            }
        }
    }
    beta = (double)1.0/(2 * result / edges);

	// compute pairwise Nlinks
	// graph is symmetric, so only up and left is necessary
	// sparse matrices in MATLAB is stored via compressed column storage
	for (idx_center = 0; idx_center < height * width; idx_center++)
	{
        row = idx_center % height;
        col = idx_center / height;

		jc[idx_center] = sparse_count;

		if ( col > 0 ) // left
		{
			idx_neighbor = ( row ) + ( col - 1 ) * height;
            pairwise[sparse_count] = a = 50 * exp(-beta * color_distance(R[idx_center], G[idx_center], B[idx_center], R[idx_neighbor], G[idx_neighbor], B[idx_neighbor]));
            ir[sparse_count] = idx_neighbor;
            sparse_count++;
		}

        if ( row > 0 ) // up
		{
			idx_neighbor = ( row - 1 ) + ( col ) * height;
            pairwise[sparse_count] = a = 50 * exp(-beta * color_distance(R[idx_center], G[idx_center], B[idx_center], R[idx_neighbor], G[idx_neighbor], B[idx_neighbor]));
            ir[sparse_count] = idx_neighbor;
            sparse_count++;
		}
        
        if ( row < height - 1 ) // bottom
        {
            idx_neighbor = ( row + 1 ) + ( col ) * height;
            pairwise[sparse_count] = a = 50 * exp(-beta * color_distance(R[idx_center], G[idx_center], B[idx_center], R[idx_neighbor], G[idx_neighbor], B[idx_neighbor]));
            ir[sparse_count] = idx_neighbor;
            sparse_count++;
        }

        if ( col < width - 1 )
        {
            idx_neighbor = ( row ) + ( col + 1 ) * height;
            pairwise[sparse_count] = a = 50 * exp(-beta * color_distance(R[idx_center], G[idx_center], B[idx_center], R[idx_neighbor], G[idx_neighbor], B[idx_neighbor]));
            ir[sparse_count] = idx_neighbor;
            sparse_count++;
        }
	}
	//jc[height*width+1] = height*width;
}