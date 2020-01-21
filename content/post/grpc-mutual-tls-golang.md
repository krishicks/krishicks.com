---
title: "Using gRPC with Mutual TLS in Golang"
date: "2016-11-01"
categories:
  - development
  - golang
summary: Example server and client code for using mutual TLS with gRPC.
---

So, you want to use [gRPC](http://www.grpc.io). Cool! And you want to use
[mutual TLS](https://en.wikipedia.org/wiki/Mutual_authentication), too. But
maybe, like me, you couldn't easily figure out how to accomplish this, given
the documentation and examples out there. Here's how I did it.

This example code uses a CA, certs, and private keys which were generated using
[certstrap](https://github.com/square/certstrap). Skip down
[below](#creating-test-ca-certs-private-keys) to see how to get and use
certstrap.

### Server Configuration

```
certificate, err := tls.LoadX509KeyPair(
  "out/example.com.crt",
  "out/example.com.key",
)

certPool := x509.NewCertPool()
bs, err := ioutil.ReadFile("out/My_Root_CA.crt")
if err != nil {
  log.Fatalf("failed to read client ca cert: %s", err)
}

ok := certPool.AppendCertsFromPEM(bs)
if !ok {
  log.Fatal("failed to append client certs")
}

lis, err := net.Listen("tcp", "127.0.0.1")
if err != nil {
  log.Fatalf("failed to listen: %s", err)
}

tlsConfig := &tls.Config{
  ClientAuth:   tls.RequireAndVerifyClientCert,
  Certificates: []tls.Certificate{certificate},
  ClientCAs:    certPool,
}

serverOption := grpc.Creds(credentials.NewTLS(tlsConfig))
server := grpc.NewServer(serverOption)

// register your server
```

### Client Configuration

```
certificate, err := tls.LoadX509KeyPair(
  "out/127.0.0.1.crt",
  "out/127.0.0.1.key",
)

certPool := x509.NewCertPool()
bs, err := ioutil.ReadFile("out/My_Root_CA.crt")
if err != nil {
  log.Fatalf("failed to read ca cert: %s", err)
}

ok := certPool.AppendCertsFromPEM(bs)
if !ok {
  log.Fatal("failed to append certs")
}

transportCreds := credentials.NewTLS(&tls.Config{
  ServerName:   "example.com",
  Certificates: []tls.Certificate{certificate},
  RootCAs:      certPool,
})

dialOption := grpc.WithTransportCredentials(transportCreds)
conn, err := grpc.Dial("example.com", dialOption)
if err != nil {
    log.Fatalf("failed to dial server: %s", err)
}
defer conn.Close()

// make your client
```

If your client certificate already has the CA concatenated to it, you can use
x509.ParseCertificate, as in the following gist:
https://gist.github.com/artyom/6897140

### Creating test CA, certs, private keys

For testing, or for deploying an application which only you will access, it
makes sense to generate a self-signed CA and self-signed certs.

Creating a self-signed CA, self-signed certs, and keys suitable for use in Go
is hard. Use [certstrap](https://github.com/square/certstrap) to make it
easier.

#### Get certstrap

```
$ git clone git@github.com:square/certstrap
$ cd certstrap
$ ./build
```

The following commands assume you run them within the directory you cloned
certstrap to.

#### Create a CA, server cert, and private key

*Note: `certstrap` will prompt you for a password. For testing, you may leave
it blank.*

```
$ bin/certstrap init --common-name "My Root CA"
Created out/My_Root_CA.key
Created out/My_Root_CA.crt
Created out/My_Root_CA.crl

$ bin/certstrap request-cert --domain mydomain.com
Created out/mydomain.com.key
Created out/mydomain.com.csr
```

If you're generating a cert for an IP, use the --ip flag, e.g. `--ip
127.0.0.1`. Golang will complain about "No IP SANs" otherwise.

```
$ bin/certstrap sign --CA "My Root CA" mydomain.com # or the IP
Created out/mydomain.com.crt from out/mydomain.com.csr signed by out/My_Root_CA.key
```

At this point you can choose to create a second CA for the client, or just use
the same CA to sign another csr. We'll use the same one for this example.

#### Create client cert and private key

```
$ bin/certstrap request-cert --ip 127.0.0.1
Created out/127.0.0.1.key
Created out/127.0.0.1.csr

$ bin/certstrap sign --CA "My Root CA" 127.0.0.1
Created out/127.0.0.1.crt from out/127.0.0.1.csr signed by out/My_Root_CA.key
```

Now you're ready to rock and roll. Head back to [server
configuration](#server-configuration) if you need to.
