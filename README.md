README
======

Load MARC blobs into [memcached](http://memcached.org/) or
[memcachedb](http://memcachedb.org/) quickly. Given an
[MARC](http://www.loc.gov/marc/bibliographic/) file,
use value of field 001 as key and the whole binary record as blob value.

Installation
------------

    $ go get github.com/miku/memcmarc/cmd/memcmarc

Or install via [debian or rpm packages](https://github.com/miku/memcmarc/releases).

Usage
-----

    $ memcmarc FILE [FILE, ...]
    Usage of memcmarc:
      -addr="127.0.0.1:11211": hostport of memcache
      -b=10000: batch size
      -key="id": key to use
      -retry=10: retry set operation this many times
      -v=false: prints current program version
      -verbose=false: be verbose
      -w=4: number of workers

Example
-------

Start memcached (or memcachedb):

    $ memcached

Load records:

    $ memcmarc fixtures/journals.mrc

Check:

    $ telnet localhost 11211
    Trying ::1...
    Connected to localhost.
    Escape character is '^]'.
    get testsample10
    VALUE testsample10 0 1195
    01195cas a22003251a 45  0010013000000050017000130070016000300080041000
    4601000170008702200140010403000110011803500160012903700100014504000530
    0155050001800208090001700226210002800243222004300271245004400314260005
    1003583000017004093620024004265000035004505060066004855300042005516500
    04600593710002000639856009300659856011700752testsample1020091117093002
    .0cr  bn ---|||||751002c19709999njufr1p       0   a0eng    a   7564307
    6 0 a0047-2662  aJPHPAE  aocm02240975  b07716  aDLCcDLCdNSDdDLCdOCLdRC
    SdAIPdNSDdOCLdNST0 aAF204.5b.J68  aAF204.5b.J61 aJ. phenomenol. psycho
    l. 0aJournal of phenomenological psychology00aJournal of phenomenologi
    cal psychology.  a[Atlantic Highlands, N.J. :bHumanities Press]  av. ;
    c23 cm.0 aVol. 1 (fall 1970)-  aAt head of title <1974->: JPP.  aElect
    ronic access restricted to Villanova University patrons.  aAlso availa
    ble on the World Wide Web. 0aPhenomenological psychologyvPeriodicals.2
     aIngenta (Firm).41zOnline version [v. 1 (1970/71)-present]uhttp://www
    .ingentaconnect.com/content/brill/jpp41zOff-campus accessuhttp://open
    url.villanova.edu:9003/sfx_local?sid=sfx:e_collection&issn=0047-2662&
    genre=journal
    END
    ^]
    telnet> Connection closed.

See it action
-------------

[![asciicast](https://asciinema.org/a/ed64c7a69ts5s9ddfths0p1mr.png)](https://asciinema.org/a/ed64c7a69ts5s9ddfths0p1mr)
