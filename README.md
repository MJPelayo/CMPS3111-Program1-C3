# CMPS 3111 — Programming Languages Program 1

# Language Recognizer — C3 Version

A C3 language recognizer based on the CMPS 3111 BNF grammar.

The project contains two separate versions of the language recognizer:

1. A console program that runs directly in the terminal.
2. A web interface using HTML, CSS, JavaScript, and a C3 HTTP server.

The C3 implementation follows the same grammar and overall functionality as the C# reference implementation.

---

# Requirements

- C3 0.8.4
- GCC / standard C development libraries
- Git
- A modern web browser
- Visual Studio Code or another code editor

---

# Install C3

## Linux — Ubuntu

C3 0.8.4 is required for this project.

After installing C3, verify the installation:

```bash

c3c --version

The expected version is:

C3 0.8.4

Verify that the C compiler is also available:

gcc --version
Windows

Install C3 0.8.4 and make sure c3c is available from PowerShell.

Verify:

c3c --version

The expected version is:

C3 0.8.4
Clone the Repository
git clone <REPOSITORY-URL>
cd CMPS3111-Program1-C3
Project Structure
CMPS3111-Program1-C3/
├── main.c3
├── validator.c3
├── derivation.c3
├── parse_tree.c3
├── tests/
│   └── test_cases.c3
├── web/
│   ├── server.c3
│   └── public/
│       ├── index.html
│       ├── style.css
│       └── script.js
├── README.md
└── .git/
C3 Console Program

The console version runs directly in the terminal.

The console program uses:

main.c3 — controls the console application
validator.c3 — validates programs and instructions
derivation.c3 — generates the rightmost derivation
parse_tree.c3 — displays the parse tree
Build and Run the Console Program

From the project directory:

c3c compile-run main.c3 validator.c3 derivation.c3 parse_tree.c3

The program will start in the terminal.

You can enter a program sentence and validate it against the BNF grammar.

Console Commands

The console recognizer supports:

INFO

Displays information about the recognizer.

EXIT

Exits the program.

The commands are case-insensitive.

Valid Program Examples
Single SQR Instruction
begin SQR A1-C4 end
Single TRI Instruction
begin TRI A1-C6-G3 end
Multiple Instructions
begin SQR A1-C4. TRI A1-C6-G3 end

The grammar requires exactly one space after a period:

. TRI
Invalid Program Examples
Missing Space After a Period
begin SQR A1-C4.TRI A1-C6-G3 end
Extra Space After a Period
begin SQR A1-C4.  TRI A1-C6-G3 end
Invalid Coordinate
begin SQR H1-C4 end
Invalid Y Value
begin SQR A7-C4 end
Lowercase Command
begin sqr A1-C4 end
Extra Space
begin  SQR A1-C4 end

The recognizer treats whitespace as significant.

Test the Console Program

The project includes a stress-test file:

tests/test_cases.c3

Run the complete test suite with:

c3c compile-run tests/test_cases.c3 validator.c3

The tests cover:

Valid SQR instructions
Valid TRI instructions
Multiple instructions
Invalid program structure
Invalid commands
Incorrect SQR coordinate count
Incorrect TRI coordinate count
Invalid separators
Coordinate boundaries
Invalid X coordinates
Invalid Y coordinates
Coordinate lengths
Multiple-instruction combinations
Empty instructions
Whitespace errors
Special characters
Web Interface

The project also includes a web version of the language recognizer.

The web version contains:

web/server.c3

and:

web/public/
├── index.html
├── style.css
└── script.js

The browser communicates with the C3 backend through the HTTP API.

Run the C3 Web Server

From the project directory:

c3c compile-run web/server.c3 validator.c3 derivation.c3 parse_tree.c3

The server starts on:

http://127.0.0.1:8080

You should see:

Server started successfully.
Serving files from web/public/
API endpoint: /api/recognize
Waiting for a browser connection...
Open the Web Interface

Open a browser on the same computer and visit:

http://127.0.0.1:8080

The C3 server provides:

/              → index.html
/style.css     → style.css
/script.js     → script.js
/api/recognize → language recognizer API
Web API

The web interface sends programs to:

POST /api/recognize

The request uses JSON.

Example:

{
    "input": "begin SQR A1-C4 end"
}

The server validates the program and returns a JSON response.

API Response

For a valid program, the response contains:

{
    "valid": true,
    "instructionResults": [
        {
            "number": 1,
            "instruction": "SQR A1-C4",
            "valid": true,
            "error": ""
        }
    ],
    "error": "",
    "derivation": "...",
    "parseTree": "..."
}

For an invalid program, the response identifies the individual instructions that contain errors.

Example:

{
    "valid": false,
    "instructionResults": [
        {
            "number": 1,
            "instruction": "SQR A1-C4",
            "valid": true,
            "error": ""
        },
        {
            "number": 2,
            "instruction": "TRI A1-C6-G3",
            "valid": false,
            "error": "..."
        }
    ],
    "error": "...",
    "derivation": "",
    "parseTree": ""
}

The web interface displays the validation result for every instruction.

Test the Web API

With the C3 web server running:

curl http://127.0.0.1:8080/

Test the recognizer:

curl -X POST http://127.0.0.1:8080/api/recognize \
-H "Content-Type: application/json" \
-d '{"input":"begin SQR A1-C4 end"}'
Test Multiple Instructions
Valid
begin SQR A1-C4. TRI A1-C6-G3 end

Both instructions should be reported as valid.

One Valid and One Invalid Instruction
begin SQR A1-C4. TRI A1-C6 end

The recognizer should report:

Instruction 1 — Valid
Instruction 2 — Invalid

The overall program should be:

PROGRAM INVALID
Missing Space After Period
begin SQR A1-C4.TRI A1-C6-G3 end

The recognizer should identify the structural error:

A period must be followed by exactly one space.
Multiple Errors
begin SQR A1-C4. TRI H1-C6-G3. SQR B2-Z9. TRI A1-C6-G3 end

The recognizer checks every instruction and reports which instructions are valid and which contain errors.

Rightmost Derivation

When a complete program is valid, the recognizer generates a rightmost derivation.

The derivation starts with:

<program>

and progressively expands the grammar until the generated sentence matches the input structure.

The derivation is displayed by the web interface under:

RIGHTMOST DERIVATION
Parse Tree

When a complete program is valid, the recognizer also generates a parse tree based on the BNF grammar.

The tree represents the structure of the recognized program.

Example:

<program>
+-- begin
+-- <instructions>
    +-- <instruction>
        +-- SQR
        +-- <coord>
            +-- <x>
            |   +-- A
            +-- <y>
                +-- 1
+-- end

The web interface displays the parse tree under:

PARSE TREE
BNF Grammar

The language recognizer uses the following grammar:

<program> → begin <instructions> end

<instructions> → <instruction>
               | <instruction> . <instructions>

<instruction> → SQR <coord>-<coord>
              | TRI <coord>-<coord>-<coord>

<coord> → <x><y>

<x> → A | B | C | D | E | F | G

<y> → 1 | 2 | 3 | 4 | 5 | 6
Important Grammar Rules

The recognizer is case-sensitive.

Valid commands:

SQR
TRI

Valid X coordinates:

A B C D E F G

Valid Y coordinates:

1 2 3 4 5 6

A SQR instruction requires exactly two coordinates:

SQR A1-C4

A TRI instruction requires exactly three coordinates:

TRI A1-C6-G3

Multiple instructions are separated by a period followed by exactly one space:

SQR A1-C4. TRI A1-C6-G3

A valid program must begin with:

begin

followed by exactly one space.

A valid program must end with:

 end

with exactly one space before end.

Whitespace is significant.

Program Architecture
Console Version
                         USER INPUT
                             |
                             v
                    +----------------+
                    |    main.c3     |
                    | Console Program|
                    +-------+--------+
                            |
                            v
                    +----------------+
                    |  validator.c3  |
                    |    Validator   |
                    +-------+--------+
                            |
                     Is program valid?
                        /         \
                      NO           YES
                      |             |
                      v             v
                   ERROR       derivation.c3
                                    |
                                    v
                            Rightmost Derivation
                                    |
                                    v
                              parse_tree.c3
                                    |
                                    v
                                Parse Tree
Web Version
                       WEB BROWSER
                            |
                     HTML / CSS / JS
                            |
                            v
                  POST /api/recognize
                            |
                            v
                   +----------------+
                   |   server.c3    |
                   |  C3 HTTP Server|
                   +-------+--------+
                           |
                           v
                   +----------------+
                   |  validator.c3  |
                   +-------+--------+
                           |
                    Is program valid?
                       /         \
                     NO           YES
                     |             |
                     v             v
                  Errors      Derivation
                                  |
                                  v
                              Parse Tree
                                  |
                                  v
                           JSON Response
                                  |
                                  v
                              WEB PAGE
Responsibility of Each File
File	Main Responsibility
main.c3	Controls the console application
validator.c3	Checks whether programs and instructions follow the grammar
derivation.c3	Generates and displays the rightmost derivation
parse_tree.c3	Generates and displays the parse tree
tests/test_cases.c3	Tests the C3 validator
web/server.c3	C3 HTTP server and web API
web/public/index.html	Webpage structure and interface
web/public/script.js	Sends input to the C3 API and displays results
web/public/style.css	Controls the visual design and layout
README.md	Project documentation
Console and Web Independence

The console and web versions are separate programs.

The console can be run with:

c3c compile-run main.c3 validator.c3 derivation.c3 parse_tree.c3

The web server can be run with:

c3c compile-run web/server.c3 validator.c3 derivation.c3 parse_tree.c3

They can operate independently.

The console does not depend on the web interface.

The web interface does not require the console program to be running.

Stop the Web Server

In the terminal running the C3 web server, press:

Ctrl + C
Git

Check the current changes:

git status

Add changes:

git add .

Commit:

git commit -m "Describe your changes"

Push to GitHub:

git push origin main
Final Build Commands
Console
c3c compile-run main.c3 validator.c3 derivation.c3 parse_tree.c3
Console Tests
c3c compile-run tests/test_cases.c3 validator.c3
Web
c3c compile-run web/server.c3 validator.c3 derivation.c3 parse_tree.c3

Web address:

http://127.0.0.1:8080
Project Summary

This project implements the CMPS 3111 Programming Languages Program 1 language recognizer in C3.

The recognizer:

Validates programs using the BNF grammar.
Validates every instruction in a multiple-instruction program.
Reports individual instruction errors.
Enforces case-sensitive input.
Treats whitespace as significant.
Generates rightmost derivations for valid programs.
Generates parse trees for valid programs.
Provides both a terminal-based console interface and a browser-based interface.
Uses a C3 HTTP server to connect the web interface to the recognizer.

That's the **single complete `README.md`**. You can copy the entire block and paste it directly into your C3 project's `README.md`.