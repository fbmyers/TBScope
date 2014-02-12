#include "Debug.h"
#include <iostream>
#include <cstring>
#include <fstream>

namespace Debug
{
    
    vector<cv::Point> loadCentroids()
    {
		if (!DEBUG) {
			return *new vector<cv::Point>;
		}
        vector<cv::Point> *centroids = new vector<cv::Point>();
        
        string row_path = MATLAB_FOLDER;
        row_path += "/centroid_rows.txt";
        string col_path = MATLAB_FOLDER;
        col_path += "/centroid_cols.txt";

        char* full_row_path = (char*)row_path.c_str();
        char* full_col_path = (char*)col_path.c_str();
        
        string rowLine;
        string colLine;
        ifstream rowInFile(full_row_path);
        ifstream colInFile(full_col_path);
        
        while (getline(rowInFile, rowLine) && getline(colInFile, colLine))
        {
            int row = ::atoi(rowLine.c_str()) - 1;
            int col = ::atoi(colLine.c_str()) - 1;
            cv::Point p = cv::Point(row, col);
            centroids->push_back(p);
        }

        return *centroids;
    }
    
    Mat loadMatrix(const char* fileName, int rows, int cols, int type)
	{
		if (!DEBUG) {
			return cv::Mat(1, 1, CV_8UC1);
		}

		Mat returnMatrix = Mat(rows, cols, type);
        
		string path = MATLAB_FOLDER;
		path += fileName;
		char* full_path = (char*)path.c_str();
        
		cout << "Opening path: " << full_path << endl;
        
		string line;
		ifstream inFile(full_path);
		if (inFile.is_open())
		{
			for (int i = 0; i < cols; i++)
			{
				for (int j = 0; j < rows; j++)
				{
					getline(inFile, line);
                    
					if (type == CV_32F) {
						float val = (float) ::atof(line.c_str());
						returnMatrix.at<float>(j, i) = val;
					} else if (type == CV_8UC1) {
						int val = ::atoi(line.c_str());
						returnMatrix.at<uchar>(j, i) = (uchar)val;
					} else if (type == CV_64F) {
						double val = ::atof(line.c_str());
						returnMatrix.at<double>(j, i) = val;
                    } else {
						cout << "Didnt understand type: " << type << endl;
					}
				}
			}
			cout << "Closing file: " << full_path << endl;
			inFile.close();
		}
		else cout << "Unable to open file: " << fileName;
        
		return returnMatrix;
	}

	void printStats(cv::Mat mat, const char* fileName)
	{
		if (!DEBUG) {
			return;
		}

		string path = OUTPUT_FOLDER;
		path += fileName;
		char* full_path = (char*)path.c_str();

		ofstream out_file;
		out_file.open(full_path);
    
		double min;
		double max;
		minMaxIdx(mat, &min, &max);
    
		int count = 0;
		string valueText = "";
    
		for (int i = 0; i < mat.cols; i++) {
			for (int j = 0; j < mat.rows; j++) {
				if (mat.type() == CV_8UC1) {
					int val = (int) mat.at<unsigned char>(j, i);
					if (val != 0) {
						if (count < 100)
							out_file << val << ",";
						count++;
					}
				} else if (mat.type() == CV_32F) {
					float val = (float) mat.at<float>(j, i);
					if (val != 0) {
						if (count < 100)
							out_file << val << ",";
						count++;
					}
				} else if (mat.type() == CV_64F) {
					double val = (double) mat.at<double>(j, i);
					if (val != 0) {
						if (count < 100)
							out_file << val << ",";
						count++;
					}
				} else {
					cout << "Didn't understand matrix type! Type: " << mat.type() << endl;
				}
			}
		}

		out_file.close();
	}
    
    void printVector(vector<double> vec, const char* name)
    {
		if (!DEBUG) {
			return;
		}

		string path = OUTPUT_FOLDER;
		path += name;
		char* full_path = (char*)path.c_str();
        
		cout << "Print to file: " << name << " Length: " << vec.size() << endl;
		cout << "Fullpath: " << full_path << endl;
		ofstream out_file;
		out_file.open(full_path);
        
        if (!out_file) {
			cerr << "Can't open output file!" << endl;
		}
        
        vector<double>::iterator it = vec.begin();
        
        for (; it != vec.end(); it++)
        {
            out_file << *it << ",";
        }
        
    }
    
    void printPairVector(vector<pair<double, int> > vec, const char* name)
    {
		if (!DEBUG) {
			return;
		}

		string path = OUTPUT_FOLDER;
		path += name;
		char* full_path = (char*)path.c_str();
        
		cout << "Print to file: " << name << " Length: " << vec.size() << endl;
		cout << "Fullpath: " << full_path << endl;
		ofstream out_file;
		out_file.open(full_path);
        
        if (!out_file) {
			cerr << "Can't open output file!" << endl;
		}
        
        vector<pair<double, int> >::iterator it = vec.begin();
        
        for (; it != vec.end(); it++)
        {
            out_file << it->first << ",";
        }
        
    }

	void print(cv::Mat mat, const char* name)
	{
		if (!DEBUG) {
			return;
		}

		string path = OUTPUT_FOLDER;
		path += name;
		char* full_path = (char*)path.c_str();
    
		cout << "Print to file: " << name << " Rows: " << mat.rows << " Cols: " << mat.cols << endl;
		cout << "Fullpath: " << full_path << endl;
		ofstream out_file;
		out_file.open(full_path);
    
		if (!out_file) {
			cerr << "Can't open output file!" << endl;
		}
    
		for (int i = 0; i < mat.cols; i++) {
			for (int j = 0; j < mat.rows; j++) {
				if (mat.type() == CV_8UC1) {
					int val = (int) mat.at<unsigned char>(j, i);
					out_file << val << ",";
				} else if (mat.type() == CV_32F) {
					float val = (float) mat.at<float>(j, i);
					out_file << val << ",";
				} else if (mat.type() == CV_64F) {
					double val = (double) mat.at<double>(j, i);
					out_file << val << ",";
				} else {
					cout << "Didn't understand matrix type! Type: " << mat.type() << endl;
				}
			}
		}

		out_file.close();

    
	}
    
    void printContours(ContourContainerType contours)
    {
		if (!DEBUG) {
			return;
		}

        ContourContainerType::iterator c_it = contours.begin();
		for(; c_it != contours.end(); c_it++)
		{
            ContourType ctr = *c_it;
            ContourType::iterator it = ctr.begin();
            
            for (; it != ctr.end(); it++)
            {
                cv::Point pt = *it;
            }
		}
    }
    
    bool centroid_comparator ( const cv::Point& l, const cv::Point& r)
    { return l.y < r.y; };
    
    void printCentroids(vector<cv::Point> centroids)
    {
		if (!DEBUG) {
			return;
		}

        sort(centroids.begin(), centroids.end(), centroid_comparator);
        
        string path = OUTPUT_FOLDER;
		string path_rows = path + "centroid_rows.txt";
        string path_cols = path + "centroid_cols.txt";
		char* full_path_rows = (char*)path_rows.c_str();
        char* full_path_cols = (char*)path_cols.c_str();
        
		ofstream out_file_rows;
		ofstream out_file_cols;
		out_file_rows.open(full_path_rows);
		out_file_cols.open(full_path_cols);
        
		if (!out_file_rows || !out_file_cols) {
			cerr << "Can't open output file!" << endl;
		}
        
        vector<cv::Point>::iterator it = centroids.begin();
        
        for (; it != centroids.end(); it++)
        {
            out_file_rows << (it->x + 1) << ",";
            out_file_cols << (it->y + 1) << ",";
        }
        
        out_file_rows.close();
        out_file_cols.close();
    }

	void printFeatures(const vector<MatDict > features, const char* feature)
	{
		if (!DEBUG) {
			return;
		}

        vector<MatDict >::const_iterator it = features.begin();
        for (; it != features.end(); it++)
        {
            MatDict p = *it;
            bool orig = strncmp(feature, "origPatch", sizeof(char*)) == 0;
            bool geom = strncmp(feature, "geom", sizeof(char*)) == 0;
            bool phi = strncmp(feature, "phi", sizeof(char*)) == 0;
            bool binPatch = strncmp(feature, "binPatch", sizeof(char*)) == 0;
            cv::Mat mat;
            
            if (orig)
            {
                mat = p.find("patch")->second;
            } else if (geom) {
                mat = p.find("geom")->second;
            } else if (phi) {
                mat = p.find("phi")->second;
            } else if (binPatch) {
                mat = p.find("binPatch")->second;
            } else {
                cout << "Didn't recognize feature: " << feature << endl;
                return;
            }
            
            
            stringstream row_ss;
			cv::Mat rowMat = p.find("row")->second;
			int row_num = (int)rowMat.at<float>(0,0);
            row_ss << row_num + 1;
            string row = row_ss.str();

            stringstream col_ss;
			cv::Mat colMat = p.find("col")->second;
			int col_num = (int)colMat.at<float>(0,0);
            col_ss << col_num + 1;
            string col = col_ss.str();

            
            string path = FEATURES_OUTPUT_FOLDER;
            path = path + row + "_" + col + "_" + feature + ".txt";
            char* full_path = (char*)path.c_str();
            
            ofstream out_file;
            out_file.open(full_path);
            
            if (!out_file) {
                cerr << "Can't open output file!" << endl;
            }
            
            for (int i = 0; i < mat.cols; i++) {
                for (int j = 0; j < mat.rows; j++) {
                    if (mat.type() == CV_8UC1) {
                        int val = (int) mat.at<unsigned char>(j, i);
                        out_file << val << ",";
                    } else if (mat.type() == CV_32F) {
                        float val = (float) mat.at<float>(j, i);
                        out_file << val << ",";
                    } else if (mat.type() == CV_64F) {
                        double val = (double) mat.at<double>(j, i);
                        out_file << val << ",";
                    } else {
                        cout << "Didn't understand matrix type! Type: " << mat.type() << endl;
                    }
                }
            }
            
            out_file.close();
        }
	}
}
