%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

int yylex(void);
void yyerror(const char *s);

/* Symbol table */
#define MAX_SYMBOLS 256

struct symbol {
    char *name;
    int capacity;
};

static struct symbol symtab[MAX_SYMBOLS];
static int sym_count = 0;

static void add_symbol(const char *name, int capacity) {
    for (int i = 0; i < sym_count; i++) {
        if (strcasecmp(symtab[i].name, name) == 0) {
            fprintf(stderr, "Warning: variable '%s' already declared\n", name);
            return;
        }
    }
    if (sym_count >= MAX_SYMBOLS) {
        fprintf(stderr, "Error: symbol table full\n");
        return;
    }
    symtab[sym_count].name = strdup(name);
    symtab[sym_count].capacity = capacity;
    sym_count++;
}

static int lookup_symbol(const char *name) {
    for (int i = 0; i < sym_count; i++) {
        if (strcasecmp(symtab[i].name, name) == 0) {
            return symtab[i].capacity;
        }
    }
    return -1;
}

static int error_count = 0;

static void check_declared(const char *name) {
    if (lookup_symbol(name) < 0) {
        fprintf(stderr, "Error: undeclared variable '%s'\n", name);
        error_count++;
    }
}

static int int_digits(const char *intstr) {
    /* count significant digits (skip leading zeros) */
    while (*intstr == '0' && *(intstr + 1) != '\0') intstr++;
    return (int)strlen(intstr);
}

%}

%union {
    char *str;
}

%token <str> IDENTIFIER SIZE_STRING INTEGER STRING_LITERAL
%token BEGINNING END BODY MOVE TO ADD INPUT PRINT DOT SEMICOLON

%%

program:
    BEGINNING DOT declarations BODY DOT statements END DOT {
        if (error_count == 0)
            printf("Program is well-formed.\n");
        else
            printf("Program has %d error(s).\n", error_count);
    }
;

declarations:
    /* empty */
    | declarations declaration
;

declaration:
    SIZE_STRING IDENTIFIER DOT {
        int cap = (int)strlen($1);
        add_symbol($2, cap);
        free($1);
        free($2);
    }
;

statements:
    statement
    | statements statement
;

statement:
    move_stmt
    | add_stmt
    | input_stmt
    | print_stmt
;

move_stmt:
    MOVE INTEGER TO IDENTIFIER DOT {
        int cap = lookup_symbol($4);
        if (cap < 0) {
            fprintf(stderr, "Error: undeclared variable '%s'\n", $4);
            error_count++;
        } else {
            int digits = int_digits($2);
            if (digits > cap) {
                fprintf(stderr, "Warning: integer '%s' (%d digits) overflows capacity of '%s' (%d digits)\n",
                        $2, digits, $4, cap);
            }
        }
        free($2);
        free($4);
    }
    | MOVE IDENTIFIER TO IDENTIFIER DOT {
        int cap1 = lookup_symbol($2);
        int cap2 = lookup_symbol($4);
        if (cap1 < 0) {
            fprintf(stderr, "Error: undeclared variable '%s'\n", $2);
            error_count++;
        }
        if (cap2 < 0) {
            fprintf(stderr, "Error: undeclared variable '%s'\n", $4);
            error_count++;
        }
        if (cap1 >= 0 && cap2 >= 0 && cap1 > cap2) {
            fprintf(stderr, "Warning: capacity mismatch moving '%s' (%d) to '%s' (%d)\n",
                    $2, cap1, $4, cap2);
        }
        free($2);
        free($4);
    }
;

add_stmt:
    ADD INTEGER TO IDENTIFIER DOT {
        int cap = lookup_symbol($4);
        if (cap < 0) {
            fprintf(stderr, "Error: undeclared variable '%s'\n", $4);
            error_count++;
        } else {
            int digits = int_digits($2);
            if (digits > cap) {
                fprintf(stderr, "Warning: integer '%s' (%d digits) may overflow capacity of '%s' (%d digits)\n",
                        $2, digits, $4, cap);
            }
        }
        free($2);
        free($4);
    }
    | ADD IDENTIFIER TO IDENTIFIER DOT {
        check_declared($2);
        check_declared($4);
        free($2);
        free($4);
    }
;

input_stmt:
    INPUT input_list DOT
;

input_list:
    IDENTIFIER {
        check_declared($1);
        free($1);
    }
    | input_list SEMICOLON IDENTIFIER {
        check_declared($3);
        free($3);
    }
;

print_stmt:
    PRINT print_list DOT
;

print_list:
    print_item
    | print_list SEMICOLON print_item
;

print_item:
    STRING_LITERAL {
        free($1);
    }
    | IDENTIFIER {
        check_declared($1);
        free($1);
    }
;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
    error_count++;
}

int main(void) {
    return yyparse();
}
