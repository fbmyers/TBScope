#include "MatrixOperations.h"
#include "opencv2/highgui/highgui.hpp"

namespace MatrixOperations
{
	cv::Mat greaterThanValue(float compareVal, cv::Mat mat) 
	{
		cv::Mat parsedMatrix = cv::Mat(mat.rows, mat.cols, mat.type());
    
		for (int i = 0; i < mat.rows; i++) {
			for (int j = 0; j < mat.cols; j++) {
				if (mat.type() == CV_32F) {
					float val = mat.at<float>(i, j);
					float newVal = val > compareVal ? (float)1.0 : (float)0.0;
					parsedMatrix.at<float>(i, j) = newVal;
				} else if (mat.type() == CV_64F) {
					double val = mat.at<double>(i, j);
					double newVal = val > compareVal ? 1 : 0;
					parsedMatrix.at<double>(i, j) = newVal;
				} else if (mat.type() == CV_8UC1) {
					int val = (int)mat.at<uchar>(i, j);
					int newVal = val > compareVal ? 1 : 0;
					parsedMatrix.at<int>(i, j) = newVal;
				} 
			}
		}
    
		return parsedMatrix;
	}
    
    std::vector<cv::Point2d> findWeightedCentroids(const ContourContainerType contours, const cv::Mat thresholdImage, const cv::Mat originalImage)
    {
        std::vector<cv::Point2d> pts;

        for (int i = 0; i < contours.size(); i++)
        {
            cv::Mat filledImage = cv::Mat::zeros(thresholdImage.rows, thresholdImage.cols, CV_8UC1);
            cv::Scalar color = cv::Scalar(255, 255, 255);
			cv::drawContours(filledImage, contours, i, color, -1);

			double sumRegion = 0;
			double weightedXSum = 0;
			double weightedYSum = 0;
			int pixelCount = 0;

			for (int j = 0; j < filledImage.rows; j++)
			{
				for (int k = 0; k < filledImage.cols; k++)
				{
					int val = filledImage.at<uchar>(j, k);
					if (val != 0)
					{
						double original_val = 0;
						if (originalImage.type() == CV_8UC1) {
							original_val = (double)originalImage.at<uchar>(j, k);
						} else if (originalImage.type() == CV_64F) {
							original_val = originalImage.at<double>(j,k);
						} else if (originalImage.type() == CV_32F) {
							original_val = (double)originalImage.at<float>(j, k);
						}

						pixelCount++;
						sumRegion += original_val;
					    weightedXSum += ((double)j * original_val);
						weightedYSum += ((double)k * original_val);
					}
				}
			}

			double xbar = weightedXSum / sumRegion;
			double ybar = weightedYSum / sumRegion;
			cv::Point2d new_pt = cv::Point2d(xbar, ybar);
			pts.push_back(new_pt);
        }
        
        
        return pts;
    }
}