package main

import (
	"flag"
	"fmt"
	"log"
	"net"
	"os"
)

func main() {
	var dohURL string
	var domain string
	var listenAddr string

	flag.StringVar(&dohURL, "doh", "", "DoH resolver URL")
	flag.StringVar(&domain, "domain", "", "DNS domain to use")
	flag.StringVar(&listenAddr, "listen", "127.0.0.1:7000", "Local address to listen on")
	flag.Parse()

	if domain == "" {
		fmt.Fprintf(os.Stderr, "the -domain option is required\n")
		flag.Usage()
		os.Exit(1)
	}

	log.Printf("Starting dnstt client")
	log.Printf("DoH URL: %s", dohURL)
	log.Printf("Domain: %s", domain)
	log.Printf("Listen on: %s", listenAddr)

	listener, err := net.Listen("tcp", listenAddr)
	if err != nil {
		log.Fatalf("Failed to listen: %v", err)
	}
	defer listener.Close()

	log.Printf("Client running")

	for {
		conn, err := listener.Accept()
		if err != nil {
			log.Printf("Error accepting connection: %v", err)
			continue
		}

		go handleConnection(conn)
	}
}

func handleConnection(conn net.Conn) {
	defer conn.Close()
	log.Printf("New connection from %s", conn.RemoteAddr())

	buf := make([]byte, 4096)
	for {
		n, err := conn.Read(buf)
		if err != nil {
			return
		}

		log.Printf("Read %d bytes", n)

		_, err = conn.Write(buf[:n])
		if err != nil {
			return
		}
	}
}
