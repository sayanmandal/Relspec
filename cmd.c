#include <stdlib.h>
#include <string.h>
#include <string>
#include <iostream>
#include <fstream>

using namespace std;

void relspec(string filename){
	string cmd_final = "./relspec ";
	cmd_final.append(filename);
	/*string out_file = " > Output.txt";
	cmd_final.append(out_file);*/
	string cmd_1 = "bison -d relspec.y";
	string cmd_2 = "flex relspec.l";
	string cmd_3 = "g++ -o relspec relspec.c -lfl";

	system(cmd_1.c_str());
	system(cmd_2.c_str());
	system(cmd_3.c_str());
	system(cmd_final.c_str());

	
	}

bool is_file_exist(const char *fileName)
{
    std::ifstream infile(fileName);
    return infile.good();
}

int main(){
	string filename;
	cout << "Please Enter The FileName You Want To Parse:" <<endl;
	cin >> filename;
	if(!is_file_exist(filename.c_str())){
		cout << "Sorry, The File doesn't exist"<<endl;
		return -1;
		}
	relspec(filename);
	}
