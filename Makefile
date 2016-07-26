CC=g++
CFLAGS=-lfl
OUTPUT=relspec
OBJECTS=lex.yy.c relspec.tab.c relspec
SOURCE=relspec.l relspec.y relspec.c

all: $(SOURCE) lex.yy.c relspec.tab.c
	$(CC) relspec.c $(CFLAGS) -o $(OUTPUT)

lex.yy.c: relspec.l
	flex relspec.l
	
relspec.tab.c: relspec.y
	bison relspec.y
	
clean :
	rm $(OBJECTS)
