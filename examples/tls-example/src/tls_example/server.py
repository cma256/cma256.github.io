import socket

HOST = "127.0.0.1"
PORT = 9099


def main() -> None:
    print(f"[server] plaintext echo server listening on {HOST}:{PORT}")
    with socket.create_server((HOST, PORT), reuse_port=True) as srv:
        while True:
            conn, _ = srv.accept()
            with conn:
                while data := conn.recv(4096):
                    conn.sendall(data)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n[server] shutting down")
