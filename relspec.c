#include "relspec.tab.c"

int main(int argc, char *argv[])
{
  int i,j = 0;
  yyin = fopen(argv[1], "r");
  int a[255][2];
	for(i = 0 ; i < 255 ; i++){
			for(j = 0 ; j <2 ; j++)
				a[i][j] = 0;
			}
	do {
		yyparse(a,0,0);
	} while (!feof(yyin));
	fclose(yyin);
	for(i = 0 ; i < 255 ; i++){
			for(j = 0 ; j < 2 ; j++){
				if(a[i][j] != 0)
					a[i][j] = a[i][j] + 2;
				}
			}
	yyin = fopen(argv[1],"r");
	do{
		yyparse(a,1,0);
	}while(!feof(yyin));
	fclose(yyin);
	
  return 0;
} 
