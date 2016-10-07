# Modify this line to indicate the default version to build

VERSION=std

# Comment this out if you don't have Tcl/Tk on your system

GUIMODE=-DHAS_GUI

# Modify the following line so that gcc can find the libtcl.so and
# libtk.so libraries on your system. You may need to use the -L option
# to tell gcc which directory to look in. Comment this out if you
# don't have Tcl/Tk.

TKLIBS=-L/usr/lib -ltk -ltcl

# Modify the following line so that gcc can find the tcl.h and tk.h
# header files on your system. Comment this out if you don't have
# Tcl/Tk.

TKINC=-isystem /usr/include

# Modify these two lines to choose your compiler and compile time
# flags.

CC=gcc
CFLAGS=-Wall -O2

##################################################
# You shouldn't need to modify anything below here
##################################################

MISCDIR=../misc
HCL2C=$(MISCDIR)/hcl2c
INC=$(TKINC) -I$(MISCDIR) $(GUIMODE)
LIBS=$(TKLIBS) -lm
YAS = ../misc/yas

all: psim drivers

# This rule builds the PIPE simulator
psim: psim.c sim.h pipe-$(VERSION).hcl $(MISCDIR)/isa.c $(MISCDIR)/isa.h 
	# Building the pipe-$(VERSION).hcl version of PIPE
	$(HCL2C) -n pipe-$(VERSION).hcl < pipe-$(VERSION).hcl > pipe-$(VERSION).c
	$(CC) $(CFLAGS) $(INC) -o psim psim.c pipe-$(VERSION).c \
		$(MISCDIR)/isa.c $(LIBS)

# This rule builds driver programs for Part C of the Architecture Lab
drivers: 
	./gen-driver.pl -n 4 -f ncopy.ys > sdriver.ys
	../misc/yas sdriver.ys
	./gen-driver.pl -n 63 -f ncopy.ys > ldriver.ys
	../misc/yas ldriver.ys

# Automatic generation and testing of benchmarks
# Parameters for best result found
UNROLL = 6
NCFLAG = 
NCHECK = 16

benchmark:
	./gen-ncopy.pl -u $(UNROLL) $(NCFLAG) > ncopyl$(UNROLL)$(NCFLAG).ys
	make ncopyl$(UNROLL)$(NCFLAG).yo
	./check-len.pl < ncopyl$(UNROLL)$(NCFLAG).yo
	./correctness.pl -n $(NCHECK) -f ncopyl$(UNROLL)$(NCFLAG)
	./benchmark.pl -f ncopyl$(UNROLL)$(NCFLAG)

# These are implicit rules for assembling .yo files from .ys files.
.SUFFIXES: .ys .yo
.ys.yo:
	$(YAS) $*.ys


# This rule builds the student distribution of the Y86 tool chain in ../sim
dist:
	cp -p	pipe-1w.hcl pipe-broken.hcl pipe-btfnt.hcl pipe-full.hcl \
		pipe-lf.hcl pipe-nobypass.hcl pipe-nt.hcl pipe-std.hcl \
		psim.c pipe.tcl pipeline.h sim.h stages.h $(DISTDIR)/pipe
	cp -p Makefile-sim $(DISTDIR)/pipe/Makefile
	cp -p README $(DISTDIR)/pipe/README
	cp -p ncopy.c ncopy.ys $(DISTDIR)/pipe
	cp -p benchmark.pl correctness.pl gen-driver.pl check-len.pl $(DISTDIR)/pipe

clean:
	rm -f psim pipe-*.c *.a *.o *.exe ldriver.* sdriver.* *.yo *~ *.exe



