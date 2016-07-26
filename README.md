# Relspec

It is IEEE sponsored project which targets to make a software reliability language which can predict the reliability of an embedded system based on a probabilistic model . In this sectio, I have made an API named RelSpec which will take any relspec file and generate the corresponding C file.(using flex and bison and c)
To Run:
gcc cmd.c
./a.out
RelSpec language uses mini c grammar to analyse the reliability of an embedded system. It also tries to optimise the system to meet the reliability requirements. Worked on the reliable code generation from relspec description. Implemented the lexer and parser for redundant code generation.
