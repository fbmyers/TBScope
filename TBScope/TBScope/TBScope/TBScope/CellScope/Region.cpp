#include "Region.h"
#include <opencv2/imgproc/imgproc.hpp>
using namespace cv;


namespace Region
{
	std::map<const char*, float> getProperties(const ContourContainerType contours, const Mat img, const Mat orig)
	{
		std::map<const char*, float> regionProperties;
		ContourType contour = contours[0];
		int contour_index = 0;
		for (int i = 0; i < contours.size(); i++) {
			ContourType tmp = contours[i];
			if (tmp.size() > contour.size()) {
				contour = tmp;
				contour_index = i;
			}
		}

    
		// Create the filled image
		Mat filledImage = Mat::zeros(img.rows, img.cols, CV_8UC1);
		drawContours(filledImage, contours, contour_index, 255, -1);

		// area, mean, min, and max intensities
		float area = cv::countNonZero(filledImage);
		float minIntensity = 1E6;
		float maxIntensity = 0;
		float meanIntensity = 0;
		for (int i = 0; i < filledImage.rows; i++) {
		  for (int j = 0; j < filledImage.cols; j++) {
		    int val = filledImage.at<unsigned char>(i, j);
			if (val != 0) {
				float val = orig.at<float>(i, j);
				if (val < minIntensity) {
					minIntensity = val;
				} 
				if (val > maxIntensity) {
					maxIntensity = val;
				}
				meanIntensity += val;
			}
		  }
		}
		meanIntensity = meanIntensity / area; 

		//  convex area
		vector<vector<cv::Point> >hull( contours.size() );
		for( int i = 0; i < contours.size(); i++ )
		{  convexHull( Mat(contours[i]), hull[i], false ); }

	
		Mat convex_image = Mat::zeros(img.rows, img.cols, CV_8UC1);
		cv::drawContours(convex_image, hull, -1, 255, -1);
		float convex_area = cv::countNonZero(convex_image);


		// Equiv diameter, extent and solidity
		float solidity = area / convex_area;
		cv::Rect br = cv::boundingRect(contour);
		float equiv_diameter = (4 * area / M_PI);
		equiv_diameter = pow(equiv_diameter, 0.5f);
		float extent = area / br.area();
	
		// Euler number
		ContourContainerType twoLevel;
		cv::vector<Vec4i> hierarchy;
    
		int holes = 0;
		int total = 0;
		findContours(img.clone(), twoLevel, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_NONE);
		for (size_t i = 0; i < hierarchy.size(); i++) {
			Vec4i hierarchyVector = hierarchy.at(i);
			if (hierarchyVector[2] != -1) {
				holes++;
			}
			total++;
		}
		float eulerNumber = total - holes;
		
		// Ellipse
		float minorAxisLength;
		float majorAxisLength;
		float eccentricity;
		if (contour.size() < 5) {
			minorAxisLength = 0;
			majorAxisLength = 0;
			eccentricity = 0;		
		} else {
			cv::RotatedRect ellipse = cv::fitEllipse(contour);
    
			cv::Size2f sz = ellipse.size;
			if (sz.width <= sz.height) {
				minorAxisLength = sz.width;
				majorAxisLength = sz.height;
			} else {
				minorAxisLength = sz.height;
				majorAxisLength = sz.width;
			}
    
			double tmp = minorAxisLength / majorAxisLength;
			tmp = pow(tmp, 2);
			tmp = 1 - tmp;
			eccentricity = (float)pow(tmp, 0.5);
		}
		// Intensity
		
		// Perimeter and filled area 
		float perimeter = (float)cv::arcLength(contour, true);
		float filled_area = countNonZero(filledImage);

		regionProperties.insert(std::pair<const char*, float>("eulerNumber", eulerNumber));
		regionProperties.insert(std::pair<const char*, float>("area", area));
		regionProperties.insert(std::pair<const char*, float>("convexArea", convex_area));
		regionProperties.insert(std::pair<const char*, float>("eccentricity", eccentricity));
		regionProperties.insert(std::pair<const char*, float>("equivDiameter", equiv_diameter));
		regionProperties.insert(std::pair<const char*, float>("extent", extent));
		regionProperties.insert(std::pair<const char*, float>("filledArea", filled_area));
		regionProperties.insert(std::pair<const char*, float>("minorAxisLength", minorAxisLength));
		regionProperties.insert(std::pair<const char*, float>("majorAxisLength", majorAxisLength));
		regionProperties.insert(std::pair<const char*, float>("maxIntensity", maxIntensity));
		regionProperties.insert(std::pair<const char*, float>("minIntensity", minIntensity));
		regionProperties.insert(std::pair<const char*, float>("meanIntensity", meanIntensity));
		regionProperties.insert(std::pair<const char*, float>("perimeter", perimeter));
		regionProperties.insert(std::pair<const char*, float>("solidity", solidity));
        
		return regionProperties;
	}
}
