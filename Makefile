CC=lazbuild
ST=strip
bindir   = $(DESTDIR)/usr/bin
sharedir = $(DESTDIR)/usr/share

winkeyer_server: src/winkeyer_server.lpi
	$(CC) --ws=gtk2 src/winkeyer_server.lpi
	$(ST) src/winkeyer_server
#	gzip tools/cqrlog.1 -c > tools/cqrlog.1.gz

clean:
	rm -f -v src/*.o src/*.ppu src/*.bak src/lnet/lib/*.ppu src/lnet/lib/*.o src/lnet/lib/*.bak src/winkeyer_server src/winkeyer_server.compiled src/winkeyer_server.or
	rm -f -v src/*.lrs
#	rm -f -v tools/cqrlog.1.gz
	
install:
	install -d -v         $(bindir)
#	install -d -v         $(sharedir)/man/man1
	install    -v -m 0755 src/winkeyer_server $(bindir)
#	install    -v -m 0644 tools/cqrlog.1.gz $(sharedir)/man/man1/cqrlog.1.gz
#deb:
#	dpkg-buildpackage -rfakeroot -i -I
#deb_src:
#	dpkg-buildpackage -rfakeroot -i -I -S
