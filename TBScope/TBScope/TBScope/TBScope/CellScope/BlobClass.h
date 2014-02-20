#ifndef BLOBCLASS_H
#define BLOBCLASS_H

#include "Globals.h"
namespace BlobClass
{
	/**
		Cross correlates the given matrix with a generated gaussian kernel
 
		@param matrix The matrix to cross correlate with a generated gaussian kernel
		@return       The matrix after having been cross-correlized
	 */
	cv::Mat crossCorrelateWithGaussian(cv::Mat matrix);

	/**
		Identifies blobs in the given image.
    
		@param image The image to identify blobs in
		@return      The image (grayscale) with only blobs
	 */
	cv::Mat blobIdentification(cv::Mat image, std::string debugPath);
}
#endif