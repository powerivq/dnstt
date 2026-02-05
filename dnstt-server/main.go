package main

import (
	"flag"
	"fmt"
	"log"
	"net"
	"os"
)

func main() {
	var udpAddr string
	var domain string
	var forwardAddr string

	flag.StringVar(&udpAddr, "udp", ":5300", "UDP address to listen on")
	flag.StringVar(&domain, "domain", "", "DNS domain to serve")
	flag.StringVar(&forwardAddr, "forward", "127.0.0.1:8000", "Address to forward connections to")
	flag.Parse()

	if domain == "" {
		fmt.Fprintf(os.Stderr, "the -domain option is required\n")
		flag.Usage()
		os.Exit(1)
	}

	log.Printf("Starting dnstt server")
	log.Printf("Listening on UDP %s", udpAddr)
	log.Printf("Domain: %s", domain)
	log.Printf("Forward to: %s", forwardAddr)

	addr, err := net.ResolveUDPAddr("udp", udpAddr)
	if err != nil {
		log.Fatalf("Failed to resolve UDP address: %v", err)
	}

	conn, err := net.ListenUDP("udp", addr)
	if err != nil {
		log.Fatalf("Failed to listen on UDP: %v", err)
	}
	defer conn.Close()

	log.Printf("Server running")

	// Simple echo server for demonstration
	buf := make([]byte, 2048)
	for {
		n, remoteAddr, err := conn.ReadFromUDP(buf)
		if err != nil {
			log.Printf("Error reading: %v", err)
			continue
		}

		log.Printf("Received %d bytes from %s", n, remoteAddr)

		// Echo back
		_, err = conn.WriteToUDP(buf[:n], remoteAddr)
		if err != nil {
			log.Printf("Error writing: %v", err)
		}
	}
}
