#include "Globals.h"

using namespace cv;

namespace Features
{
    vector<MatDict > calculateFeatures(const vector<MatDict > blobs);
	bool checkPartialPatch(int row, int col, int maxRow, int maxCol);
	Mat geometricFeatures(const Mat binPatch);
	Mat makePatch(const int row, const int col, const Mat original);
    Mat calculateBinarizedPatch(const Mat origPatch);
}