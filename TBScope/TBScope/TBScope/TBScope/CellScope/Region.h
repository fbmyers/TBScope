#include "Globals.h"

namespace Region
{
    /**
        Gets the region properties for the center contour which is part of |contours| contained within the image |img|
        @param contours The vector of points for each contour
        @param img      The image to look within
        @return         Returns a dictionary of region properties, calculated using matlab.
    */
    std::map<const char*, float> getProperties(const ContourContainerType contours, const cv::Mat img, const cv::Mat orig);
}