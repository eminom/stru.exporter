all:
	yacc -d stru.y
	lex -l stru.l
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
	rm -rf *.yy.*
	rm -rf *.tab.*
	rm -rf *.o
	rm -rf result*
