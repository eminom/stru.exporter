all:
	yacc -d stru.y
	lex stru.l
	cc -std=c99 -o parser *.c

test:
	./parser < input2 > result
	node enci.js result > code_snippet
	@echo '' 
	@echo ''
	@echo ''
	cat ./code_snippet

clean:
	rm -rf parser
	rm -rf *.c
	rm -rf *.h
	rm -rf *.cc
	rm -rf *.o
	rm -rf result*
