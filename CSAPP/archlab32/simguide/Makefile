
SRC = ../src
ROOT = ../../../..
C2TEX = $(ROOT)/bin/c2tex
WWWDIR = /afs/cs/project/csapp2/www
CODE = $(SRC)/y86-code

all: simguide

simguide:
	latex simguide
	latex simguide
	dvips simguide -o simguide.ps
	ps2pdf simguide.ps

codefiles:
	$(C2TEX) -n -f $(CODE)/asum.yo -t code-yso

# This rule is used only by authors
webpage:
	cp simguide.pdf $(WWWDIR)

clean:
	rm -f *~ *.dvi

