#ifndef MATRIXOPERATIONS_H
#define MATRIXOPERATIONS_H

#include "Globals.h"


namespace MatrixOperations
{
	/**
		A replication of the (matrix) > (val) function in matLab.
		For the given matrix, if the value is > val, returns 1. Else, returns 0.
		Returns a new matrix.
 
		@param compareVal The value to compare matrix values against
		@param mat        The matrix to compare values from
		@return           Returns a copy of |mat|, with all values > val as 1 and all values <= val as 0.
	 */
	cv::Mat greaterThanValue(float compareVal, cv::Mat mat);
    
    std::vector<cv::Point2d> findWeightedCentroids(const ContourContainerType contours, const cv::Mat thresholdImage, const cv::Mat originalImage);
}
#endif