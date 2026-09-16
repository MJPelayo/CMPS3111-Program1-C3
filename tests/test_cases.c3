module test_cases;

import std::io;
import validator;


// ============================================================
// CMPS 3111 LANGUAGE RECOGNIZER
// STRESS TEST CASES
// ============================================================


fn void test_case(String description, String input, bool expected)
{
    bool result =
        validator::validate_program(input);

    if (result == expected)
    {
        io::printfn(
            "[PASS] %s",
            description
        );
    }
    else
    {
        io::printfn(
            "[FAIL] %s",
            description
        );

        io::printfn(
            "       Input: %s",
            input
        );

        io::printfn(
            "       Expected: %s",
            expected ? "VALID" : "INVALID"
        );

        io::printfn(
            "       Got: %s",
            result ? "VALID" : "INVALID"
        );
    }
}


// ============================================================
// MAIN TEST RUNNER
// ============================================================

fn void main()
{
    io::printn("");
    io::printn("==================================================");
    io::printn("       CMPS 3111 LANGUAGE RECOGNIZER TESTS");
    io::printn("==================================================");
    io::printn("");


    // --------------------------------------------------------
    // VALID PROGRAMS
    // --------------------------------------------------------

    io::printn("VALID PROGRAM TESTS");
    io::printn("--------------------");


    test_case(
        "Valid SQR instruction",
        "begin SQR A1-C4 end",
        true
    );


    test_case(
        "Valid TRI instruction",
        "begin TRI A1-C6-G3 end",
        true
    );


    test_case(
        "Valid multiple instructions",
        "begin SQR A1-C4. TRI A1-C6-G3 end",
        true
    );


    test_case(
        "Valid multiple SQR instructions",
        "begin SQR A1-C4. SQR B2-D5 end",
        true
    );


    test_case(
        "Valid multiple TRI instructions",
        "begin TRI A1-C6-G3. TRI B2-D4-F6 end",
        true
    );


    test_case(
        "Valid coordinates at boundaries",
        "begin SQR A1-G6 end",
        true
    );


    test_case(
        "Valid coordinate combinations",
        "begin TRI G6-A1-B2 end",
        true
    );


    // --------------------------------------------------------
    // INVALID PROGRAM STRUCTURE
    // --------------------------------------------------------

    io::printn("");
    io::printn("INVALID PROGRAM STRUCTURE TESTS");
    io::printn("--------------------------------");


    test_case(
        "Missing begin",
        "SQR A1-C4 end",
        false
    );


    test_case(
        "Missing end",
        "begin SQR A1-C4",
        false
    );


    test_case(
        "Empty program",
        "begin end",
        false
    );


    test_case(
        "Only begin",
        "begin",
        false
    );


    test_case(
        "Only end",
        "end",
        false
    );


    test_case(
        "Extra text after end",
        "begin SQR A1-C4 end extra",
        false
    );


    test_case(
        "Extra text before begin",
        "extra begin SQR A1-C4 end",
        false
    );


    // --------------------------------------------------------
    // INVALID COMMAND TESTS
    // --------------------------------------------------------

    io::printn("");
    io::printn("INVALID COMMAND TESTS");
    io::printn("---------------------");


    test_case(
        "Unknown command",
        "begin ABC A1-C4 end",
        false
    );


    test_case(
        "Lowercase command",
        "begin sqr A1-C4 end",
        false
    );


    test_case(
        "Mixed-case command",
        "begin Sqr A1-C4 end",
        false
    );


    test_case(
        "Missing command",
        "begin A1-C4 end",
        false
    );


    // --------------------------------------------------------
    // SQR TESTS
    // --------------------------------------------------------

    io::printn("");
    io::printn("SQR TESTS");
    io::printn("---------");


    test_case(
        "SQR with one coordinate",
        "begin SQR A1 end",
        false
    );


    test_case(
        "SQR with three coordinates",
        "begin SQR A1-C4-G6 end",
        false
    );


    test_case(
        "SQR missing dash",
        "begin SQR A1 C4 end",
        false
    );


    test_case(
        "SQR with incorrect separator",
        "begin SQR A1/C4 end",
        false
    );


    // --------------------------------------------------------
    // TRI TESTS
    // --------------------------------------------------------

    io::printn("");
    io::printn("TRI TESTS");
    io::printn("---------");


    test_case(
        "TRI with two coordinates",
        "begin TRI A1-C4 end",
        false
    );


    test_case(
        "TRI with four coordinates",
        "begin TRI A1-C4-G6-B2 end",
        false
    );


    test_case(
        "TRI missing first dash",
        "begin TRI A1 C4-G6 end",
        false
    );


    test_case(
        "TRI missing second dash",
        "begin TRI A1-C4 G6 end",
        false
    );


    // --------------------------------------------------------
    // INVALID X COORDINATES
    // --------------------------------------------------------

    io::printn("");
    io::printn("INVALID X COORDINATE TESTS");
    io::printn("--------------------------");


    test_case(
        "X coordinate H",
        "begin SQR H1-C4 end",
        false
    );


    test_case(
        "X coordinate Z",
        "begin SQR Z1-C4 end",
        false
    );


    test_case(
        "Lowercase X coordinate",
        "begin SQR a1-C4 end",
        false
    );


    test_case(
        "Numeric X coordinate",
        "begin SQR 11-C4 end",
        false
    );


    // --------------------------------------------------------
    // INVALID Y COORDINATES
    // --------------------------------------------------------

    io::printn("");
    io::printn("INVALID Y COORDINATE TESTS");
    io::printn("--------------------------");


    test_case(
        "Y coordinate 0",
        "begin SQR A0-C4 end",
        false
    );


    test_case(
        "Y coordinate 7",
        "begin SQR A7-C4 end",
        false
    );


    test_case(
        "Y coordinate 9",
        "begin SQR A9-C4 end",
        false
    );


    test_case(
        "Lowercase-style coordinate",
        "begin SQR A0-C4 end",
        false
    );


    // --------------------------------------------------------
    // INVALID COORDINATE LENGTH TESTS
    // --------------------------------------------------------

    io::printn("");
    io::printn("INVALID COORDINATE LENGTH TESTS");
    io::printn("--------------------------------");


    test_case(
        "Coordinate with three characters",
        "begin SQR A12-C4 end",
        false
    );


    test_case(
        "Coordinate with one character",
        "begin SQR A-C4 end",
        false
    );


    test_case(
        "Empty coordinate",
        "begin SQR -C4 end",
        false
    );


    // --------------------------------------------------------
    // PERIOD / MULTIPLE INSTRUCTION TESTS
    // --------------------------------------------------------

    io::printn("");
    io::printn("MULTIPLE INSTRUCTION TESTS");
    io::printn("---------------------------");


    test_case(
        "Two valid instructions",
        "begin SQR A1-C4. TRI A1-C6-G3 end",
        true
    );


    test_case(
        "Three valid instructions",
        "begin SQR A1-C4. TRI A1-C6-G3. SQR B2-D5 end",
        true
    );


    test_case(
        "Invalid instruction after valid instruction",
        "begin SQR A1-C4. ABC A1-C4 end",
        false
    );


    test_case(
        "Valid instruction after invalid instruction",
        "begin ABC A1-C4. SQR A1-C4 end",
        false
    );


    test_case(
        "Empty instruction at beginning",
        "begin . SQR A1-C4 end",
        false
    );


    test_case(
        "Empty instruction in middle",
        "begin SQR A1-C4..TRI A1-C6-G3 end",
        false
    );


    test_case(
        "Empty instruction at end",
        "begin SQR A1-C4. end",
        false
    );


    // --------------------------------------------------------
    // WHITESPACE TESTS
    // --------------------------------------------------------

    io::printn("");
    io::printn("WHITESPACE TESTS");
    io::printn("----------------");


    test_case(
        "Extra spaces after begin",
        "begin  SQR A1-C4 end",
        false
    );


    test_case(
        "Extra spaces inside instruction",
        "begin SQR  A1-C4 end",
        false
    );


    test_case(
        "Extra spaces before end",
        "begin SQR A1-C4  end",
        false
    );


    // --------------------------------------------------------
    // SPECIAL CHARACTER TESTS
    // --------------------------------------------------------

    io::printn("");
    io::printn("SPECIAL CHARACTER TESTS");
    io::printn("-----------------------");


    test_case(
        "Slash instead of dash",
        "begin SQR A1/C4 end",
        false
    );


    test_case(
        "Comma instead of dash",
        "begin SQR A1,C4 end",
        false
    );


    test_case(
        "Colon instead of dash",
        "begin SQR A1:C4 end",
        false
    );


    test_case(
        "No separator",
        "begin SQRA1-C4 end",
        false
    );


    // --------------------------------------------------------
    // SUMMARY
    // --------------------------------------------------------

    io::printn("");
    io::printn("==================================================");
    io::printn("                  TESTS COMPLETE");
    io::printn("==================================================");
    io::printn("");
}