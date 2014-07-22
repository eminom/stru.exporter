all:
	yacc -d stru.y
	lex -l stru.l
	cc -std=c99 -o parser *.c

test:
	find sample -name "sample*.in" | xargs -I{} ./test.pl {}

clean:
	rm -rf parser
	rm -rf *.yy.*
	rm -rf *.tab.*
	rm -rf *.o
	rm -rf result*
