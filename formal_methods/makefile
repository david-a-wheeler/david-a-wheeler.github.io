
all: openproofs-packaging.pdf

%.pdf: %.ps
	ps2pdf $< $@

%.ps: %.dot
	dot -Tps $< > $@

