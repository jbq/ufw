all:
	for pofile in `ls po/*.po`; do \
		lang=$$(basename $$pofile .po); \
		echo "msgfmt -c -o mo/$$lang.mo po/$$lang.po"; \
		formatted=`msgfmt -c -o mo/$$lang.mo po/$$lang.po 2>&1 | grep fatal` ; \
		if [ "$$formatted" != "" ]; then \
			exit 1; \
		fi; \
	done; \

# These are only used in development
clean:
	rm -rf ./*.mo
