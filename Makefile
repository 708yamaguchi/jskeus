all: eus-installed irteus-installed bashrc.eus manuals

SVN_EUSURL=https://euslisp.svn.sourceforge.net/svnroot/euslisp/trunk/EusLisp
SVN_IRTEUSURL=https://jskeus.svn.sourceforge.net/svnroot/jskeus/trunk/irteus

EUSC_PATCH=eus.c_CUSTUM_EUSDIR.patch

MACHINE=$(shell uname -m)
OS=$(shell uname -s)
ifeq ($(OS),Linux)
 ifeq ($(MACHINE),x86_64)
  export ARCHDIR=Linux64
  export MAKEFILE=Makefile.Linux64
 else
  export ARCHDIR=Linux
  export MAKEFILE=Makefile.Linux.thread
 endif
endif
ifeq ($(OS),Cygwin)
 export ARCHDIR=Cygwin
 export MAKEFILE=Makefile.Cygwin
endif

export EUSDIR=$(shell pwd)/eus

manuals: manual.pdf jmanual.pdf
manual.pdf:
	wget http://euslisp.svn.sourceforge.net/viewvc/euslisp/trunk/EusLisp/doc/latex/manual.pdf -O manual.pdf

jmanual.pdf:
	wget http://euslisp.svn.sourceforge.net/viewvc/euslisp/trunk/EusLisp/doc/jlatex/jmanual.pdf -O jmanual.pdf

bashrc.eus:
	@echo "#\n\
# bashrc.eus : environment variable for euslisp \n#\n\
export EUSDIR=$(EUSDIR) \n\
export ARCHDIR=$(ARCHDIR) \n\
export PATH=\$$EUSDIR/\$$ARCHDIR/bin:\$$PATH \n\
export LD_LIBRARY_PATHPATH=\$$EUSDIR/\$$ARCHDIR/bin:\$$LD_LIBRARY_PATH \n\
" > bashrc.eus
	@bash -c 'echo -e "\e[1;32m;; generating bashrc.eus ...\n;;\e[m"'
	@bash -c 'echo -e "\e[1;32m;; Please move bashrc.eus to ~/bashrc.eus\e[m"'
	@bash -c 'echo -e "\e[1;32m;;   and include \"source bashrc.eus\" in your .bashrc file\e[m"'
	@cat bashrc.eus

eus:
	# 'svn propget svn:externals .' to see the details
	mkdir eus
	svn co $(SVN_EUSURL)/lisp eus/lisp
	svn co -N $(SVN_EUSURL)/lib eus/lib; cd eus/lib; svn up llib

rm-lib-dir:
	# remove unsupported directories
	@if [ -e eus/lib/clib -o -e eus/lib/demo -o -e eus/lib/bitmaps ]; then\
		svn up -q --set-depth files eus/lib/; \
		svn up -q eus/lib/llib; \
	fi

eus-installed: eus rm-lib-dir
	cd eus/lisp && ln -sf $(MAKEFILE) Makefile && make eus0 eus1 eus2 eusg eusx eusgl eus

irteus:
	svn up irteus

irteus-installed: irteus
	cd irteus; make

clean:
	-rm bashrc.eus manual.pdf jmanual.pdf
	if [ -e irteus ]; then cd irteus; make clean ; fi
	if [ -e eus/lisp ]; then cd eus/lisp; make clean ; fi

wipe: clean
	-rm -fr eus irteus

