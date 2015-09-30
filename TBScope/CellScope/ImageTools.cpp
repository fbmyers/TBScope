#include "ImageTools.h"
#include "opencv2/imgproc/imgproc.hpp"

namespace ImageTools
{
	cv::Mat getRedChannel(cv::Mat image) 
	{
		cv::Mat red(image.rows, image.cols, CV_8UC1);
		cv::Mat junk(image.rows, image.cols, CV_8UC2);
    
		cv::Mat output[] = { red, junk };
		int index_map[] = { 0,0, 1,1, 2,2 };
		cv::mixChannels(&image, 1, output, 2, index_map, 3);
    
		return red;
	}


	cv::Mat normalizeImage(cv::Mat image) 
	{
		cv::Mat img_32F(image.rows, image.cols, CV_32F);
        
        image.convertTo(img_32F, CV_32F);
        double max;
        double min;
        double range;

        if (image.rows == 1944) {
            cv::minMaxIdx(image, &min, &max, NULL, NULL);
        } else if (image.rows >= 1800 && image.cols > 1400) { //neilscope
            cv::Mat img_mask(image.rows,image.cols, CV_8UC1);
            img_mask = cv::Scalar(0);
            for (int i = 800; i < 1800; i++)
            {
                for (int j = 400; j < 1400; j++)
                {
                    img_mask.at<char>(i,j) = 1;
                }
            }

            cv::minMaxIdx(image, &min, &max, NULL, NULL, img_mask);
            img_mask.release();
        } else {
            // Image was smaller than recent iPad resolution; do our best...
            cv::minMaxIdx(image, &min, &max, NULL, NULL);
        }
        
        //cv::minMaxIdx(image, &min, &max);
        range = max-min;
        
        std::cout << "min: " << min;
        std::cout << " max: " << max;
        
		for (int i = 0; i < img_32F.rows; i++) {
			for (int j = 0; j < img_32F.cols; j++) {
				float val = img_32F.at<float>(i, j);
                val = (val>min)?val-min:0.0;
                
				val = val / (float)range;
				img_32F.at<float>(i, j) = val;
			}
		}
    

        
		return img_32F;
	}
}