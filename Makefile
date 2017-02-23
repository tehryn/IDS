build:
	latex dokumentace.tex
	latex dokumentace.tex
	dvips dokumentace.dvi
	ps2pdf -sPAPERSIZE=a4 dokumentace.ps
