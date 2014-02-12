#ifndef IMAGETOOLS_H
#define IMAGETOOLS_H

#include "Globals.h"
namespace ImageTools 
{
	/**
		Splits an image into the appropriate channels, and returns the red channel. Assumes a 3-channel RGB image.
 
		@param image The original image
		@return      Returns the red channel (or channel 0) for this image.
	 */
	cv::Mat getRedChannel(cv::Mat image);

	/**
		Normalizes the image to have intensities between 0-1.
 
		@param image The original image
		@return      Returns the normalized image, with intensities between 0-1.
	 */
	cv::Mat normalizeImage(cv::Mat image);
}
#endif