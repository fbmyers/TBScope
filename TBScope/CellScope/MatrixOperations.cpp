#include "MatrixOperations.h"
#include "opencv2/highgui/highgui.hpp"
#include <stdexcept>

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

  template <typename TDataType>
  std::vector<cv::Point2d> findWeightedCentroidsImpl(const ContourContainerType &contours, const cv::Mat &thresholdImage, const cv::Mat &originalImage) {
    std::vector<cv::Point2d> pts;

    for (int i = 0; i < contours.size(); i++) {
      cv::Mat filledImage = cv::Mat::zeros(thresholdImage.rows, thresholdImage.cols, CV_8UC1);
      const cv::Scalar color = cv::Scalar(255, 255, 255);
			cv::drawContours(filledImage, contours, i, color, -1);

			double sumRegion = 0;
			double weightedXSum = 0;
			double weightedYSum = 0;
			int pixelCount = 0;

      const ContourType &ct = contours[i];
      int min_x = filledImage.cols;
      int max_x = 0;
      int min_y = filledImage.rows;
      int max_y = 0;
      for (const auto &pt : ct) {
        min_x = std::min(min_x, pt.x);
        max_x = std::max(max_x, pt.x);
        min_y = std::min(min_y, pt.y);
        max_y = std::max(max_y, pt.y);
      }

			for (int j = min_y; j < max_y; j++) {
				for (int k = min_x; k < max_x; k++) {
					int val = filledImage.at<uchar>(j, k);
					if (val != 0) {
						const double original_val = static_cast<double>(originalImage.at<TDataType>(j, k));
            ++pixelCount;
						sumRegion += original_val;
					  weightedXSum += (static_cast<double>(j) * original_val);
						weightedYSum += (static_cast<double>(k) * original_val);
					}
				}
			}

			double xbar = weightedXSum / sumRegion;
			double ybar = weightedYSum / sumRegion;
			pts.emplace_back(xbar, ybar);
    }
    return std::move(pts);
  }

  std::vector<cv::Point2d> findWeightedCentroids(const ContourContainerType &contours, const cv::Mat &thresholdImage, const cv::Mat &originalImage) {
    switch (originalImage.type()) {
      case CV_8UC1: {
        return std::move(findWeightedCentroidsImpl<uchar>(contours, thresholdImage, originalImage));
      }
      case CV_64F: {
        return std::move(findWeightedCentroidsImpl<double>(contours, thresholdImage, originalImage));
      }
      case CV_32F: {
        return std::move(findWeightedCentroidsImpl<float>(contours, thresholdImage, originalImage));
      }
      default: {
        throw std::logic_error("Unimplemented image type");
      }
    }
  }
}