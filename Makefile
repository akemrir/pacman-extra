package = pacman-extra
distfiles = pkgrepo.sh rank-mirrorlist.sh checkupdate.sh Makefile \
            DEPENDS README

prefix = /usr/local
exec_prefix = $(prefix)
bindir = $(exec_prefix)/bin

.PHONY: all check dist clean distclean install uninstall

all:

check:

dist:
	rm -R -f $(package) $(package).tar $(package).tar.gz
	mkdir $(package)
	cp -f $(distfiles) $(package)
	tar -c -f $(package).tar $(package)
	gzip $(package).tar
	rm -R -f $(package) $(package).tar

clean:
	rm -R -f $(package) $(package).tar $(package).tar.gz

distclean: clean

install: all
	mkdir -p $(DESTDIR)$(bindir)
	cp -f pkgrepo.sh $(DESTDIR)$(bindir)/pkgrepo
	chmod +x $(DESTDIR)$(bindir)/pkgrepo
	cp -f rank-mirrorlist.sh $(DESTDIR)$(bindir)/rank-mirrorlist
	chmod +x $(DESTDIR)$(bindir)/rank-mirrorlist
	cp -f checkupdate.sh $(DESTDIR)$(bindir)/checkupdate
	chmod +x $(DESTDIR)$(bindir)/checkupdate

uninstall:
	rm -f $(DESTDIR)$(bindir)/checkupdate \
	      $(DESTDIR)$(bindir)/rank-mirrorlist \
	      $(DESTDIR)$(bindir)/pkgrepo
