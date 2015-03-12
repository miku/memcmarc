TARGETS = memcmarc

all: $(TARGETS)

memcmarc: imports
	go build -o memcmarc cmd/memcmarc/main.go

imports:
	goimports -w .

clean:
	rm -f $(TARGETS)
	rm -f memcmarc_*deb
	rm -f memcmarc-*rpm
	rm -rf ./packaging/deb/memcmarc/usr

deb: $(TARGETS)
	mkdir -p packaging/deb/memcmarc/usr/sbin
	cp $(TARGETS) packaging/deb/memcmarc/usr/sbin
	cd packaging/deb && fakeroot dpkg-deb --build memcmarc .
	mv packaging/deb/memcmarc_*.deb .

rpm: $(TARGETS)
	mkdir -p $(HOME)/rpmbuild/{BUILD,SOURCES,SPECS,RPMS}
	cp ./packaging/rpm/memcmarc.spec $(HOME)/rpmbuild/SPECS
	cp $(TARGETS) $(HOME)/rpmbuild/BUILD
	./packaging/rpm/buildrpm.sh memcmarc
	cp $(HOME)/rpmbuild/RPMS/x86_64/memcmarc*.rpm .

cloc:
	cloc --max-file-size 1 .
