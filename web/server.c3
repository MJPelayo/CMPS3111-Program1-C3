
module web::server;

import std::io;
import std::net::tcp;

fn void main()
{
    io::printn("==================================================");
    io::printn("       CMPS 3111 LANGUAGE RECOGNIZER");
    io::printn("              C3 WEB SERVER");
    io::printn("==================================================");
    io::printn("");

    io::printn("Starting server on http://127.0.0.1:8080 ...");

    tcp::TcpServerSocket server =
        tcp::listen("127.0.0.1", 8080, 10)!!;

    io::printn("Server started successfully.");
    io::printn("Waiting for a browser connection...");
    io::printn("");

    while (true)
    {
        tcp::TcpSocket client =
            tcp::accept(&server)!!;

        io::printn("Client connected.");

        handle_client(&client);

        client.close()!!;

        io::printn("Client connection closed.");
        io::printn("Waiting for another connection...");
        io::printn("");
    }
}

fn void handle_client(tcp::TcpSocket* client)
{
    char[8192] request_buffer;

    sz? bytes_read =
        client.read(request_buffer[..]);

    if (catch bytes_read)
    {
        io::printn("Could not read HTTP request.");
        return;
    }

    io::printn("HTTP request received.");

    String body =
        "<!DOCTYPE html>"
        "<html>"
        "<head>"
        "<meta charset=\"UTF-8\">"
        "<title>CMPS 3111 Language Recognizer</title>"
        "</head>"
        "<body>"
        "<h1>CMPS 3111 Language Recognizer</h1>"
        "<p>C3 web server is running successfully.</p>"
        "</body>"
        "</html>";

    String response =
        string::tformat(
            "HTTP/1.1 200 OK\r\n"
            "Content-Type: text/html; charset=UTF-8\r\n"
            "Content-Length: %d\r\n"
            "Connection: close\r\n"
            "\r\n"
            "%s",
            body.len,
            body
        );

    client.write(response)!!;

    io::printn("HTTP response sent.");
}

