#!/bin/bash

echo "=== 1. Flex source file (comments.l) ==="
cat comments.l

echo ""
echo "=== 2. Running flex to generate lex.yy.c ==="
flex comments.l
echo "Done."

echo ""
echo "=== 3. Compiling the scanner ==="
cc lex.yy.c -o comments_scanner
echo "Done."

echo ""
echo "=== 4. Sample C input (sample.c) ==="
cat sample.c

echo ""
echo "=== 5. Scanner output ==="
./comments_scanner < sample.c
