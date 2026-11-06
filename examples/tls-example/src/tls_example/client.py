import pathlib
import socket
import ssl
import sys

HOST = "localhost"
PORT = 8443
CA_CERT = pathlib.Path(__file__).resolve().parents[2] / "certs" / "server.crt"


def echo(tls: ssl.SSLSocket, message: str) -> None:
    tls.sendall(message.encode())
    reply = tls.recv(4096)
    print(f"[client] {reply}")


def main() -> None:
    if not CA_CERT.exists():
        sys.exit(f"missing {CA_CERT}; run `nix run .#gen-certs` first")

    ctx = ssl.create_default_context(cafile=str(CA_CERT))

    with (
        socket.create_connection((HOST, PORT)) as sock,
        ctx.wrap_socket(sock, server_hostname=HOST) as tls,
    ):
        for message in sys.argv[1:]:
            echo(tls, message)


if __name__ == "__main__":
    main()
