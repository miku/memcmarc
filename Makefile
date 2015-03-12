TARGETS = memcmarc

all: $(TARGETS)

memcmarc:
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

# TODO: outsource vm setup to vagrant public registy
USERDIR=/home/vagrant/src/github.com/miku
PROJECTDIR=$(USERDIR)/memcmarc
PORT = 2222
SSHCMD = ssh -o StrictHostKeyChecking=no -i vagrant.key vagrant@127.0.0.1 -p $(PORT)
SCPCMD = scp -o port=$(PORT) -o StrictHostKeyChecking=no -i vagrant.key

vagrant.key:
	curl -sL "https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant" > vagrant.key
	chmod 0600 vagrant.key

setup: vagrant.key
	vagrant up
	$(SSHCMD) "sudo yum install -y http://ftp.riken.jp/Linux/fedora/epel/6/i386/epel-release-6-8.noarch.rpm"
	$(SSHCMD) "sudo yum install -y golang git rpm-build"
	$(SSHCMD) "mkdir -p cd $(USERDIR)"
	$(SSHCMD) "cd $(USERDIR) && git clone https://github.com/miku/memcmarc.git"

rpm-compatible: vagrant.key
	$(SSHCMD) "cd $(PROJECTDIR) && GOPATH=/home/vagrant go get ./..."
	$(SSHCMD) "cd $(PROJECTDIR) && git pull origin master && pwd && GOPATH=/home/vagrant make clean rpm"
	$(SCPCMD) vagrant@127.0.0.1:$(PROJECTDIR)/*rpm .
