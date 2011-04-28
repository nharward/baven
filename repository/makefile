# Builds MD5 and SHA1 hashes

all: checksums

prep: checksums cleanrepo

checksums: md5 sha1

md5: $(patsubst %.bash,%.bash.md5,$(wildcard *.bash))

sha1: $(patsubst %.bash,%.bash.sha1,$(wildcard *.bash))

clean:
	rm -f *.md5 *.sha1

cleanrepo:
	rm -rf $(HOME)/.baven/repository

%.bash.md5: %.bash
	md5sum $< > $@

%.bash.sha1: %.bash
	sha1sum $< > $@

.SUFFIXES: .bash.md5 .bash.sha1
