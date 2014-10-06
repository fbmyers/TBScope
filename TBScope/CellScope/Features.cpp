#include "Features.h"
#include "MatrixOperations.h"
#include "Region.h"
#include "ClassifierGlobals.h"

namespace Features
{

	Mat geometricFeatures(const Mat binPatch, const Mat patch)
	{
		Mat geometricFeatures = Mat(14, 1, CV_32F);

		ContourContainerType contours;
		cv::vector<Vec4i> hierarchy;

		//std::cout << "Finding contours in binary patch" << std::endl;
		findContours(binPatch.clone(), contours, hierarchy, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE);

		if (contours.size() == 0) {
			return cv::Mat::zeros(14, 1, CV_32F);
		}

		//std::cout << "Grabbing region properties for patch" << std::endl;
		std::map<const char*, float> regionProperties = Region::getProperties(contours, binPatch, patch);

        int key_count = 14;
		const char* keys[] = {"area", "convexArea", "eccentricity", "equivDiameter", "extent", "filledArea",
            "majorAxisLength", "minorAxisLength", "maxIntensity", "minIntensity",
            "meanIntensity", "perimeter", "solidity", "eulerNumber"};

		//std::cout << "Dumping props into geom matrix" << std::endl;
		for (int i = 0; i < key_count; i++) {
            const char* key = keys[i];
            float val = regionProperties.find(key)->second;
			geometricFeatures.at<float>(i, 0) = val;
		}


		return geometricFeatures;
	}

	bool checkPartialPatch(int row, int col, int maxRow, int maxCol)
	{
		bool partial = false;

		// Lower bounds checking
		int lowerC = col - PATCHSZ / 2;
		int lowerR = row - PATCHSZ / 2;
		if (lowerC <= 0 || lowerR <= 0) {
			partial = true;
		}

		// Higher bounds checking
		int higherC = (col + (PATCHSZ / 2 - 1));
		int higherR = (row + (PATCHSZ / 2 - 1));

		if ((higherC > maxCol) || (higherR  > maxRow)) {
			partial = true;
		}

		return partial;
	}

	bool checkPatchOutsideCircle(int row, int col, int maxRow, int maxCol, int radius)
	{
		bool partial = false;
        
        double centerX = maxCol/2;
        double centerY = maxRow/2;
        
        double r = sqrt(pow((row-centerY),2) + pow((col-centerX),2));
        
        
		if (r > (double)radius) {
			partial = true;
		}
        
		return partial;
	}
    
	double momentpq(const Mat image, int p, int q, double xc, double yc)
    {
        double sum = 0;
        for (int i = 0; i < image.rows; i++)
        {
            for (int j = 0; j < image.cols; j++)
            {
                // x = i, y = j
                double val = (double) image.at<float>(i, j);
                double colVal = pow((j - yc), q);
                double rowVal = pow((i - xc), p);
                double next = rowVal * colVal * val;
                sum += next;

            }
        }
        return sum;
    }

	cv::Mat makePatch(const int row, const int col, const Mat original)
	{
		int row_start = (row - PATCHSZ / 2);
		int row_end = row + (PATCHSZ / 2);
		int col_start = (col - PATCHSZ / 2);
		int col_end = col + (PATCHSZ / 2);

		Mat patchMatrix = original(cv::Range(row_start, row_end), cv::Range(col_start, col_end));
		return patchMatrix;
	}

    cv::Mat calculateBinarizedPatch(const cv::Mat &origPatch)
    {
      // Calculate binarized patch using Otsu threshold.
      //std::cout << "Calculating binarize patch" << std::endl;
      int rows = origPatch.rows;
      int cols = origPatch.cols;

      cv::Mat binPatchNew(rows, cols, CV_32F);
      cv::Mat preThresh(rows, cols, CV_32F);
      cv::Mat junk(rows, cols, CV_8UC1);

      float maxVal = origPatch.at<float>((rows/2) - 1, (cols/2) - 1);

      for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
          float matVal = origPatch.at<float>(i, j);
          float val = MIN(matVal, maxVal);
          val = val / maxVal;
          preThresh.at<float>(i, j) = val;
        }
      }

      cv::Mat preThreshConverted;
      preThresh.clone().convertTo(preThreshConverted, CV_8UC1, 255);
      // compute optimal Otsu threshold
      double thresh = cv::threshold(preThreshConverted,junk,0,255,CV_THRESH_BINARY | CV_THRESH_OTSU);
      thresh = thresh / 255.0;

      int count = 0;
      // apply threshold
  		for (int i = 0; i < preThresh.rows; i++) {
  			for (int j = 0; j < preThresh.cols; j++) {
  				float val = preThresh.at<float>(i, j);
  				float newVal = 0;
  				if (val > thresh) {
  					newVal = 1;
  				}
  				binPatchNew.at<float>(i, j) = newVal;
  				count++;
  			}
  		}
      //cv::threshold(preThresh,binPatchNew,(thresh/255.0),1,CV_THRESH_BINARY);
  		//Debug::print(preThresh, "prethresh.txt");
  		//Debug::print(binPatchNew, "bin_patch_init.txt");

      binPatchNew.convertTo(binPatchNew, CV_8UC1);
      ContourContainerType newContours;


      cv::findContours(binPatchNew.clone(), newContours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE);
      std::vector<cv::Point2d> allCenters = MatrixOperations::findWeightedCentroids(newContours, binPatchNew, origPatch);

      if (allCenters.size() > 1) {
        std::vector<cv::Point2d>::const_iterator it = allCenters.begin();
        std::vector<double> distances;

        double minDist = 1E10;
        int index = 0;
        std::vector<int> patchIndices;

        for (; it != allCenters.end(); it++) {
  				cv::Point2d center = *it;
  				double patchValue = (rows / 2) + 0.5;
  				double x = pow((it->x - patchValue), 2);
  				double y = pow((it->y - patchValue), 2);

  				double distance = pow(x + y, 0.5);

  				if (distance < minDist) {
  					minDist = distance;
  				}

        }

  			for (it = allCenters.begin(); it != allCenters.end(); it++) {
  				double patchValue = (rows / 2) + 0.5;
  				double x = pow((it->x - patchValue), 2);
  				double y = pow((it->y - patchValue), 2);

  				double distance = pow(x + y, 0.5);

  				if (distance == minDist) {
  					patchIndices.push_back(index);
  				}

  				index++;
  			}

  			index = 0;
  			ContourContainerType::const_iterator cit = newContours.begin();
  			for (; cit != newContours.end(); cit++) {
  				ContourType contour = *cit;

  				std::vector<int>::const_iterator pit = patchIndices.begin();
  				bool inIndices = false;
  				for (; pit != patchIndices.end(); pit++) {
  					if (inIndices) {
  						break;
  					}
  					if (*pit == index) {
  						inIndices = true;
  					}
  				}
  				if (!inIndices) {
  					std::vector<cv::Point>::const_iterator rit = contour.begin();
  					for (; rit != contour.end(); rit++) {
  						cv::Point pt = *rit;
  						binPatchNew.at<unsigned char>(pt.x, pt.y) = 0;
  					}
  				}

  				index++;
  			}
  		}
      return binPatchNew;
    }

    vector<MatDict > calculateFeatures(const vector<MatDict > blobs)
    {
        vector<MatDict >::const_iterator it = blobs.begin();
        vector<MatDict > patchedBlobs;

        //std::cout << "calculating features... " << std::endl;
        for (; it != blobs.end(); it++)
        {
            MatDict p = *it;
            Mat patch = p.find("patch")->second;

			//std::cout << "Calculating moments..." << std::endl;
			// Calculate the hu moments
			Moments m = cv::moments(patch);
            double huMomentsArr[7];
			HuMoments(m, huMomentsArr);
            Mat huMoments = Mat(8,1,CV_64F);
            for (int j = 0; j < 7; j++)
            {
               huMoments.at<double>(j, 0) = huMomentsArr[j];
            }

            // Phi_11 moment
            double xc = m.m10 / m.m00;
            double yc = m.m01 / m.m00;

			double mu40 = momentpq(patch, 4, 0, xc, yc);
            double mu22 = momentpq(patch, 2, 2, xc, yc);
            double mu04 = momentpq(patch, 0, 4, xc, yc);

            double nu40 = mu40 / pow(m.m00, 3);
            double nu22 = mu22 / pow(m.m00, 3);
            double nu04 = mu04 / pow(m.m00, 3);

			double last_moment = nu40 - 2 * nu22 + nu04;
            huMoments.at<double>(7, 0) = last_moment;
            //std::cout << "Done calculating moments" << std::endl;

			// Grab the geometric features and return
			//std::cout << "Grabbing binpatch" << std::endl;
            Mat binPatch = p.find("binPatch")->second;
			//std::cout << "Calculating geometric features..." << std::endl;
            Mat geom = geometricFeatures(binPatch.clone(), patch.clone());
			//std::cout << "Done calculating geometric features" << std::endl;
            p.insert(std::make_pair("geom", geom));
            p.insert(std::make_pair("phi", huMoments));
			patchedBlobs.push_back(p);

        }
		//std::cout << "Done calculating features" << std::endl;

		return patchedBlobs;
    }

}