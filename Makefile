SHELL=/bin/sh
LEX=flex
YACC=bison
CC=gcc
CFLAGS=-std=c11 -pedantic -Wall -Iinclude
LDFLAGS=
# --nounput: ne g�n�re pas la fonction yyunput() inutile
# --DYY_NO_INPUT: ne prend pas en compte la fonction input() inutile
# -D_POSIX_SOURCE: d�clare la fonction fileno()
LEXOPTS=-D_POSIX_SOURCE -DYY_NO_INPUT --nounput
YACCOPTS=
vpath %.h ./include
vpath %.c ./src

LIBS=util.o hashtable.o stt.o stack.o llist.o

# REMPLACER ICI "fichier" PAR LE NOM DE VOS FICHIERS
PROG=algo

all: clean $(PROG)

run : $(PROG) 
	./$(PROG) > $(PROG).asm
	asipro $(PROG).asm $(PROG).asipro
	sipro $(PROG).asipro
	rm *.asipro

$(PROG): lex.yy.o $(PROG).tab.o $(LIBS)
	$(CC) $(CFLAGS) $+ -o $@ $(LDFLAGS) 

lex.yy.c: $(PROG).l $(PROG).tab.h
	$(LEX) $(LEXOPTS) $<

lex.yy.h: $(PROG).l
	$(LEX) $(LEXOPTS) --header-file=$@ $<

$(PROG).tab.c $(PROG).tab.h: $(PROG).y lex.yy.h
	$(YACC) $(YACCOPTS) $< -d -v --graph

%.o: %.c
	$(CC) -DYYDEBUG $(CFLAGS) $< -c

clean:
	-rm $(PROG) *.o lex.yy.* $(PROG).tab.* *.err *.output *.out *.dot *.gv *.asm *.asipro
