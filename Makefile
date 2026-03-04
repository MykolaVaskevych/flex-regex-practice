all: jibuc_parser

jibuc_parser: jibuc.tab.c lex.yy.c
	gcc -o jibuc_parser jibuc.tab.c lex.yy.c -lfl

jibuc.tab.c jibuc.tab.h: jibuc.y
	bison -d jibuc.y

lex.yy.c: jibuc.l jibuc.tab.h
	flex jibuc.l

clean:
	rm -f jibuc_parser jibuc.tab.c jibuc.tab.h lex.yy.c

.PHONY: all clean
