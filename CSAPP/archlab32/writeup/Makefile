C2TEX = ./c2tex
CODE = ../src

all: codefiles
	latex archlab.tex
	latex archlab.tex  # to resolve references
	dvips -o archlab.ps archlab.dvi
	ps2pdf archlab.ps

codefiles:
	$(C2TEX) -n -f $(CODE)/pipe/ncopy.c -t ncopy
	$(C2TEX) -n -f $(CODE)/pipe/ncopy.ys -t ncopy-ys
	$(C2TEX) -n -f $(CODE)/misc/examples.c -t examples

clean:
	rm -f *~ *.dvi *.log *.aux archlab.ps archlab.pdf



