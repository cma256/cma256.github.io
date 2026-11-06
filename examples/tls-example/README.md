# tls-example

TLS termination demo.

## Usage

```sh
# one-time: generate the self-signed cert into certs/
nix run .#gen-certs

# terminal 1: plaintext echo server on 127.0.0.1:9099
nix run .#server

# terminal 2: nginx TLS proxy on 127.0.0.1:8443
nix run .#proxy

# terminal 3: TLS client (interactive, or pass messages as args)
nix run .#client -- hello world
```