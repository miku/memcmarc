package main

import (
	"errors"
	"flag"
	"fmt"
	"io"
	"log"
	"os"
	"runtime"
	"sync"
	"time"

	"github.com/bradfitz/gomemcache/memcache"
	"github.com/ubleipzig/marctools"
)

const (
	version = "1.2.0"
	backoff = 50 * time.Millisecond
)

var errSetFailed = errors.New("cache set failed")

type work struct {
	blob []byte
	id   string
}

type options struct {
	hostport string
	retry    uint
	verbose  bool
}

func worker(queue chan []work, opts options, wg *sync.WaitGroup) {
	defer wg.Done()
	mc := memcache.New(opts.hostport)
	for batch := range queue {
		for _, work := range batch {
			ok := false
			var i uint

			for i = 1; i <= opts.retry; i++ {
				err := mc.Set(&memcache.Item{Key: work.id, Value: work.blob})
				if err != nil {
					pause := 2 << i * backoff
					if opts.verbose {
						log.Printf("retry %d for %s in %s ...", i, work.id, pause)
					}
					time.Sleep(pause)
				} else {
					ok = true
					break
				}
			}
			if !ok {
				log.Fatal(errSetFailed)
			}
		}
	}
}

func main() {

	hostport := flag.String("addr", "127.0.0.1:11211", "hostport of memcache")
	retry := flag.Int("retry", 10, "retry set operation this many times")
	numWorker := flag.Int("w", runtime.NumCPU(), "number of workers")
	size := flag.Int("b", 10000, "batch size")
	verbose := flag.Bool("verbose", false, "be verbose")
	showVersion := flag.Bool("v", false, "prints current program version")

	flag.Parse()

	runtime.GOMAXPROCS(*numWorker)

	if *showVersion {
		fmt.Println(version)
		os.Exit(0)
	}

	if flag.NArg() < 1 {
		log.Fatal("input file or files required")
	}

	opts := options{
		hostport: *hostport,
		retry:    uint(*retry),
		verbose:  *verbose,
	}

	queue := make(chan []work)
	var wg sync.WaitGroup

	for i := 0; i < *numWorker; i++ {
		wg.Add(1)
		go worker(queue, opts, &wg)
	}

	var batch []work
	var counter int

	for _, filename := range flag.Args() {

		var offset int64
		var i int

		file, err := os.Open(filename)
		if err != nil {
			log.Fatal(err)
		}

		ids := marctools.IDList(file.Name())

		for {
			length, err := marctools.RecordLength(file)
			if err == io.EOF {
				break
			}
			if err != nil {
				log.Fatal(err)
			}

			file.Seek(offset, 0)
			buf := make([]byte, length)
			_, err = file.Read(buf)
			if err != nil {
				log.Fatal(err)
			}

			batch = append(batch, work{id: ids[i], blob: buf})

			if i%*size == 0 {
				b := make([]work, len(batch))
				copy(b, batch)
				queue <- b
				if *verbose {
					log.Printf("@%d", i)
				}
				batch = batch[:0]
			}

			offset = offset + length
			i++
			counter++
		}
	}

	b := make([]work, len(batch))
	copy(b, batch)
	queue <- b
	if *verbose {
		log.Printf("@%d", counter)
	}

	close(queue)
	wg.Wait()
}
