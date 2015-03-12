README
======

Load MARC blobs into [memcached](http://memcached.org/) or
[memcachedb](http://memcachedb.org/) quickly. Given an
[MARC](http://www.loc.gov/marc/bibliographic/) file,
use value of field 001 as blob.

Installation
------------

    $ go get github.com/miku/memcmarc/cmd/memcmarc

Or install via [debian or rpm packages](https://github.com/miku/memcmarc/releases).

Usage
-----

    $ memcmarc
    Usage of memcmarc:
      -addr="127.0.0.1:11211": hostport of memcache
      -retry=10: retry set operation this many times
      -verbose=false: be verbose
