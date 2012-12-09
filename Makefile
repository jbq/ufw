SRCS     = src/ufw $(wildcard src/*.py)
POTFILES = locales/po/ufw.pot
TMPDIR   = ./tmp
EXCLUDES = --exclude='.bzr*' --exclude='*~' --exclude='*.swp' --exclude='*.pyc' --exclude='debian' --exclude='ubuntu'
VERSION  = $(shell egrep '^ufw_version' ./setup.py | cut -d "'" -f 2)
SRCVER   = ufw-$(VERSION)
TARBALLS = ../tarballs
TARSRC   = $(TARBALLS)/$(SRCVER)
TARDST   = $(TARBALLS)/$(SRCVER).tar.gz
PYFLAKES = $(TMPDIR)/pyflakes.out
PYFLAKES_EXE = pyflakes

all:
	# Use setup.py to install. See README for details
	exit 1

install: all

translations: $(POTFILES)
$(POTFILES): $(SRCS)
	xgettext -d ufw -L Python -o $@ $(SRCS)

mo:
	make -C locales all

test:
	./run_tests.sh -s

syntax-check: clean
	$(shell mkdir $(TMPDIR) && $(PYFLAKES_EXE) src 2>&1 | grep -v "undefined name '_'" > $(PYFLAKES))
	cat "$(PYFLAKES)"
	test ! -s "$(PYFLAKES)"

man-check: clean
	$(shell mkdir $(TMPDIR) 2>/dev/null)
	for manfile in `ls doc/*.8`; do \
		page=$$(basename $$manfile); \
		manout=$(TMPDIR)/$$page.out; \
		echo "Checking $$page for errors... "; \
		PAGER=cat LANG='en_US.UTF-8' MANWIDTH=80 man --warnings -E UTF-8 -l doc/$$page >/dev/null 2> "$$manout"; \
		cat "$$manout"; \
		test ! -s "$$manout" || exit 1; \
		echo "PASS"; \
	done; \

check: syntax-check man-check test

# These are only used in development
clean:
	rm -rf ./build
	rm -rf ./staging
	rm -rf ./tests/testarea
	rm -rf $(TMPDIR)
	rm -f ./locales/mo/*.mo

evaluate: clean
	mkdir -p $(TMPDIR)/ufw/usr $(TMPDIR)/ufw/etc
	python ./setup.py install --home=$(TMPDIR)/ufw
	PYTHONPATH=$(PYTHONPATH):$(TMPDIR)/ufw/lib/python $(TMPDIR)/ufw/usr/sbin/ufw version
	sed -i 's/self.do_checks = True/self.do_checks = False/' $(TMPDIR)/ufw/lib/python/ufw/backend.py
	cp ./examples/* $(TMPDIR)/ufw/etc/ufw/applications.d
	# Test with:
	# PYTHONPATH=$$PYTHONPATH:$(TMPDIR)/ufw/lib/python $(TMPDIR)/ufw/usr/sbin/ufw ...
	# sudo sh -c "PYTHONPATH=$$PYTHONPATH:$(TMPDIR)/ufw/lib/python $(TMPDIR)/ufw/usr/sbin/ufw ..."

devel: evaluate
	cp -f ./tests/defaults/profiles/* $(TMPDIR)/ufw/etc/ufw/applications.d
	cp -f ./tests/defaults/profiles.bad/* $(TMPDIR)/ufw/etc/ufw/applications.d

debug: devel
	sed -i 's/DEBUGGING = False/DEBUGGING = True/' $(TMPDIR)/ufw/lib/python/ufw/util.py

tarball: syntax-check clean translations
	bzr export --format dir $(TARSRC)
	tar -zcv -C $(TARBALLS) $(EXCLUDES) -f $(TARDST) $(SRCVER)
	rm -rf $(TARSRC)

