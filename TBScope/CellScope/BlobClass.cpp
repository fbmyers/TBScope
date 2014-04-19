#include "BlobClass.h"
#include "MatrixOperations.h"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/highgui/highgui.hpp"

namespace BlobClass
{
	cv::Mat crossCorrelateWithGaussian(cv::Mat matrix) 
	{
		cv::Mat correlationMatrix;
		cv::Mat binarizedMatrix;
		cv::Mat result;

		int kernelSize = 17;               // Size of Gaussian kernel // 16 + 1
		float kernelStdDev  = 1.5f;         // StdDev of Gaussian kernel
		double correlationThreshold = 0.125;//0.130;  // Threshold on normalized cross-correlation

		cv::GaussianBlur(matrix, correlationMatrix, cv::Size(kernelSize, kernelSize), kernelStdDev, kernelStdDev); 
		cv::threshold(correlationMatrix, binarizedMatrix, correlationThreshold, 1.0, CV_THRESH_BINARY);
    
		// Touch-up morphological operations
		int type = cv::MORPH_RECT;
		cv::Mat element = getStructuringElement(type, cv::Size(2,2));
		cv::morphologyEx(binarizedMatrix, result, cv::MORPH_CLOSE, element);
		
        correlationMatrix.release();
        binarizedMatrix.release();
        
		return result;
	}

	cv::Mat blobIdentification(cv::Mat image, std::string debugPath)
	{
        //this is a hack, but it handles the different thresholds between this scope and Neil's scope
        bool neilscope = true;
        int thresholdMultiplier = 6;
        if (image.rows==1944) {
            neilscope = false;
            thresholdMultiplier = 3;
            std::cout << "running as Neilscope image\n";
        }
        
        //input image has been normalized
        
		cv::Mat grayscaleImage;
		cv::Mat imageOpening;
		cv::Mat imageDifference;
		cv::Mat imageThreshold;
		cv::Mat meanImageDifference;
		cv::Mat stdDevImageDifference;
    
		// Get background image via morphological opening w/ 9x9 strel
        //Q: use gaussianBlur instead?
		cv::morphologyEx(image, imageOpening, cv::MORPH_OPEN, cv::getStructuringElement(cv::MORPH_RECT, cv::Size(9,9)));
		
        //std::cout << "opened\n";
        if (debugPath!="")
            imwrite(debugPath + "/opened2-1.tif",imageOpening*255);
        
		// Subtract background
		cv::subtract(image, imageOpening, imageDifference);
        
        if (debugPath!="")
            imwrite(debugPath + "/subtracted2-2.tif",imageDifference*255);
        
        //std::cout << "subtracted\n";
        
        imageOpening.release(); //FBM
        
        //TODO: bring all these parameters out to settings
        //TODO: image mask
        if (!neilscope)
        {
            cv::Mat img_mask(image.rows,image.cols, CV_8UC1);
            img_mask = cv::Scalar(0);
            for (int i = 800; i < 1800; i++) {
                for (int j = 400; j < 1400; j++) {
                    img_mask.at<char>(i,j) = 1;
                }
            }
            if (debugPath!="")
                imwrite(debugPath + "/mask2-3.tif",img_mask*255);
            
            cv::meanStdDev(imageDifference, meanImageDifference, stdDevImageDifference, img_mask);
            img_mask.release();
        }
        else
        {
            cv::meanStdDev(imageDifference, meanImageDifference, stdDevImageDifference);
        }
        // Find mean and std dev of background-subtracted image
        //threshold for binarization is mean + 3*std_dev

		double mean = meanImageDifference.at<double>(0, 0);
		double stdev = stdDevImageDifference.at<double>(0, 0);
		double threshold_value = mean + (thresholdMultiplier * stdev);
        std::cout << "mean: " << mean << " std: " << stdev << " thresh: " << threshold_value << "\n";

        //get binary (thresholded) image
		imageThreshold = MatrixOperations::greaterThanValue((float)threshold_value, imageDifference);
        
        if (debugPath!="")
            imwrite(debugPath + "/thresholded2-4.tif",imageThreshold*255);
        
        //std::cout << "thresholded\n";
        imageDifference.release(); //FBM

        
		// Only use pixels which pass the threshold from the cross correlation
        //I don't understand what this is doing
		cv::Mat grayscaleCrossCorrelation = crossCorrelateWithGaussian(image);
		cv::bitwise_and(imageThreshold, grayscaleCrossCorrelation, grayscaleImage);

        //std::cout << "cross correlated\n";
        image.release(); //FBM
        imageThreshold.release(); //FBM
        grayscaleCrossCorrelation.release(); //FBM
        
        if (debugPath!="")
            imwrite(debugPath + "/grayscalecorrelated2-5.tif",grayscaleImage*255);
        
		// Morphological close
		cv::Mat closingElement = getStructuringElement(cv::MORPH_RECT, cv::Size(3,3));
		cv::morphologyEx(grayscaleImage, grayscaleImage, cv::MORPH_CLOSE, closingElement);
     
		grayscaleImage.convertTo(grayscaleImage, CV_8UC1);
    
        closingElement.release(); //FBM

        if (debugPath!="")
            imwrite(debugPath + "/grayscaleclsed2-6.tif",grayscaleImage*255);
        
        
		return grayscaleImage;
	}
 

    /* come back to this...I feel like Jeanette's implementation is overly complex
    cv::Mat blobIdentification(cv::Mat image, std::string debugPath)
	{
        //input image has been normalized
        
		cv::Mat outputImage;
		cv::Mat imageOpening;
		cv::Mat imageClosed;
		cv::Mat imageThreshold;
		cv::Mat meanImageDifference;
		cv::Mat stdDevImageDifference;
        
        //TODO: image mask as TIF
        cv::Mat img_mask(image.rows,image.cols, CV_32FC1);
        img_mask = cv::Scalar(0);
        for (int i = 1000; i < 1500; i++) {
            for (int j = 750; j < 1250; j++) {
                img_mask.at<char>(i,j) = 1;
            }
        }
        
        imwrite(debugPath + "/blobinput2-1.tif",imageThreshold*255);
    
        // Find mean and std dev of background-subtracted image
        //threshold for binarization is mean + 3*std_dev
		cv::meanStdDev(image, meanImageDifference, stdDevImageDifference, img_mask);
		double mean = meanImageDifference.at<double>(0, 0);
		double stdev = stdDevImageDifference.at<double>(0, 0);
		double threshold_value = mean + (3 * stdev);
        std::cout << "mean: " << mean << " std: " << stdev << " thresh: " << threshold_value << "\n";
        
        //get binary (thresholded) image
		imageThreshold = MatrixOperations::greaterThanValue((float)threshold_value, image);
        
        imwrite(debugPath + "/thresholded2-2.tif",imageThreshold*255);
        
        std::cout << "thresholded\n";
        
        //close image to filter noise (below 3x3 px)
 		cv::Mat closingElement = getStructuringElement(cv::MORPH_RECT, cv::Size(9,9));
		cv::morphologyEx(imageThreshold, imageClosed, cv::MORPH_CLOSE, closingElement);
        closingElement.release(); //FBM
        
        imwrite(debugPath + "/closed2-3.tif",imageClosed*255);
        
		// Only use pixels which pass the threshold from the cross correlation
		//cv::Mat grayscaleCrossCorrelation = crossCorrelateWithGaussian(image);

		cv::bitwise_and(imageClosed, image, outputImage);
        
        image.release(); //FBM
        imageThreshold.release(); //FBM
        
        imwrite(debugPath + "/anded2-4.tif",outputImage*255);
        
		outputImage.convertTo(outputImage, CV_8UC1);
        

        imwrite(debugPath + "/converted2-5.tif",outputImage*255);
        
		return outputImage;
	}
     */
    
    
}