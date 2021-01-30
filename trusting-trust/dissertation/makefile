# Makefile.  Uses GNU make.


INTERPFORMAT = prover9-interpformat

INDEPENDENCE= \
ddc-independence-1.cooked \
ddc-independence-2.cooked \
ddc-independence-3.cooked \
ddc-independence-4.cooked \
ddc-independence-5.cooked \
all-repeats-independence-1.cooked \
all-repeats-independence-2.cooked \
all-repeats-independence-3.cooked \
all-repeats-independence-4.cooked \
all-repeats-independence-5.cooked \
all-repeats-independence-6.cooked \
all-repeats-independence-7.cooked \
all-repeats-independence-8.cooked \
all-repeats-independence-9.cooked \
cP-corresponds-sP-independence-1.cooked \
cP-corresponds-sP-independence-2.cooked \
cP-corresponds-sP-independence-3.cooked

all: ddc.pdf repeats.pdf lemma-stage1-cp.pdf lemma-sp.pdf all-repeats.pdf ddc-equivalence.pdf $(INDEPENDENCE)

%.out: %.in
	rm -f $*.proof
	-(prover9 -t 60 -f $+ > $@ && \
         prooftrans expand renumber -f $@ > $*.proof && \
         prooftrans xml expand renumber -f $@ > $*.xml )

%.mout: %.in
	# For most "-n 2" works fine.
	# mace4 -c -f $+ > $@.temp
	mace4 -n 6 -N 10 -b 3000 -c -f $+ > $@.temp
	# If that succeeded, then create the new mout file.
	mv $@.temp $@

%.cooked: %.mout
	$(INTERPFORMAT) tabular -f $< > $*.tabular
	$(INTERPFORMAT) cooked -f $< > $*.cooked

.PRECIOUS: %.out %.mout

%.all: %.out %.mout
	@

%.xml: %.out

%.dot: %.xml
	./gvizify $+ > $*.dot

# Some versions of "dot" don't support pdf as direct output.
# Also, there's a bug somewhere that creates bogus eps files (and then
# bogus pdf files); fix this by
# running eps2eps, to make the ps file regular.
%.ps: %.dot
	dot -Tps $+ -o $@

%.svg: %.dot
	dot -Tsvg $+ -o $@

%.big.dot: %.xml
	GVIZIFY='--rotation=0 --relax --size=42,42' ./gvizify $+ > $*.big.dot

%.big.ps: %.big.dot
	dot -Tps $+ -o $@

# Do "man gs" to see ghostscript options.
%.big.pdf: %.big.ps
	ps2pdf -g25200x12600 -r600 $+ $@

%.mungedps: %.ps
	eps2eps $+ $@


#	dot -Tps2 $+ -o $@

%.pdf: %.mungedps
	ps2pdf $+ $@

%.ivy: %.out
	prooftrans ivy renumber -f $+ > $@

# %.pdf: %.dot
# 	dot -Tpdf $+ -o $@

%.html: %.xml
	xsltproc proof3.xsl $+ > $@

sqrt2.html: sqrt2.xml proof3.xsl proof3.dtd
	xsltproc proof3.xsl sqrt2.xml > sqrt2.html

# "make commit" commits all changes. Before doing this,
# do "git add FILENAMES" if a file has been added that isn't under SCM.
# Message file isn't in current directory, because "git commit --all" would
# then include it.
commit:
	(echo "One-line summary" ; echo ; echo "Details." ; git diff ) > /tmp/message.$$ ; vi /tmp/message.$$ ; git commit --all -F /tmp/message.$$

print-old:
	enscript --no-header summary-proofs
	lp ddc.ps lemma-sp.ps lemma-stage1-cp.ps repeats.ps \
		all-repeats.ps cP-corresponds-sP.ps
print:
	enscript --no-header summary-proofs
	lp ddc.ps all-repeats.ps cP-corresponds-sP.ps

bigprint:  ddc.big.ps all-repeats.big.ps cP-corresponds-sP.big.ps
	lp ddc.big.ps all-repeats.big.ps cP-corresponds-sP.big.ps

proof-package.zip: all-repeats.ps cP-corresponds-sP.ps ddc.ps lemma-sp.ps lemma-stage1-cp.ps repeats.ps
	rm -f proof-package.zip	
	zip proof-package.zip \
		summary-proofs \
		all-repeats.ps cP-corresponds-sP.ps ddc.ps lemma-sp.ps lemma-stage1-cp.ps repeats.ps \
		all-repeats.in cP-corresponds-sP.in ddc.in lemma-sp.in lemma-stage1-cp.in repeats.in \
		all-repeats.out cP-corresponds-sP.out ddc.out lemma-sp.out lemma-stage1-cp.out repeats.out \
		all-repeats.xml cP-corresponds-sP.xml ddc.xml lemma-sp.xml lemma-stage1-cp.xml repeats.xml \
		proof3.xsl

