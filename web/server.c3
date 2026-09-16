module web::server;

import std::io;
import std::net::tcp;
import validator;
import derivation;
import parse_tree;


// ============================================================
// MAIN SERVER
// ============================================================

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
    io::printn("Serving files from web/public/");
    io::printn("API endpoint: /api/recognize");
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


// ============================================================
// HANDLE HTTP REQUEST
// ============================================================

fn void handle_client(tcp::TcpSocket* client)
{
    char[16384] request_buffer;

    sz? bytes_read =
        client.read(request_buffer[..]);

    if (catch bytes_read)
    {
        io::printn("Could not read HTTP request.");
        return;
    }

    io::printn("HTTP request received.");

    String request =
        (String)request_buffer[..bytes_read];

    String path =
        get_request_path(request);

    io::print("Requested path: ");
    io::printn(path);


    // --------------------------------------------------------
    // API endpoint
    // --------------------------------------------------------

    if (path == "/api/recognize")
    {
        handle_recognize(client, request);
        return;
    }


    // --------------------------------------------------------
    // Static files
    // --------------------------------------------------------

    String body;
    String content_type;

    if (path == "/")
    {
        body = read_file("web/public/index.html");
        content_type = "text/html; charset=UTF-8";
    }
    else if (path == "/style.css")
    {
        body = read_file("web/public/style.css");
        content_type = "text/css; charset=UTF-8";
    }
    else if (path == "/script.js")
    {
        body = read_file("web/public/script.js");
        content_type = "application/javascript; charset=UTF-8";
    }
    else if (path == "/favicon.ico")
    {
        send_not_found(client, path);
        return;
    }
    else
    {
        send_not_found(client, path);
        return;
    }


    if (body.len == 0)
    {
        send_error(client, path);
        return;
    }


    String response =
        string::tformat(
            "HTTP/1.1 200 OK\r\n"
            "Content-Type: %s\r\n"
            "Content-Length: %d\r\n"
            "Connection: close\r\n"
            "\r\n"
            "%s",
            content_type,
            body.len,
            body
        );


    client.write(response)!!;

    io::print("Sent: ");
    io::printn(path);
}


// ============================================================
// RECOGNIZE API
// ============================================================

fn void handle_recognize(
    tcp::TcpSocket* client,
    String request
)
{
    io::printn("Processing recognition request.");


    String input =
        extract_json_input(request);


    // --------------------------------------------------------
    // Missing input
    // --------------------------------------------------------

    if (input.len == 0)
    {
        send_json_error(
            client,
            "No program input was supplied."
        );

        return;
    }


    // --------------------------------------------------------
    // Validate complete program
    // --------------------------------------------------------

    bool program_valid =
        validator::validate_program(input);


    // --------------------------------------------------------
    // Build individual instruction results
    // --------------------------------------------------------

    String instruction_results =
        build_instruction_results(input);


    // --------------------------------------------------------
    // Invalid program
    // --------------------------------------------------------

    if (!program_valid)
    {
        String program_error =
            validator::get_program_error(input);


        String response_body =
            string::tformat(
                "{"
                "\"valid\":false,"
                "\"instructionResults\":[%s],"
                "\"error\":\"%s\","
                "\"derivation\":\"\","
                "\"parseTree\":\"\""
                "}",
                instruction_results,
                json_escape(program_error)
            );


        send_json(
            client,
            response_body,
            "200 OK"
        );


        io::printn("Recognition result: INVALID");

        return;
    }


    // --------------------------------------------------------
    // Valid program
    // --------------------------------------------------------

    String derivation_output =
        build_derivation(input);


    String parse_tree_output =
        build_parse_tree(input);


    String response_body =
        string::tformat(
            "{"
            "\"valid\":true,"
            "\"instructionResults\":[%s],"
            "\"error\":\"\","
            "\"derivation\":\"%s\","
            "\"parseTree\":\"%s\""
            "}",
            instruction_results,
            json_escape(derivation_output),
            json_escape(parse_tree_output)
        );


    send_json(
        client,
        response_body,
        "200 OK"
    );


    io::printn("Recognition result: VALID");
}


// ============================================================
// BUILD INSTRUCTION RESULTS
// ============================================================

fn String build_instruction_results(String input)
{
    if (input.len < 10)
    {
        return "";
    }


    if (!input.starts_with("begin "))
    {
        return "";
    }


    if (!input.ends_with(" end"))
    {
        return "";
    }


    String instruction_text =
        input[6 .. input.len - 5];


    if (instruction_text.len == 0)
    {
        return "";
    }


    String[] instructions =
        instruction_text.split(tmem, ".");


    String output = "";


    for (usz i = 0; i < instructions.len; i++)
    {
        String instruction =
            instructions[i];


        // ----------------------------------------------------
        // Remove exactly one separator space after a period.
        // ----------------------------------------------------

        if (i > 0)
        {
            if (
                instruction.len > 0 &&
                instruction[0] == ' '
            )
            {
                instruction =
                    instruction[1 .. instruction.len - 1];
            }
        }


        bool valid =
            validator::validate_instruction(instruction);


        String error =
            validator::get_instruction_error(instruction);


        if (i > 0)
        {
            output =
                string::tformat(
                    "%s,",
                    output
                );
        }


        if (valid)
        {
            output =
                string::tformat(
                    "%s"
                    "{"
                    "\"number\":%d,"
                    "\"instruction\":\"%s\","
                    "\"valid\":true,"
                    "\"error\":\"\""
                    "}",
                    output,
                    i + 1,
                    json_escape(instruction)
                );
        }
        else
        {
            output =
                string::tformat(
                    "%s"
                    "{"
                    "\"number\":%d,"
                    "\"instruction\":\"%s\","
                    "\"valid\":false,"
                    "\"error\":\"%s\""
                    "}",
                    output,
                    i + 1,
                    json_escape(instruction),
                    json_escape(error)
                );
        }
    }


    return output;
}


// ============================================================
// BUILD RIGHTMOST DERIVATION
// ============================================================

fn String build_derivation(String input)
{
    String instruction_text =
        input[6 .. input.len - 5];


    String[] instructions =
        instruction_text.split(tmem, ".");


    String output =
        "<program>\n";


    String current =
        "<program>";


    current =
        "begin <instructions> end";


    output =
        string::tformat(
            "%s=> %s\n",
            output,
            current
        );


    // --------------------------------------------------------
    // Expand instructions
    // --------------------------------------------------------

    if (instructions.len == 1)
    {
        current =
            derivation::replace_rightmost(
                current,
                "<instructions>",
                "<instruction>"
            );


        output =
            string::tformat(
                "%s=> %s\n",
                output,
                current
            );
    }
    else
    {
        for (usz i = 0; i < instructions.len - 1; i++)
        {
            current =
                derivation::replace_rightmost(
                    current,
                    "<instructions>",
                    "<instruction> . <instructions>"
                );


            output =
                string::tformat(
                    "%s=> %s\n",
                    output,
                    current
                );
        }


        current =
            derivation::replace_rightmost(
                current,
                "<instructions>",
                "<instruction>"
            );


        output =
            string::tformat(
                "%s=> %s\n",
                output,
                current
            );
    }


    // --------------------------------------------------------
    // Expand instructions right to left
    // --------------------------------------------------------

    for (usz i = instructions.len; i > 0; i--)
    {
        usz instruction_index =
            i - 1;


        String instruction =
            instructions[instruction_index].trim();


        String[] parts =
            instruction.split(tmem, " ");


        String command =
            parts[0];


        String[] coordinates =
            parts[1].split(tmem, "-");


        String instruction_production;


        if (command == "SQR")
        {
            instruction_production =
                "SQR <coord>-<coord>";
        }
        else
        {
            instruction_production =
                "TRI <coord>-<coord>-<coord>";
        }


        current =
            derivation::replace_rightmost(
                current,
                "<instruction>",
                instruction_production
            );


        output =
            string::tformat(
                "%s=> %s\n",
                output,
                current
            );


        // ----------------------------------------------------
        // Expand coordinates right to left
        // ----------------------------------------------------

        for (usz j = coordinates.len; j > 0; j--)
        {
            usz coordinate_index =
                j - 1;


            String coordinate =
                coordinates[coordinate_index];


            current =
                derivation::replace_rightmost(
                    current,
                    "<coord>",
                    "<x><y>"
                );


            output =
                string::tformat(
                    "%s=> %s\n",
                    output,
                    current
                );


            current =
                derivation::replace_rightmost(
                    current,
                    "<y>",
                    coordinate[1 .. 1]
                );


            output =
                string::tformat(
                    "%s=> %s\n",
                    output,
                    current
                );


            current =
                derivation::replace_rightmost(
                    current,
                    "<x>",
                    coordinate[0 .. 0]
                );


            output =
                string::tformat(
                    "%s=> %s\n",
                    output,
                    current
                );
        }
    }


    output =
        string::tformat(
            "%s\nFinal generated sentence:\n%s",
            output,
            current
        );


    return output;
}


// ============================================================
// BUILD PARSE TREE
//
// ASCII characters are intentionally used here instead of
// Unicode box-drawing characters. This prevents encoding
// problems between C3, JSON, and the browser.
// ============================================================

fn String build_parse_tree(String input)
{
    String instruction_text =
        input[6 .. input.len - 4];


    String[] instructions =
        instruction_text.split(tmem, ".");


    String output =
        "<program>\n"
        "+-- begin\n"
        "+-- <instructions>\n";


    output =
        build_instructions_tree(
            output,
            instructions,
            0,
            "    "
        );


    output =
        string::tformat(
            "%s+-- end",
            output
        );


    return output;
}


// ============================================================
// BUILD INSTRUCTIONS TREE
// ============================================================

fn String build_instructions_tree(
    String output,
    String[] instructions,
    usz index,
    String prefix
)
{
    String instruction =
        instructions[index].trim();


    bool last_instruction =
        index == instructions.len - 1;


    if (last_instruction)
    {
        output =
            string::tformat(
                "%s%s+-- <instruction>\n",
                output,
                prefix
            );


        output =
            build_instruction_tree(
                output,
                instruction,
                string::tformat(
                    "%s    ",
                    prefix
                )
            );
    }
    else
    {
        output =
            string::tformat(
                "%s%s+-- <instruction>\n",
                output,
                prefix
            );


        output =
            build_instruction_tree(
                output,
                instruction,
                string::tformat(
                    "%s|   ",
                    prefix
                )
            );


        output =
            string::tformat(
                "%s%s+-- .\n",
                output,
                prefix
            );


        output =
            string::tformat(
                "%s%s+-- <instructions>\n",
                output,
                prefix
            );


        output =
            build_instructions_tree(
                output,
                instructions,
                index + 1,
                string::tformat(
                    "%s    ",
                    prefix
                )
            );
    }


    return output;
}


// ============================================================
// BUILD INSTRUCTION TREE
// ============================================================

fn String build_instruction_tree(
    String output,
    String instruction,
    String prefix
)
{
    String[] parts =
        instruction.split(tmem, " ");


    String command =
        parts[0];


    String coordinates_text =
        parts[1];


    String[] coordinates =
        coordinates_text.split(tmem, "-");


    // --------------------------------------------------------
    // SQR
    // --------------------------------------------------------

    if (command == "SQR")
    {
        output =
            string::tformat(
                "%s%s+-- SQR\n",
                output,
                prefix
            );


        output =
            string::tformat(
                "%s%s+-- <coord>\n",
                output,
                prefix
            );


        output =
            build_coordinate_tree(
                output,
                coordinates[0],
                string::tformat(
                    "%s|   ",
                    prefix
                )
            );


        output =
            string::tformat(
                "%s%s+-- -\n",
                output,
                prefix
            );


        output =
            string::tformat(
                "%s%s+-- <coord>\n",
                output,
                prefix
            );


        output =
            build_coordinate_tree(
                output,
                coordinates[1],
                string::tformat(
                    "%s    ",
                    prefix
                )
            );
    }


    // --------------------------------------------------------
    // TRI
    // --------------------------------------------------------

    else if (command == "TRI")
    {
        output =
            string::tformat(
                "%s%s+-- TRI\n",
                output,
                prefix
            );


        output =
            string::tformat(
                "%s%s+-- <coord>\n",
                output,
                prefix
            );


        output =
            build_coordinate_tree(
                output,
                coordinates[0],
                string::tformat(
                    "%s|   ",
                    prefix
                )
            );


        output =
            string::tformat(
                "%s%s+-- -\n",
                output,
                prefix
            );


        output =
            string::tformat(
                "%s%s+-- <coord>\n",
                output,
                prefix
            );


        output =
            build_coordinate_tree(
                output,
                coordinates[1],
                string::tformat(
                    "%s|   ",
                    prefix
                )
            );


        output =
            string::tformat(
                "%s%s+-- -\n",
                output,
                prefix
            );


        output =
            string::tformat(
                "%s%s+-- <coord>\n",
                output,
                prefix
            );


        output =
            build_coordinate_tree(
                output,
                coordinates[2],
                string::tformat(
                    "%s    ",
                    prefix
                )
            );
    }


    return output;
}


// ============================================================
// BUILD COORDINATE TREE
// ============================================================

fn String build_coordinate_tree(
    String output,
    String coordinate,
    String prefix
)
{
    char x =
        coordinate[0];


    char y =
        coordinate[1];


    output =
        string::tformat(
            "%s%s+-- <x>\n",
            output,
            prefix
        );


    output =
        string::tformat(
            "%s%s|   +-- %c\n",
            output,
            prefix,
            x
        );


    output =
        string::tformat(
            "%s%s+-- <y>\n",
            output,
            prefix
        );


    output =
        string::tformat(
            "%s%s    +-- %c\n",
            output,
            prefix,
            y
        );


    return output;
}


// ============================================================
// EXTRACT REQUEST PATH
// ============================================================

fn String get_request_path(String request)
{
    if (request.len == 0)
    {
        return "/";
    }


    int first_space = -1;


    for (int i = 0; i < request.len; i++)
    {
        if (request[i] == ' ')
        {
            first_space = i;
            break;
        }
    }


    if (first_space == -1)
    {
        return "/";
    }


    int second_space = -1;


    for (
        int i = first_space + 1;
        i < request.len;
        i++
    )
    {
        if (request[i] == ' ')
        {
            second_space = i;
            break;
        }
    }


    if (second_space == -1)
    {
        return "/";
    }


    return request[
        (first_space + 1)..
        (second_space - 1)
    ];
}


// ============================================================
// EXTRACT JSON INPUT
// ============================================================

fn String extract_json_input(String request)
{
    String marker =
        "\"input\":\"";


    int marker_position = -1;


    for (
        int i = 0;
        i <= request.len - marker.len;
        i++
    )
    {
        bool found = true;


        for (
            int j = 0;
            j < marker.len;
            j++
        )
        {
            if (request[i + j] != marker[j])
            {
                found = false;
                break;
            }
        }


        if (found)
        {
            marker_position = i;
            break;
        }
    }


    if (marker_position == -1)
    {
        return "";
    }


    int start =
        marker_position + marker.len;


    int end =
        start;


    while (
        end < request.len &&
        request[end] != '"'
    )
    {
        end++;
    }


    if (end >= request.len)
    {
        return "";
    }


    return request[
        start ..
        end - 1
    ];
}


// ============================================================
// JSON ESCAPE
// ============================================================

fn String json_escape(String value)
{
    String result = "";


    for (int i = 0; i < value.len; i++)
    {
        char c =
            value[i];


        if (c == '\\')
        {
            result =
                string::tformat(
                    "%s\\\\",
                    result
                );
        }
        else if (c == '"')
        {
            result =
                string::tformat(
                    "%s\\\"",
                    result
                );
        }
        else if (c == '\n')
        {
            result =
                string::tformat(
                    "%s\\n",
                    result
                );
        }
        else if (c == '\r')
        {
            result =
                string::tformat(
                    "%s\\r",
                    result
                );
        }
        else
        {
            result =
                string::tformat(
                    "%s%c",
                    result,
                    c
                );
        }
    }


    return result;
}


// ============================================================
// READ FILE
// ============================================================

fn String read_file(String path)
{
    char[] contents =
        io::file::load(tmem, path)!!;

    return (String)contents;
}


// ============================================================
// SEND JSON
// ============================================================

fn void send_json(
    tcp::TcpSocket* client,
    String body,
    String status
)
{
    String response =
        string::tformat(
            "HTTP/1.1 %s\r\n"
            "Content-Type: application/json; charset=UTF-8\r\n"
            "Content-Length: %d\r\n"
            "Connection: close\r\n"
            "\r\n"
            "%s",
            status,
            body.len,
            body
        );


    client.write(response)!!;

    io::printn("JSON response sent.");
}


// ============================================================
// SEND JSON ERROR
// ============================================================

fn void send_json_error(
    tcp::TcpSocket* client,
    String message
)
{
    String body =
        string::tformat(
            "{"
            "\"error\":\"%s\""
            "}",
            json_escape(message)
        );


    send_json(
        client,
        body,
        "400 Bad Request"
    );
}


// ============================================================
// SEND FILE ERROR
// ============================================================

fn void send_error(
    tcp::TcpSocket* client,
    String path
)
{
    String body =
        string::tformat(
            "<!DOCTYPE html>"
            "<html>"
            "<head>"
            "<meta charset=\"UTF-8\">"
            "<title>Server Error</title>"
            "</head>"
            "<body>"
            "<h1>500 Internal Server Error</h1>"
            "<p>Could not read %s.</p>"
            "</body>"
            "</html>",
            path
        );


    String response =
        string::tformat(
            "HTTP/1.1 500 Internal Server Error\r\n"
            "Content-Type: text/html; charset=UTF-8\r\n"
            "Content-Length: %d\r\n"
            "Connection: close\r\n"
            "\r\n"
            "%s",
            body.len,
            body
        );


    client.write(response)!!;

    io::print("Could not read: ");
    io::printn(path);
}


// ============================================================
// SEND 404
// ============================================================

fn void send_not_found(
    tcp::TcpSocket* client,
    String path
)
{
    String body =
        string::tformat(
            "<!DOCTYPE html>"
            "<html>"
            "<head>"
            "<meta charset=\"UTF-8\">"
            "<title>404 Not Found</title>"
            "</head>"
            "<body>"
            "<h1>404 Not Found</h1>"
            "<p>The requested resource %s was not found.</p>"
            "</body>"
            "</html>",
            path
        );


    String response =
        string::tformat(
            "HTTP/1.1 404 Not Found\r\n"
            "Content-Type: text/html; charset=UTF-8\r\n"
            "Content-Length: %d\r\n"
            "Connection: close\r\n"
            "\r\n"
            "%s",
            body.len,
            body
        );


    client.write(response)!!;

    io::print("404 Not Found: ");
    io::printn(path);
}