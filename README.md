# CMPS 3111 — Programming Languages Program 1
# Language Recognizer — C3 Version

A C3 language recognizer based on the CMPS 3111 BNF grammar.

The project contains:

1. A console language recognizer.
2. A web-based language recognizer using HTML, CSS, JavaScript, and a C3 HTTP server.
3. Automated tests for the validator.
4. Rightmost derivation generation.
5. Parse tree generation.
6. Three web-access options:
   - Local access
   - Same-network access
   - Internet access through a temporary Cloudflare Quick Tunnel

The C3 implementation follows the same grammar and overall functionality as the C# reference implementation.

---

# 1. Requirements

## Required

- C3 0.8.4
- Git
- A modern web browser
- A code editor such as Visual Studio Code

## Linux

- Ubuntu 24.04 or compatible Linux distribution
- `c3c` available in the terminal
- GCC / standard C development tools

## Windows

- Windows 11 or compatible Windows version
- `c3c` available in PowerShell or Command Prompt

## Optional: Internet Tunneling

For the public Internet demonstration:

- `cloudflared`

The project uses a Cloudflare Quick Tunnel. A Quick Tunnel creates a temporary public HTTPS address that forwards requests to the local C3 web server.

---

# 2. Install and Verify C3

## Linux — Ubuntu

C3 0.8.4 is required for this project.

Verify C3:

```bash
c3c --version
```

Expected version:

```text
C3 0.8.4
```

Verify GCC:

```bash
gcc --version
```

## Windows

Install C3 0.8.4 and make sure `c3c` is available from PowerShell.

Verify:

```powershell
c3c --version
```

Expected version:

```text
C3 0.8.4
```

---

# 3. Clone the Repository

Clone the repository:

```bash
git clone <REPOSITORY-URL>
```

Enter the project directory:

```bash
cd CMPS3111-Program1-C3
```

On Windows PowerShell, use the corresponding path to your cloned project.

---

# 4. Project Structure

```text
CMPS3111-Program1-C3/
│
├── main.c3
├── validator.c3
├── derivation.c3
├── parse_tree.c3
├── README.md
│
├── tests/
│   └── test_cases.c3
│
└── web/
    ├── server.c3
    └── public/
        ├── index.html
        ├── style.css
        └── script.js
```

---

# 5. Responsibility of Each File

| File | Main Responsibility |
|---|---|
| `main.c3` | Controls the console application |
| `validator.c3` | Validates programs and individual instructions |
| `derivation.c3` | Generates the rightmost derivation |
| `parse_tree.c3` | Generates the parse tree |
| `tests/test_cases.c3` | Tests the C3 validator |
| `web/server.c3` | C3 HTTP server and web API |
| `web/public/index.html` | Webpage structure and interface |
| `web/public/style.css` | Visual design and layout |
| `web/public/script.js` | Sends input to the C3 API and displays results |
| `README.md` | Project documentation |

---

# 6. BNF Grammar

The recognizer uses the following grammar:

```text
<program> → begin <instructions> end

<instructions> → <instruction>
               | <instruction> . <instructions>

<instruction> → SQR <coord>-<coord>
              | TRI <coord>-<coord>-<coord>

<coord> → <x><y>

<x> → A | B | C | D | E | F | G

<y> → 1 | 2 | 3 | 4 | 5 | 6
```

The language is case-sensitive and whitespace is significant.

---

# 7. Important Grammar Rules

## Program

A valid program must begin with:

```text
begin
```

followed by exactly one space.

A valid program must end with:

```text
end
```

with exactly one space before `end`.

## SQR

A `SQR` instruction requires exactly two coordinates:

```text
SQR A1-C4
```

## TRI

A `TRI` instruction requires exactly three coordinates:

```text
TRI A1-C6-G3
```

## Coordinates

Valid X values:

```text
A B C D E F G
```

Valid Y values:

```text
1 2 3 4 5 6
```

Examples:

```text
A1
C4
G6
```

## Multiple Instructions

Multiple instructions are separated by a period followed by exactly one space:

```text
SQR A1-C4. TRI A1-C6-G3
```

The following are invalid:

```text
SQR A1-C4.TRI A1-C6-G3
```

because the required space after the period is missing.

```text
SQR A1-C4.  TRI A1-C6-G3
```

because there are two spaces after the period.

---

# 8. Valid Program Examples

## Single SQR Instruction

```text
begin SQR A1-C4 end
```

## Single TRI Instruction

```text
begin TRI A1-C6-G3 end
```

## Multiple Instructions

```text
begin SQR A1-C4. TRI A1-C6-G3 end
```

---

# 9. Invalid Program Examples

## Missing Space After a Period

```text
begin SQR A1-C4.TRI A1-C6-G3 end
```

## Extra Space After a Period

```text
begin SQR A1-C4.  TRI A1-C6-G3 end
```

## Invalid Coordinate

```text
begin SQR H1-C4 end
```

## Invalid Y Value

```text
begin SQR A7-C4 end
```

## Lowercase Command

```text
begin sqr A1-C4 end
```

## Extra Space After `begin`

```text
begin  SQR A1-C4 end
```

Whitespace is significant throughout the grammar.

---

# 10. Console Version

The console version runs directly in the terminal.

It uses:

```text
main.c3
validator.c3
derivation.c3
parse_tree.c3
```

The console can operate independently from the web version.

---

# 11. Run the Console Version — Linux

Open a terminal and enter the project directory:

```bash
cd ~/Desktop/CMPS3111-Program1-C3
```

Compile and run:

```bash
c3c compile-run main.c3 validator.c3 derivation.c3 parse_tree.c3
```

The program will start in the terminal.

You can enter a program sentence and validate it against the BNF grammar.

---

# 12. Run the Console Version — Windows

Open PowerShell or Command Prompt.

Navigate to the project directory, for example:

```powershell
cd C:\Users\YourName\Desktop\CMPS3111-Program1-C3
```

Run:

```powershell
c3c compile-run main.c3 validator.c3 derivation.c3 parse_tree.c3
```

The console version works the same way on Windows and Linux.

---

# 13. Console Commands

The console recognizer supports:

```text
INFO
```

Displays information about the recognizer.

```text
EXIT
```

Exits the program.

The console commands are case-insensitive.

The grammar itself remains case-sensitive.

---

# 14. Automated Tests

The project includes a stress-test file:

```text
tests/test_cases.c3
```

Run the complete test suite:

```bash
c3c compile-run tests/test_cases.c3 validator.c3
```

On Windows PowerShell:

```powershell
c3c compile-run tests/test_cases.c3 validator.c3
```

The tests cover:

- Valid SQR instructions
- Valid TRI instructions
- Multiple instructions
- Invalid program structure
- Invalid commands
- Incorrect SQR coordinate count
- Incorrect TRI coordinate count
- Invalid separators
- Coordinate boundaries
- Invalid X coordinates
- Invalid Y coordinates
- Coordinate lengths
- Multiple-instruction combinations
- Empty instructions
- Whitespace errors
- Special characters

All tests should pass before final submission.

---

# 15. Web Version

The project includes a browser-based version of the recognizer.

The web version contains:

```text
web/server.c3
```

and:

```text
web/public/
├── index.html
├── style.css
└── script.js
```

The browser communicates with the C3 backend through the HTTP API.

Architecture:

```text
WEB BROWSER
    │
    │ HTTP
    ▼
server.c3
    │
    ├── validator.c3
    ├── derivation.c3
    └── parse_tree.c3
```

---

# 16. Run the Web Server — Linux

From the project root:

```bash
cd ~/Desktop/CMPS3111-Program1-C3
```

Start the server:

```bash
c3c compile-run web/server.c3 validator.c3 derivation.c3 parse_tree.c3
```

The server uses port:

```text
8080
```

The server listens on:

```text
0.0.0.0:8080
```

This allows the same server to support local access, same-network access, and a tunnel.

You should see a startup message similar to:

```text
==================================================
       CMPS 3111 LANGUAGE RECOGNIZER
              C3 WEB SERVER
==================================================

Starting server on port 8080 ...
Server started successfully.
Local access:   http://127.0.0.1:8080
Network access: http://<laptop-IP>:8080
Serving files from web/public/
API endpoint: /api/recognize
Waiting for a browser connection...
```

Leave this terminal running.

---

# 17. Run the Web Server — Windows

From PowerShell, navigate to the project directory:

```powershell
cd C:\Users\YourName\Desktop\CMPS3111-Program1-C3
```

Start the C3 web server:

```powershell
c3c compile-run web/server.c3 validator.c3 derivation.c3 parse_tree.c3
```

The server uses port `8080`.

Leave the PowerShell window running while the website is being used.

---

# 18. Web Access Method 1 — Local Access

Local access means the browser and C3 server are running on the **same computer**.

Start the C3 web server:

```bash
c3c compile-run web/server.c3 validator.c3 derivation.c3 parse_tree.c3
```

Open a browser on the same computer:

```text
http://127.0.0.1:8080
```

This method does not require a network connection to another computer.

### Example

```text
Linux laptop
    │
    ├── C3 server :8080
    │
    └── Browser
         ↓
    http://127.0.0.1:8080
```

---

# 19. Web Access Method 2 — Same Network

Same-network access allows another computer to use the web application when both devices are connected to the same network.

This is useful for a classroom demonstration where:

```text
Linux laptop = Server
Classroom computer = Browser
```

The classroom computer does **not** need C3 or the project installed.

## Step 1 — Start the C3 server

On the Linux server laptop:

```bash
cd ~/Desktop/CMPS3111-Program1-C3
c3c compile-run web/server.c3 validator.c3 derivation.c3 parse_tree.c3
```

Leave the terminal running.

## Step 2 — Find the laptop's current IP address

Open another terminal and run:

```bash
hostname -I
```

Look for the current private IPv4 address.

For example:

```text
192.168.18.143
```

The address can change when the laptop connects to a different Wi-Fi or Ethernet network.

**Do not hard-code the IP address into the program.**

The server listens on:

```text
0.0.0.0
```

so the server can use the address assigned by the current network.

## Step 3 — Open the website from the other computer

If the server laptop's current IP is:

```text
192.168.18.143
```

open:

```text
http://192.168.18.143:8080
```

If the address changes, replace it with the new address:

```text
http://<CURRENT-LAPTOP-IP>:8080
```

---

# 20. Same-Network Classroom Example

A possible classroom setup is:

```text
School Network
      │
      ├───────────────┐
      │               │
      ▼               ▼
Linux Laptop       Classroom PC
C3 Server          Web Browser
Port 8080
```

The Linux laptop may receive an address such as:

```text
10.20.5.37
```

The classroom computer would then open:

```text
http://10.20.5.37:8080
```

The exact IP address depends on the school network.

### Ethernet or Wi-Fi

The server laptop can use either:

- Ethernet
- Wi-Fi

The important requirement is that the client computer can reach the server laptop over the network.

---

# 21. Important Same-Network Limitation

Being connected to the same Wi-Fi or Ethernet network does not always guarantee that devices can communicate directly.

Some school, public, or guest networks use:

- Client isolation
- Device isolation
- Firewall rules
- Network access restrictions

If the classroom computer cannot reach:

```text
http://<CURRENT-LAPTOP-IP>:8080
```

the Internet tunnel method can be used instead.

---

# 22. Web Access Method 3 — Internet Access with Cloudflare Quick Tunnel

The third method allows people to access the website even when they are **not on the same network**.

The architecture is:

```text
Remote Browser
      │
      │ HTTPS
      ▼
Cloudflare Quick Tunnel
      │
      ▼
cloudflared
      │
      │ HTTP
      ▼
Linux Laptop
      │
      ▼
C3 Web Server
localhost:8080
```

This is useful when:

- The client is using mobile data.
- The client is on another Wi-Fi network.
- The school network blocks device-to-device communication.
- You want a public demonstration link.

The Quick Tunnel URL is temporary.

---

# 23. Install Cloudflare `cloudflared` — Linux

After installing `cloudflared`, verify it:

```bash
cloudflared --version
```

Example:

```text
cloudflared version 2026.9.1
```

The exact version may be newer when the project is used later.

---

# 24. Start the Cloudflare Tunnel — Linux

The C3 server must be running first.

## Terminal 1 — C3 Server

From the project root:

```bash
cd ~/Desktop/CMPS3111-Program1-C3
c3c compile-run web/server.c3 validator.c3 derivation.c3 parse_tree.c3
```

Leave Terminal 1 running.

The C3 server should be listening on:

```text
localhost:8080
```

## Terminal 2 — Cloudflare Tunnel

Open a second terminal.

Run:

```bash
cloudflared tunnel --url http://localhost:8080
```

Cloudflare will generate a temporary public address.

Look for:

```text
Your quick Tunnel has been created!
Visit it at:
https://<random-name>.trycloudflare.com
```

For example:

```text
https://literature-proteins-added-liked.trycloudflare.com
```

Use the URL generated by the **current tunnel session**.

---

# 25. Finding the New Tunnel URL

A Quick Tunnel generates a temporary URL when `cloudflared` starts.

Every time this command is run:

```bash
cloudflared tunnel --url http://localhost:8080
```

look for:

```text
Your quick Tunnel has been created!
Visit it at:
https://________________.trycloudflare.com
```

That is the URL to share.

Do not assume a previous Quick Tunnel URL will continue to work after the tunnel process has been stopped.

For example:

```text
First session:
https://demonstration-digit-phi-salary.trycloudflare.com
```

A later session may generate:

```text
https://literature-proteins-added-liked.trycloudflare.com
```

Use the newest URL.

---

# 26. Test the Public Tunnel

Once `cloudflared` reports that the tunnel connection is registered, open the generated URL on another device.

A strong test is a phone using **mobile data** instead of the same Wi-Fi network.

For example:

```text
https://literature-proteins-added-liked.trycloudflare.com
```

If the CMPS 3111 Language Recognizer page loads, the server is accessible from outside the local network.

---

# 27. Keep Both Processes Running

When using the tunnel, two processes must remain active.

## Terminal 1

```text
C3 Web Server
localhost:8080
```

## Terminal 2

```text
cloudflared
```

The flow is:

```text
Internet
   ↓
Cloudflare
   ↓
cloudflared
   ↓
localhost:8080
   ↓
C3 Web Server
   ↓
Language Recognizer
```

If either process is stopped, the public website will stop working.

Stop a running process with:

```text
Ctrl + C
```

---

# 28. Cloudflare Quick Tunnel — Windows

If `cloudflared` is installed on Windows, the tunnel command is:

```powershell
cloudflared tunnel --url http://localhost:8080
```

The C3 web server must already be running on port `8080`.

Cloudflare will display a temporary URL similar to:

```text
https://<random-name>.trycloudflare.com
```

That URL can be opened from another network.

For the classroom presentation, the Linux laptop can remain the server while the classroom computer only needs a browser.

---

# 29. Three Web Access Methods — Quick Reference

| Method | Browser Location | Address | C3 Needed on Client? |
|---|---|---|---|
| Local | Same computer as server | `http://127.0.0.1:8080` | No |
| Same network | Another computer on same network | `http://<CURRENT-LAPTOP-IP>:8080` | No |
| Internet tunnel | Any network | `https://<random-name>.trycloudflare.com` | No |

---

# 30. Recommended Classroom Setup

The Linux laptop can act as a **mobile server**.

It does not need a permanent IP address.

When moving from home to school, the laptop can receive a different IP address.

For example:

```text
At home:
192.168.18.143
```

At school it might receive:

```text
10.50.12.84
```

The C3 source code does not need to be changed.

The server listens on:

```text
0.0.0.0:8080
```

Then run:

```bash
hostname -I
```

to find the current network address.

---

# 31. Recommended Presentation Plan

There are two useful presentation paths.

## Primary Method — Same Network

If the school network allows device-to-device communication:

### Linux laptop

```bash
c3c compile-run web/server.c3 validator.c3 derivation.c3 parse_tree.c3
```

Find the current IP:

```bash
hostname -I
```

Then the classroom computer opens:

```text
http://<CURRENT-LAPTOP-IP>:8080
```

### Client

Only a web browser is required.

---

## Backup Method — Cloudflare Tunnel

If the school network blocks direct device-to-device communication:

### Terminal 1

```bash
c3c compile-run web/server.c3 validator.c3 derivation.c3 parse_tree.c3
```

### Terminal 2

```bash
cloudflared tunnel --url http://localhost:8080
```

Copy the newly generated:

```text
https://<random-name>.trycloudflare.com
```

address.

Open it on the classroom computer.

---

# 32. Web API

The browser communicates with:

```text
POST /api/recognize
```

The request uses JSON.

Example:

```json
{
  "input": "begin SQR A1-C4 end"
}
```

The C3 server validates the program and returns a JSON response.

The response includes:

- Overall validity
- Individual instruction results
- Error messages
- Rightmost derivation
- Parse tree

---

# 33. Example API Response

For a valid program:

```json
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
```

For an invalid program, the response identifies individual instruction problems.

Example:

```json
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
      "instruction": "TRI A1-C6",
      "valid": false,
      "error": "..."
    }
  ],
  "error": "...",
  "derivation": "",
  "parseTree": ""
}
```

The web interface displays the validation result for every instruction.

---

# 34. Test the Web API Locally

With the C3 web server running:

```bash
curl http://127.0.0.1:8080/
```

Test the recognizer:

```bash
curl -X POST http://127.0.0.1:8080/api/recognize \
-H "Content-Type: application/json" \
-d '{"input":"begin SQR A1-C4 end"}'
```

---

# 35. Test Multiple Instructions

## Valid

```text
begin SQR A1-C4. TRI A1-C6-G3 end
```

Both instructions should be reported as valid.

## One Valid and One Invalid

```text
begin SQR A1-C4. TRI A1-C6 end
```

The recognizer should report:

```text
Instruction 1 — Valid
Instruction 2 — Invalid
```

The overall result should be:

```text
PROGRAM INVALID
```

## Missing Space After Period

```text
begin SQR A1-C4.TRI A1-C6-G3 end
```

The recognizer should identify:

```text
A period must be followed by exactly one space.
```

## Multiple Errors

```text
begin SQR A1-C4. TRI H1-C6-G3. SQR B2-Z9. TRI A1-C6-G3 end
```

The recognizer checks every instruction and reports which instructions are valid and which contain errors.

---

# 36. Rightmost Derivation

When a complete program is valid, the recognizer generates a rightmost derivation.

The derivation starts with:

```text
<program>
```

and progressively expands the grammar until the generated sentence matches the input structure.

The web interface displays the result under:

```text
RIGHTMOST DERIVATION
```

---

# 37. Parse Tree

When a complete program is valid, the recognizer generates a parse tree based on the BNF grammar.

Example:

```text
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
```

The web interface displays the result under:

```text
PARSE TREE
```

---

# 38. Program Architecture

## Console Version

```text
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
                   ERROR      derivation.c3
                                   |
                                   v
                           Rightmost Derivation
                                   |
                                   v
                             parse_tree.c3
                                   |
                                   v
                               Parse Tree
```

## Web Version

```text
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
```

## Internet Tunnel Version

```text
Remote Browser
      |
      | HTTPS
      v
Cloudflare Quick Tunnel
      |
      v
cloudflared
      |
      | HTTP
      v
C3 Web Server :8080
      |
      +---- validator.c3
      |
      +---- derivation.c3
      |
      +---- parse_tree.c3
```

---

# 39. Console and Web Independence

The console and web versions are separate programs.

Console:

```bash
c3c compile-run main.c3 validator.c3 derivation.c3 parse_tree.c3
```

Web:

```bash
c3c compile-run web/server.c3 validator.c3 derivation.c3 parse_tree.c3
```

They can operate independently.

The console does not depend on the web interface.

The web interface does not require the console program to be running.

---

# 40. Troubleshooting

## Browser Says `127.0.0.1 Refused to Connect`

`127.0.0.1` means the current computer.

Use:

```text
http://127.0.0.1:8080
```

only when the browser is running on the same computer as the C3 server.

For another computer on the same network, use:

```text
http://<SERVER-LAPTOP-IP>:8080
```

For Internet access, use the current Cloudflare URL:

```text
https://<random-name>.trycloudflare.com
```

---

## Same-Network Computer Cannot Connect

On the Linux server laptop:

```bash
hostname -I
```

Verify the current IPv4 address.

Make sure:

- Both devices are connected to the intended network.
- The C3 server is running.
- Port `8080` is being used.
- The server is listening on `0.0.0.0`.
- The school/public network does not isolate client devices.

If direct access is blocked, use the Cloudflare Quick Tunnel.

---

## Cloudflare Error 1033

Error 1033 can occur when Cloudflare cannot reach an active `cloudflared` connector.

Check that both processes are running.

### Terminal 1

```bash
c3c compile-run web/server.c3 validator.c3 derivation.c3 parse_tree.c3
```

### Terminal 2

```bash
cloudflared tunnel --url http://localhost:8080
```

Use the **new URL printed by the current `cloudflared` process**.

---

## Cloudflare URL Stops Working

A Quick Tunnel URL is temporary.

If `cloudflared` is stopped and restarted, use the newly generated URL.

---

## Web Files Are Not Found

Run the server from the project root:

```bash
cd ~/Desktop/CMPS3111-Program1-C3
```

Then:

```bash
c3c compile-run web/server.c3 validator.c3 derivation.c3 parse_tree.c3
```

The server expects the web files under:

```text
web/public/
```

---

# 41. Stopping the Web Server

In the terminal running the C3 web server, press:

```text
Ctrl + C
```

If a Cloudflare tunnel is running, stop it separately with:

```text
Ctrl + C
```

---

# 42. Git

Check the current changes:

```bash
git status
```

Add changes:

```bash
git add .
```

Commit:

```bash
git commit -m "Update README and web deployment instructions"
```

Push to GitHub:

```bash
git push origin main
```

Compiled binaries such as:

```text
main
server
test_cases
```

are build artifacts and should not be committed unless the project specifically requires them.

---
#####

# 43. Final Build Commands

## Console

```bash
c3c compile-run main.c3 validator.c3 derivation.c3 parse_tree.c3
```

## Console Tests

```bash
c3c compile-run tests/test_cases.c3 validator.c3
```

## Web Server

```bash
c3c compile-run web/server.c3 validator.c3 derivation.c3 parse_tree.c3
```

## Find Current Linux Network Address

```bash
hostname -I
```

## Cloudflare Quick Tunnel

```bash
cloudflared tunnel --url http://localhost:8080
```

---