%{

//C++ Headers
using namespace std;
#include <iostream>
#include <cstdio>
#include <stack>
#include <queue>
#include <vector>
#include <algorithm>
#include <cmath>
#include <sys/time.h>

//Lex Functions and Variables
void yyerror(const char *s);
int yylex(void);

//Time Counters
double cpu_time_relspec,cpu_time_prism,cpu_time_graph;
struct timeval relspec,prism,graph;

//Function Declaration
void calc_rel_graph(void);	//Calculates the reliability of the graph
int factorial(int);	//Factorial Function
int nCr(int n, int);	//Combination Function
void gen_dtmc(void);	//Generates DTMC
float calc_rel();	//Calculates Reliability
void search (int);	//Branch & Bound Search
float dtmc[100][100];	//Adjacency Matrix of DTMC
int node;	//Node in Adjacency Matrix
int loop_iteration;	//Flag indicating the number of loop iterations
stack <int> ifstart;	//Stack for marking the start node of if-statement
stack <float> ifprob;	//Probability of if evaluating true
stack <int> ifend;	//Stack for marking the end of if-statement
int nodecomp[100];	//array for storing node-component relationship nodecomp[node]=component
int curr_cost=0;	//Current Cost
int temp;	//temporary variable
void initialize_adj_mat (void);	//Initializes the Adjacency Matrix of DTMC
void print_adj_mat(int);	//Prints the Adjacency Matrix of DTMC
void print_input_component_information (void);	//Prints input reliability and cost information of components
void ilp_output(void);	//generates output for ilp formulation
void print_result (void);	//prints the best configuration and minimum cost
void print_configuration (void); //prints the configuration of the system
void print_node_reliability_information (void);	//prints the current reliability of the node
int solution_flag;	//flag to indicate if a solution exists
//float calc_prism_time (void);	//Calculates time taken by PRISM to calculate Reliability
int search_counter,prism_calls;
vector<vector <int> >GRAPH(100);
bool isadjacency_node_not_present_in_current_path(int node,vector<int>path);
int findpaths(int ,int ,int ,int );
inline void print_path(vector<int>path);
void print_path_details(vector<int>path);
void make_graph(void);
float rel (vector <int> path);
int transition;
float relgraph;
vector< vector<int> > PATHS;
float cost_incr_rate, min_cost_incr_rate=10000;

/*hardcoded Global Component information*/
void generate_cost(void);
void generate_reliability(void);
#define comp_num 6	//total number of components

// #define comp_options 30
// #define rel_step 0.00004 //number of reliability options

// #define comp_options 24
// #define rel_step 0.000234783 //number of reliability options

#define comp_options 18
#define rel_step 0.000317647 //number of reliability options

// #define comp_options 12
// #define rel_step 0.000490909 //number of reliability options

// #define comp_options 6
// #define rel_step 0.00108 //number of reliability options

float comp_rel[comp_num][comp_options];	//reliability of components
float comp_rel_ini[comp_num][comp_options];	//input reliability of components
int comp_cost[comp_num][comp_options];	//input cost of components
int rel_opt[comp_num];	//number of reliability options for component i = rel_opt[i-1]
int curr_conf[comp_num];	//current selection of reliability options
int best_conf[comp_num];	//best selection of reliability options
int rel_upper[comp_num];
int rel_lower[comp_num];
float target_rel=0.985;	//Target Reliability
int min_cost=9999999;	//Minimum cost
%}

%union	//token return type
{
	float f;
	int i;
}

%token INTEGER FLOAT IDENTIFIER WHILE IF ELSE RE TRY PARR VOID RETURN
%token <f> FLOAT_NUMBER
%token <i> INTEGER_NUMBER
%right '='
%right THEN ELSE
%left LE GE EQ NE '<' '>'
%%

Program			:	DeclarationList ;
DeclarationList		:	DeclarationList Declaration | Declaration ;
Declaration		:	VarDeclaration | FunDeclaration ;
VarDeclaration		:	TypeSpecifier IDENTIFIER ;
TypeSpecifier		:	INTEGER | FLOAT | VOID ;
FunDeclaration		:	TypeSpecifier IDENTIFIER '(' Parameters ')' CompoundStatement ;
Parameters	   	:	ParameterList | VOID | ;
ParameterList		:	ParameterList ',' Parameter | Parameter ;
Parameter		:	TypeSpecifier IDENTIFIER ;
CompoundStatement	:	'{' LocalDeclaration StatementList '}' ;
LocalDeclaration	:	LocalDeclaration VarDeclaration | ;
StatementList		:	StatementList Statement | ;
Statement			:	ExpressionStatement | IterationStatement | SelectionStatement | CompoundStatement | JumpStatement | RepetitionStatement | ParallelStatement | TryStatement;
ExpressionStatement	:	'[' INTEGER_NUMBER ']' Expression ';'
						{
							nodecomp[node]=$2;
							temp=$2-1;
							if (loop_iteration!=1)
							{
								for (int i=0;i<rel_opt[temp];i++)
									comp_rel[temp][i]=pow(comp_rel[temp][i],loop_iteration);
							}
							dtmc[node][node+1]=1;
							dtmc[node+1][node+1]=1;
							dtmc[node][node+2]=1;
							node=node+2;
						}
					;
IterationStatement	:	WHILE '[' INTEGER_NUMBER ',' INTEGER_NUMBER']' '(' Expression ')'
						{
							nodecomp[node]=$3;
							temp=$3-1;
							loop_iteration=loop_iteration*$5;
							for (int i=0;i<rel_opt[temp];i++)
								comp_rel[temp][i]=pow(comp_rel[temp][i],loop_iteration);
							dtmc[node][node+1]=1;
							dtmc[node+1][node+1]=1;
							dtmc[node][node+2]=1;
							node=node+2;
						}
						Statement
						{
							loop_iteration=loop_iteration/$5;
						}
					;
SelectionStatement	: 	IF '[' INTEGER_NUMBER ',' FLOAT_NUMBER ']' '(' Expression ')'
						{
							nodecomp[node]=$3;
							temp=$3-1;
							if (loop_iteration!=1)
							{
								for (int i=0;i<rel_opt[temp];i++)
									comp_rel[temp][i]=pow(comp_rel[temp][i],loop_iteration);
							}
							dtmc[node][node+1]=1;
							dtmc[node+1][node+1]=1;
							dtmc[node][node+2]=1;
							node=node+2;
							ifstart.push(node);
							ifprob.push($5);
							dtmc[node][node+1]=$5;
							node=node+1;
						}
						Statement
							{
						   		ifend.push(node);
							}
							ElsePart
					;
ElsePart			:	ELSE
		            		{
		                			dtmc[ifstart.top()][++node]=(1-ifprob.top());
		                			ifprob.pop();
		            		}
		            		Statement
		            		{
								dtmc[ifend.top()][node]=1;
								ifend.pop();
						   	}
					|	%prec THEN
						{
							dtmc[ifstart.top()][node]=(1-ifprob.top());
								ifstart.pop();
								ifprob.pop();
						   		ifend.pop();
					        	}
					;
RepetitionStatement	:	RE '[' INTEGER_NUMBER ',' INTEGER_NUMBER ']' Expression ';'
						{
							nodecomp[node]=$3;
							temp=$3-1;
							int re=$5;
							for (int i=0;i<rel_opt[temp];i++)
							{
								comp_rel[temp][i]=1-pow((1-comp_rel[temp][i]),re);
								if (loop_iteration!=1)
									comp_rel[temp][i]=pow(comp_rel[temp][i],loop_iteration);
							}
							dtmc[node][node+1]=1;
							dtmc[node+1][node+1]=1;
							dtmc[node][node+2]=1;
							node=node+2;

						}
					;
ParallelStatement	:	PARR '[' INTEGER_NUMBER ',' INTEGER_NUMBER ',' INTEGER_NUMBER ']' Expression ';'
					{
						nodecomp[node]=$3;
						temp=$3-1;
						float prob;
						int m=$5,n=$7,j;
						for (int i=0;i<rel_opt[temp];i++)
						{
							prob=0;
							for (j=m;j<=n;j++)
								prob=prob+nCr(n,j)*pow(comp_rel[temp][i],j)*pow((1-comp_rel[temp][i]),(n-j));
							comp_rel[temp][i]=prob;
							if (loop_iteration!=1)
								comp_rel[temp][i]=pow(comp_rel[temp][i],loop_iteration);
						}
						dtmc[node][node+1]=1;
						dtmc[node+1][node+1]=1;
						dtmc[node][node+2]=1;
						node=node+2;
					}
					;
TryStatement		:	TRY '[' INTEGER_NUMBER ']' Expression '[' INTEGER_NUMBER ']' Expression ';'
					{
						nodecomp[node]=$3;
						temp=$3-1;
						if (loop_iteration!=1)
						{
							for (int i=0;i<rel_opt[temp];i++)
								comp_rel[temp][i]=pow(comp_rel[temp][i],loop_iteration);
						}
						nodecomp[node+1]=$7;
						temp=$7-1;
						if (loop_iteration!=1)
						{
							for (int i=0;i<rel_opt[temp];i++)
								comp_rel[temp][i]=pow(comp_rel[temp][i],loop_iteration);
						}
						dtmc[node][node+1]=1;
						dtmc[node][node+3]=1;
						dtmc[node+1][node+2]=1;
						dtmc[node+1][node+3]=1;
						node=node+3;
					}
					;
JumpStatement		:	RETURN ';' | RETURN Expression ';' ;
Expression			:	IdentifierAssignment '=' Expression | SimpleExpression ;
IdentifierAssignment:	IDENTIFIER ;
SimpleExpression	:	SimpleExpression RelationOperator AdditionExpression | AdditionExpression ;
RelationOperator	:	LE | '<'| '>' | GE | EQ | NE ;
AdditionExpression	:	AdditionExpression AdditionOperator Term | Term ;
AdditionOperator	:	'+' | '-' ;
Term			:	Term ProductOperator Factor | Factor ;
ProductOperator		:	'*' | '/' ;
Factor			:	'(' Expression ')' | IdentifierAssignment | Call | Number ;
Call			:	IDENTIFIER '(' Arguments ')' ;
Arguments		:	ArgumentList | ;
ArgumentList		:	ArgumentList ',' Expression | Expression ;
Number			:	PositiveNumber | NegativeNumber ;
PositiveNumber		:	'+' Value | Value ;
NegativeNumber		:	'-' Value ;
Value			:	INTEGER_NUMBER | FLOAT_NUMBER ;

%%

#include"lex.yy.c"
void yyerror(const char *s)
{
	printf("%d : %s %s\n", yylineno, s, yytext );
}
int main(int argc, char *argv[])
{
  gettimeofday(&relspec, NULL);
  double t1=relspec.tv_sec+(relspec.tv_usec/1000000.0);
  int i,j;
	node=1;
	loop_iteration=1;
	//print_input_component_information ();
	yyin = fopen(argv[1], "r");
	initialize_adj_mat();
	if(!yyparse());
		//printf("\nParsing complete\n");
	else
		printf("\nParsing failed\n");
	//print_node_reliability_information ();
	//print_adj_mat (node);
	for (i=0;i<comp_num;i++)
	{
		rel_opt[i] = comp_options;
		curr_conf[i] = 0;
		best_conf[i] = 0;
	}
	generate_cost();
	generate_reliability();
	print_input_component_information ();
	//gen_dtmc();
	//calc_rel();
	//calc_prism_time();
	//ilp_output();
	for (i=0;i<comp_num;i++)
		printf ("%d ",curr_conf[i]);
	printf ("\n");
	printf ("%f\n",target_rel);
	make_graph();
	findpaths(1,node,node,transition);
	cout << PATHS.size() << endl;
	for (int i=0;i<PATHS.size();i++)
	{
		print_path_details(PATHS[i]);
		relgraph=relgraph+rel(PATHS[i]);
	}
	//printf ("reliability by graph=%f",relgraph);
	/*for(i=0;i<6;i++)
	{
		for (j=0;j<comp_num;j++)
			curr_conf[j]=i;
		calc_rel_graph();
		if (relgraph>target_rel)
		{
			for (int k=0;k<comp_num;k++)
				curr_cost=curr_cost+comp_cost[k][curr_conf[k]];
			if (curr_cost<min_cost)
				min_cost=curr_cost;
			break;
		}
	}
	for (j=0;j<comp_num;j++)
	{
		rel_upper[j]=i;
		rel_lower[j]=i-1;
	}
	printf("\n");
	for (i=0;i<comp_num;i++)
	{
		printf("\t%d",rel_upper[i]);
	}
	printf("\n");
	for (i=0;i<comp_num;i++)
	{
		printf("\t%d",rel_lower[i]);
	}
	for (j=0;j<comp_num;j++)
				curr_cost=curr_cost+comp_cost[j][curr_conf[j]];
	int temp_cost=curr_cost;
	int temp_rel=relgraph;
	for (i=0;i<comp_num;i++)
	{
		curr_conf[i]=1;
		calc_rel_graph();
		for (j=0;j<comp_num;j++)
			curr_cost=curr_cost+comp_cost[j][curr_conf[j]];
		cost_incr_rate=(curr_cost-temp_cost)/(relgraph-temp_rel);
		if (cost_incr_rate<min_cost_incr_rate)
			min_cost_incr_rate=cost_incr_rate;
	}
	printf("\n%f",min_cost_incr_rate);
	for (j=0;j<comp_num;j++)
			curr_conf[j]=0;*/
	// search(-1);
	// printf("\n");
	// for (i=0;i<comp_num;i++)
	// {
	// 	printf("\t%d",best_conf[i]);
	// }
	// print_result();
	fclose(yyin);
	//printf ("\nleaf nodes explored = %d\n",search_counter);
	//printf ("\nNo. of PRISM calls = %d\n",prism_calls);
	gettimeofday(&relspec, NULL);
	double t2=relspec.tv_sec+(relspec.tv_usec/1000000.0);
	cpu_time_relspec = t2-t1;
	//printf("\nTOTAL TIME OF PRISM= %6lf\n",cpu_time_prism);
	//printf("\nTOTAL TIME OF GRAPH= %6lf\n",cpu_time_graph);
	//printf("\nTOTAL TIME OF RELSPEC= %f\n",cpu_time_relspec);
	return 0;
}

void generate_reliability(void)
{
    for (int i=0;i<comp_num;i++)
    {
        for (int j=0;j<comp_options;j++)
        {
            comp_rel[i][j] = .994 + rel_step*j;
            comp_rel_ini[i][j] = comp_rel[i][j];
        }
    }
}

void generate_cost(void)
{
    for (int i=0;i<comp_num;i++)
    {
        comp_cost[i][0] = 3*(i+1)+2;
        for (int j=1;j<comp_options;j++)
        {
            comp_cost[i][j] = comp_cost[i][j-1] + 5*j;
        }
    }
}

inline void print_path(vector<int>path)
{
    //cout<<"[ ";
		cout << path.size()<<" ";
    for(int i=0;i<path.size();++i)
    {
        cout<<path[i]<<" ";
    }
    cout<<endl;
}

void print_path_details (vector <int> path)
{
	float prob = 1;
	for(int i=0;i<path.size()-1;++i)
	{
		if (dtmc[path[i]][path[i+1]] != 0 && dtmc[path[i]][path[i+1]] < 1)
			prob = prob*dtmc[path[i]][path[i+1]];
	}
	printf ("%1.3f",prob);
	int count=0;
	for(int i=0;i<path.size()-1;++i)
	{
		if (dtmc[path[i]][path[i+1]] == 1)
			if ((path[i+1]-path[i])==2)
				++count;
	}
	printf (" %d",count);
	for(int i=0;i<path.size()-1;++i)
	{
		if (dtmc[path[i]][path[i+1]] == 1)
			if ((path[i+1]-path[i])==2)
				printf (" %d",nodecomp[path[i]]);
	}
	printf ("\n");
}

float rel (vector<int>path)
{
	float temp_rel=1;
	int flag_cond=0;
	for(int i=0;i<path.size();++i)
    {
    	if (nodecomp[path[i]])
				temp_rel=temp_rel*comp_rel[nodecomp[path[i]]-1][curr_conf[nodecomp[path[i]]-1]];
			else
			{
				//printf ("\ni=%d,%d\n",i,path[i]);
				for (int j=1;j<=node;j++)
				{
					if (dtmc[path[i]][j]!=0)
					{
						if (dtmc[path[i]][j]!=1)
						{
							//printf ("\ndtmc[%d][%d]=%f\n",path[i],path[i+1],dtmc[path[i]][path[i+1]]);
							temp_rel=temp_rel*dtmc[path[i]][path[i+1]];
							break;
						}
					}
				}
			}
    }
    return temp_rel;
}

bool isadjacency_node_not_present_in_current_path(int node,vector<int>path)
{
    for(int i=0;i<path.size();++i)
    {
        if(path[i]==node)
        return false;
    }
    return true;
}

int findpaths(int source ,int target ,int totalnode,int totaledge )
{
	PATHS.clear();
    vector<int>path;
    path.push_back(source);
    queue<vector<int> >q;
    q.push(path);
	gettimeofday(&graph, NULL);
	double t5=graph.tv_sec+(graph.tv_usec/1000000.0);
    while(!q.empty())
    {
        path=q.front();
        q.pop();

        int last_nodeof_path=path[path.size()-1];
        if(last_nodeof_path==target)
        {
            //cout<<"\nThe Required path is:: ";
            //print_path(path);
            //printf ("reliability of path=%f",rel(path));
            PATHS.push_back(path);
            //relgraph=relgraph+rel(path);
        }
        /*else
        {
            print_path(path);
        }*/

        for(int i=0;i<GRAPH[last_nodeof_path].size();++i)
        {
            if(isadjacency_node_not_present_in_current_path(GRAPH[last_nodeof_path][i],path))
            {

                vector<int>new_path(path.begin(),path.end());
                new_path.push_back(GRAPH[last_nodeof_path][i]);
                q.push(new_path);
            }
        }
    }
    gettimeofday(&graph, NULL);
	double t6=graph.tv_sec+(graph.tv_usec/1000000.0);
	cpu_time_graph += t6-t5;
    return 1;
}

void make_graph()
{
	for (int i=1;i<=node;i++)
	{
		for (int j=1;j<=node;j++)
		{
			if (dtmc[i][j]!=0)
			{
				GRAPH[i].push_back(j);
				transition=transition+1;
			}
		}
	}
}
void print_result (void)
{
	if (solution_flag==0)
		printf ("\nDesired Reliability could not be reached at the given reliablity options\n");
	else
	{
		printf ("\nBest Configuration\n");
		//for (int j=0;j<comp_num;j++)
			//printf ("\t%d",best_conf[j]);
		printf ("\nCOMPONENT\tRELIABILITY\n");
		for (int j=0;j<comp_num;j++)
			printf ("\t%d\t%f\n",j+1,comp_rel_ini[j][best_conf[j]]);
		printf ("\nMinimum cost = %d\n",min_cost);
	}
}
void initialize_adj_mat (void)
{
	int i,j;
	for (i=0;i<100;i++)
	{
		for (j=0;j<100;j++)
		{
			dtmc[i][j] = 0;
		}
	}
	for (i=0,j=0;i<100;i++)
		dtmc[i][j]=i;
	for (i=0,j=0;j<100;j++)
		dtmc[i][j]=j;
}
void print_adj_mat(int n)
{
	int i,j;
	for (i=0;i<=n;i++)
	{
		for (j=0;j<=n;j++)
		{
			printf ("%0.2f\t",dtmc[i][j]);
		}
		printf ("\n");
	}
}
void gen_dtmc ()
{
	int i,j,flag_cond=0,comp,curr_rel_opt;
	float val,prob;

	FILE *fp,*fp1;
	if ((fp = fopen("lang.prism", "w")) == NULL)
		fprintf(stderr, "Cannot open %s\n", "lang.prism");
	fprintf(fp,"dtmc\nmodule lang\nN: [1..%d] init 1;",node);
	for (i=1;i<=node;i++)
	{
		val=0;
		for (j=1;j<=node;j++)
		{
			if (dtmc[i][j]!=0)
			{
				val=val+dtmc[i][j];
				if (dtmc[i][j]!=1)
					flag_cond=1;
			}
		}
		if (val == 2)
		{
			//printf ("\nNODE %d IS A COMPONENT",i);
			comp=nodecomp[i]-1;
			curr_rel_opt=curr_conf[comp];
			prob=comp_rel[comp][curr_rel_opt];
			fprintf (fp,"\n[] N=%d -> %f : (N'=%d) + %f : (N'=%d);",i,(1-prob),i+1,prob,(i+2));
		}
		else if (val == 1)
		{
			if (dtmc[i][i]==1)
			{
				//printf ("\nNODE %d IS A FAILURE NODE",i);
				fprintf (fp,"\n[] N=%d -> (N'=%d);",i,i);
			}
			else if (flag_cond)
			{
				temp=0;
				//printf ("\nNODE %d IS A CONDITIONAL NODE",i);
				for (j=1;j<=node;j++)
				{
					if (dtmc[i][j]!=0)
					{
						prob=dtmc[i][j];
						if (temp==0)
							fprintf (fp,"\n[] N=%d -> %f : (N'=%d) + ",i,prob,j);
						temp=j;
					}
				}
				fprintf (fp,"%f : (N'=%d);",prob,temp);
			}
			else
			{
				//printf ("\nNODE %d IS A TRANSITIONAL NODE",i);
				for (j=1;j<=node;j++)
				{
					if (dtmc[i][j]==1)
						fprintf (fp,"\n[] N=%d -> (N'=%d);",i,j);
				}
			}
		}
		else
		{
			//printf ("\nNODE %d IS A SUCCESS NODE",i);
			fprintf (fp,"\n[] N=%d -> (N'=%d);",i,i);
			if ((fp1 = fopen("prop.pctl", "w")) == NULL)
				fprintf(stderr, "Cannot open %s\n", "prop.pctl");
			fprintf (fp1,"label \"success\" = N=%d;\nP = ? [F \"success\"]",i);
			fclose(fp1);
		}
		flag_cond=0;
	}
	fprintf(fp,"\nendmodule");
	printf("\n");
	fclose(fp);
}
float calc_rel()
{
	float reliability;
	FILE* fp;
	prism_calls = prism_calls +1;
	gettimeofday(&prism, NULL);
    double t3=prism.tv_sec+(prism.tv_usec/1000000.0);
	system("/opt/prism-4.2.beta1-linux64/bin/prism lang.prism prop.pctl > prism");
	gettimeofday(&prism, NULL);
	double t4=prism.tv_sec+(prism.tv_usec/1000000.0);
	cpu_time_prism += t4-t3;
	system("awk '/Result/{print $2}' prism > reliability");
	if ((fp = fopen("reliability", "r")) == NULL)
		fprintf(stderr, "Cannot open %s\n", "reliability");
	fscanf (fp,"%f",&reliability);
	printf("\nReliability=%f",reliability);
	fclose(fp);
	return reliability;
}
/*float calc_prism_time()
{
	float time;
	FILE* fp;
	system("awk '/Time\ for\ model\ construction/{print $5}' prism > time");
	if ((fp = fopen("time", "r")) == NULL)
		fprintf(stderr, "Cannot open %s\n", "time");
	fscanf (fp,"%f",&time);
	float temp = time;
	printf("\nTime taken by PRISM for model construction=%f",time);
	fclose(fp);
	system("awk '/Time\ for\ model\ checking/{print $5}' prism > time");
	if ((fp = fopen("time", "r")) == NULL)
		fprintf(stderr, "Cannot open %s\n", "time");
	fscanf (fp,"%f",&time);
	temp = temp + time;
	printf("\nTime taken by PRISM for model checking=%f",time);
	fclose(fp);
	printf("\nTotal time taken by PRISM=%f\n",temp);
	return time;
}*/
void print_input_component_information (void)
{
	int i,j;
	printf ("%d\n",comp_num);
	//printf ("\nCOMPONENT\tRELIABLITY\tCOST\n");
    	for (i=0;i<comp_num;i++)
    	{
    		printf ("C%d  %d",i+1,rel_opt[i]);
        	for (j=0;j<rel_opt[i];j++)
        	{
        	    	printf ("  %f  %f  %d",comp_rel_ini[i][j],comp_rel[i][j],comp_cost[i][j]);
        	}
        printf ("\n");
    	}
    // printf ("%f\n",target_rel);
}

void print_node_reliability_information (void)
{
	int i,comp,curr_rel_opt,cost;
	float prob;
	printf ("\n\nCOMPONENT\tNODE\tOPTION\tRELIABLITY\tCOST\n");
    	for (i=0;i<node;i++)
    	{
    		if (nodecomp[i]!=0)
    		{
    			comp=nodecomp[i]-1;
				curr_rel_opt=curr_conf[comp];
				prob=comp_rel[comp][curr_rel_opt];
				cost=comp_cost[comp][curr_rel_opt];
				printf ("\n\t%d\t%d\t%d\t%f\t%d\n",comp+1,i,curr_rel_opt,prob,cost);
			}
     	}
}

void ilp_output(void)
{
	FILE* fp;
	if ((fp = fopen("AdjMatrix.ini", "w")) == NULL)
		fprintf(stderr, "Cannot open %s\n", "AdjMatrix");
	int count=0;
	for(int row = 1; row <= node; row++)
 	{
		for(int col = 1; col <= node; col++)
		{
	    		if ( dtmc[row][col] != 0.0f )
	    		++count;
		}
	}
	fprintf(fp, "%d\n%d\n", node, count);
	for(int row = 1; row <= node; row++)
    {
		for(int col = 1; col <= node; col++)
		{
			if ( dtmc[row][col] != 0.0f )
			fprintf(fp, "%-2d\t%-2d\t%0.2f\n", row, col, dtmc[row][col]);
		}
    }
	fclose(fp);
 	FILE* lsp_OutFile = fopen("ComponentInFile.ini", "w");
	fprintf(lsp_OutFile, "NUMOFCOMPONENTS %d\n", comp_num);
    fprintf(lsp_OutFile, "SUCCESSNODE %d\t%d\n",1, node);
    fprintf(lsp_OutFile, "COMPONENTSEQ:\t");
    int cmpCount = 1;
    for(int ln_CmpCnt = 1; ln_CmpCnt <= node; ln_CmpCnt++)
    {
		if ( nodecomp[ln_CmpCnt] )
        fprintf(lsp_OutFile, "%d-%d ", cmpCount++, ln_CmpCnt);
    }
    fprintf(lsp_OutFile, "\n\nCOMPONENTNUM     ROWS    VALUES\n");
	for(int ln_CmpCnt = 0; ln_CmpCnt < comp_num; ln_CmpCnt++)
    {
        fprintf(lsp_OutFile, "%d\t%d\t", ln_CmpCnt+1, rel_opt[ln_CmpCnt]);
	    for(int ln_Count = 0; ln_Count < rel_opt[ln_CmpCnt]; ln_Count++)
        {
            fprintf(lsp_OutFile, "<%f %d> ", comp_rel[ln_CmpCnt][ln_Count], comp_cost[ln_CmpCnt][ln_Count]);
        }
        fprintf(lsp_OutFile, "\n");
    }
}
void print_configuration (void)
{
	int j;
	printf ("\n\n");
	for (j=0;j<comp_num;j++)
		printf ("\t%d",curr_conf[j]);
	//printf ("\n");
	//for (j=0;j<comp_num;j++)
		//printf ("\t%f",comp_rel[j][curr_conf[j]]);
}
void print_node_reliability ()
{
	int i,j;
	printf ("%d\n",comp_num);
	//printf ("\nCOMPONENT\tRELIABLITY\tCOST\n");
    	for (i=0;i<comp_num;i++)
    	{
        	for (j=0;j<rel_opt[i];j++)
        	{
        	    	printf ("\t%d\t%f\t%d\n",i,comp_rel[i][j],comp_cost[i][j]);
        	}
    	}
}
void calc_rel_graph(void)
{
	relgraph=0;
	for (int i=0;i<PATHS.size();i++)
	{
		//print_path(PATHS[i]);
		relgraph=relgraph+rel(PATHS[i]);
	}
	//print_configuration ();
	//printf ("reliability by graph=%f",relgraph);
}
void search (int i)
{
	int j,flag1=0,flag2=0;
	float rel;
	curr_cost=0;
	for (j=0;j<comp_num;j++)
				curr_cost=curr_cost+comp_cost[j][curr_conf[j]];
	calc_rel_graph();
	if (i==(comp_num-1))
	{
		flag1=0;
		flag2=0;
		//print_configuration ();
		for (j=0;j<comp_num;j++)
			{
				if (curr_conf[j]>rel_lower[j])
					flag1=1;
			}
		for (j=0;j<comp_num;j++)
			{
				if (curr_conf[j]<rel_upper[j])
					flag2=1;
			}
		//if (flag1==1&&flag2==1)
		{
			//print_configuration ();
			search_counter=search_counter+1;
			//print_configuration ();
			//print_node_reliability_information ();
			//for (j=0;j<comp_num;j++)
			//	curr_cost=curr_cost+comp_cost[j][curr_conf[j]];
			if (curr_cost < min_cost)
			{
				//gen_dtmc();
				//end_relspec = clock ();
				//cpu_time_relspec = cpu_time_relspec + ((double) (end_relspec - start_relspec)) / CLOCKS_PER_SEC;

				//rel = findpaths(1,node,node,transition);
				//calc_rel_graph();
				//rel = calc_rel();
				//start_relspec = clock ();
				if (relgraph>target_rel)
				{
					solution_flag=1;
					min_cost=curr_cost;
					for (j=0;j<comp_num;j++)
						best_conf[j]=curr_conf[j];
					//print_result();
				}
			}
			//else
				//printf ("\nCOST EXCEEDED BOUNDS\n");
			return;
		}
	}
	else
	{
		//calc_rel_graph();
		printf("\nReliability Difference = %f\n",(target_rel-relgraph));
		printf("\nRequired Cost = %f\n",(curr_cost+((target_rel-relgraph)*min_cost_incr_rate)));
		printf("\nMin Cost = %d\n",min_cost);
		if (((curr_cost+target_rel-relgraph)*min_cost_incr_rate)<min_cost)
		{
			i=i+1;
			search(i);
			while(curr_conf[i]<rel_opt[i]-1)
			{
				curr_conf[i]=curr_conf[i]+1;
				search(i);
			}
			curr_conf[i]=0;
		}
	}
}
int factorial(int n)
{
	int i;
   	long result = 1;
	for( i = 1 ; i <= n ; i++ )
      		result = result*i;
	return result;
}
int nCr(int n, int r)
{
   	int result;
	result = factorial(n)/(factorial(r)*factorial(n-r));
	return result;
}
