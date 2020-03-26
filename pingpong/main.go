package main

import (
	"crypto/tls"
	"crypto/x509"
	"flag"
	"html/template"
	"io/ioutil"
	"log"
	"net/http"
	"strings"
	"time"
)

const indexFile = `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>TLS Ping Pong</title>
</head>
<body>
    <p>
		{{.Endpoint}} replied with the following certificate:
		<ul>
			<li>Server name: {{.ServerNames}}</li>
			<li>Issuer: {{.Issuer}}</li>
			<li>Serial: {{.Serial}}</li>
			<li>Expiry date: {{.NotValidAfter}}</li>
		</ul>
	</p>
</body>
</html>
`

type templateData struct {
	Endpoint      string
	ServerNames   string
	Issuer        string
	Serial        string
	NotValidAfter time.Time
}

var (
	endpoint   string
	caFile     string
	certFile   string
	keyFile    string
	caCertPool = x509.NewCertPool()
)

func main() {
	flag.StringVar(&endpoint, "endpoint", "", "Endpoint to contact and get certificate info from, e.g. https://jetstack.io/")
	flag.StringVar(&caFile, "ca-file", "", "PEM file with the CA")
	flag.StringVar(&certFile, "cert-file", "", "PEM file with the server certificate")
	flag.StringVar(&keyFile, "key-file", "", "File with the server private key")
	flag.Parse()

	if endpoint == "" || caFile == "" || certFile == "" || keyFile == "" {
		log.Fatal("Needs -endpoint, -ca-file, -cert-file and -key-file flags")
	}

	http.HandleFunc("/", serveRoot)
	http.HandleFunc("/ping", servePing)

	caCert, err := ioutil.ReadFile(caFile)
	if err != nil {
		log.Fatal(err)
	}
	caCertPool.AppendCertsFromPEM(caCert)

	// Configuring TLS Client auth
	// Currently disabled
	/*
		tlsConfig := &tls.Config{
			ClientCAs:  caCertPool,
			ClientAuth: tls.RequireAndVerifyClientCert,
		}
		server := &http.Server{
			Addr:      ":8443",
			TLSConfig: tlsConfig,
		}
		go func() {
			log.Fatal(server.ListenAndServeTLS(certFile, keyFile)) // run internal TLS auth only endpoint
		}()

	*/

	log.Fatal(http.ListenAndServeTLS(":9443", certFile, keyFile, nil)) // run browser accessible endpoint to show info
}

func serveRoot(w http.ResponseWriter, r *http.Request) {
	tmpl, err := template.New("index").Parse(indexFile)
	if err != nil {
		// template file is hard coded as a constant, this should not fail
		log.Println(err)
	}

	resp, err := callServer()
	if err != nil {
		log.Println(err)
		return
	}

	err = tmpl.Execute(w, templateData{
		Endpoint:      endpoint,
		ServerNames:   strings.Join(resp.TLS.PeerCertificates[0].DNSNames, ", "),
		Issuer:        resp.TLS.PeerCertificates[0].Issuer.CommonName,
		Serial:        resp.TLS.PeerCertificates[0].SerialNumber.String(),
		NotValidAfter: resp.TLS.PeerCertificates[0].NotAfter,
	})
	if err != nil {
		log.Println(err)
		return
	}
}

func servePing(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("pong"))
}

func callServer() (*http.Response, error) {
	// Load client cert
	/*cert, err := tls.LoadX509KeyPair(certFile, keyFile)
	if err != nil {
		return nil, err
	}*/

	// Setup HTTPS client
	tlsConfig := &tls.Config{
		//Certificates: []tls.Certificate{cert},
		RootCAs: caCertPool,
	}
	tlsConfig.BuildNameToCertificate()
	c := &http.Client{
		Transport: &http.Transport{
			TLSClientConfig: tlsConfig,
		},
	}

	return c.Get(endpoint)
}
