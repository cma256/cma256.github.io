{
  description = "TLS termination example: nginx terminates TLS in front of a plaintext TCP echo server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        python = pkgs.python3;

        gen-certs = pkgs.writeShellApplication {
          name = "gen-certs";
          runtimeInputs = [ pkgs.openssl ];
          text = ''
            mkdir -p certs logs
            openssl req -x509 \
              -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 \
              -keyout certs/server.key \
              -out certs/server.crt \
              -days 365 -nodes \
              -subj "/CN=localhost" \
              -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"
            echo "wrote certs/server.key and certs/server.crt"
          '';
        };

        proxy = pkgs.writeShellApplication {
          name = "proxy";
          runtimeInputs = [ pkgs.nginx ];
          text = ''
            mkdir -p logs
            exec nginx -p "$PWD" -e logs/error.log -c nginx.conf
          '';
        };

        server = pkgs.writeShellApplication {
          name = "server";
          runtimeInputs = [ python ];
          text = ''
            exec python -u src/tls_example/server.py "$@"
          '';
        };

        client = pkgs.writeShellApplication {
          name = "client";
          runtimeInputs = [ python ];
          text = ''
            exec python -u src/tls_example/client.py "$@"
          '';
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            python
            pkgs.nginx
            pkgs.openssl
            pkgs.uv
          ];
        };

        apps = {
          gen-certs = {
            type = "app";
            program = "${gen-certs}/bin/gen-certs";
          };
          proxy = {
            type = "app";
            program = "${proxy}/bin/proxy";
          };
          server = {
            type = "app";
            program = "${server}/bin/server";
          };
          client = {
            type = "app";
            program = "${client}/bin/client";
          };
        };
      });
}
