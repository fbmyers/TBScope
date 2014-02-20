#include "Globals.h"
#include <string>

#if __APPLE__
    #define OUTPUT_FOLDER "/Users/wgerard/Dropbox/CS_Comparisons/cpp/"
    #define FEATURES_OUTPUT_FOLDER "/Users/wgerard/Dropbox/CS_Comparisons/cpp/features/"
	#define MATLAB_FOLDER "/Users/wgerard/Dropbox/CS_Comparisons/matlab/"
    #define MODEL_PATH "/Users/wgerard/Dropbox/CS_Comparisons/model_out.txt"
    #define TRAIN_MAX_PATH "/Users/wgerard/Dropbox/CS_Comparisons/train_max.csv"
    #define TRAIN_MIN_PATH "/Users/wgerard/Dropbox/CS_Comparisons/train_min.csv"
#else // Assumed to be windows
    #define OUTPUT_FOLDER "C:\\Users\\Wayne\\Dropbox\\CS_Comparisons\\cpp\\"
    #define FEATURES_OUTPUT_FOLDER "C:\\Users\\Wayne\\Dropbox\\CS_Comparisons\\cpp\\features\\"
	#define MATLAB_FOLDER "C:\\Users\\Wayne\\Dropbox\\CS_Comparisons\\matlab\\"
    #define MODEL_PATH "C:\\Users\\Wayne\\Dropbox\\CS_Comparisons\\model_out.txt"
    #define TRAIN_MAX_PATH "C:\\Users\\Wayne\\Dropbox\\CS_Comparisons\\train_max.csv"
    #define TRAIN_MIN_PATH "C:\\Users\\Wayne\\Dropbox\\CS_Comparisons\\train_min.csv"
#endif

using namespace std;
using namespace cv;

namespace Debug
{
    void print(cv::Mat mat, const char* name);

    void printStats(cv::Mat mat, const char* fileName);

	void printFeatures(const vector<MatDict > features, const char* feature);
    
    void printVector(vector<double> vec, const char* name);
    
    void printPairVector(vector<pair<double, int> > vec, const char* name);

    void printContours(ContourContainerType contours);
    
    void printCentroids(vector<cv::Point> centroids);

    cv::Mat loadMatrix(const char* fileName, int rows, int cols, int type);
    
    vector<cv::Point> loadCentroids();

}