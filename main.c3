module main;

import std::io;
import validator;
import derivation;
import parse_tree;


// ============================================================
// MAIN
// ============================================================

fn void main()
{
    show_instructions();


    while (true)
    {
        io::printn("");

        io::print(
            "Enter string (EXIT = quit, INFO = instructions): "
        );


        String? input = io::treadline();


        if (catch input)
        {
            io::printn("");
            io::printn("Program terminated.");
            return;
        }


        // ----------------------------------------------------
        // EXIT
        // ----------------------------------------------------

        if (input == "EXIT" || input == "exit")
        {
            io::printn("");
            io::printn("Program terminated.");
            return;
        }


        // ----------------------------------------------------
        // INFO
        // ----------------------------------------------------

        if (input == "INFO" || input == "info")
        {
            io::printn("");
            show_instructions();
            continue;
        }


        // ----------------------------------------------------
        // EMPTY INPUT
        // ----------------------------------------------------

        if (input.len == 0)
        {
            io::printn("");
            io::printn("ERROR: No input was entered.");
            continue;
        }


        // ----------------------------------------------------
        // VALIDATE
        // ----------------------------------------------------

        bool is_valid =
            validator::validate_program(input);


        // ----------------------------------------------------
        // INVALID
        // ----------------------------------------------------

        if (!is_valid)
        {
            io::printn("");

            io::printn(
                "ERROR: Invalid program."
            );

            io::printn("");

            io::printn(
                "Examples of valid input:"
            );

            io::printn(
                "begin SQR A1-C4 end"
            );

            io::printn(
                "begin TRI A1-C6-G3 end"
            );

            io::printn("");

            io::print(
                "Enter Y to try again or EXIT to quit: "
            );


            String? choice = io::treadline();


            if (catch choice)
            {
                io::printn("");
                io::printn("Program terminated.");
                return;
            }


            if (choice == "EXIT" || choice == "exit")
            {
                io::printn("");
                io::printn("Program terminated.");
                return;
            }


            if (choice == "Y" || choice == "y")
            {
                continue;
            }


            io::printn("");

            io::printn(
                "Invalid choice. Returning to input prompt."
            );

            continue;
        }


        // ----------------------------------------------------
        // VALID INPUT
        // ----------------------------------------------------

        io::printn("");

        io::printn(
            "SUCCESS: Valid string!"
        );

        io::printn(
            "The input follows the required grammar."
        );


        // ----------------------------------------------------
        // RIGHTMOST DERIVATION
        // ----------------------------------------------------

        derivation::display_rightmost_derivation(
            input
        );


        // ----------------------------------------------------
        // PARSE TREE
        // ----------------------------------------------------

        io::printn("");

        io::print(
            "Display parse tree? (Y/N): "
        );


        String? tree_choice =
            io::treadline();


        if (catch tree_choice)
        {
            io::printn("");
            io::printn("Program terminated.");
            return;
        }


        if (tree_choice == "Y" || tree_choice == "y")
        {
            parse_tree::display_parse_tree(
                input
            );
        }
        else if (
            tree_choice == "N"
            || tree_choice == "n"
        )
        {
            io::printn("");

            io::printn(
                "Parse tree skipped."
            );
        }
        else
        {
            io::printn("");

            io::printn(
                "Invalid choice. Parse tree skipped."
            );
        }


        io::printn("");

        io::printn(
            "Ready for another input."
        );
    }
}


// ============================================================
// DISPLAY INSTRUCTIONS
// ============================================================

fn void show_instructions()
{
    io::printn(
        "=================================================="
    );

    io::printn(
        "       CMPS 3111 LANGUAGE RECOGNIZER"
    );

    io::printn(
        "=================================================="
    );

    io::printn("");


    // --------------------------------------------------------
    // GRAMMAR
    // --------------------------------------------------------

    io::printn(
        "<program> → begin <instructions> end"
    );

    io::printn("");


    io::printn(
        "<instructions> → <instruction>"
    );

    io::printn(
        "               | <instruction> . <instructions>"
    );

    io::printn("");


    io::printn(
        "<instruction> → SQR <coord>-<coord>"
    );

    io::printn(
        "              | TRI <coord>-<coord>-<coord>"
    );

    io::printn("");


    io::printn(
        "<coord> → <x><y>"
    );

    io::printn(
        "<x> → A | B | C | D | E | F | G"
    );

    io::printn(
        "<y> → 1 | 2 | 3 | 4 | 5 | 6"
    );

    io::printn("");


    // --------------------------------------------------------
    // INPUT INSTRUCTIONS
    // --------------------------------------------------------

    io::printn(
        "INPUT INSTRUCTIONS"
    );

    io::printn(
        "1. Input must begin with: begin"
    );

    io::printn(
        "2. Input must end with: end"
    );

    io::printn(
        "3. SQR requires exactly 2 coordinates."
    );

    io::printn(
        "4. TRI requires exactly 3 coordinates."
    );

    io::printn(
        "5. Coordinates use letters A-G and numbers 1-6."
    );

    io::printn(
        "6. Coordinates are separated by a dash (-)."
    );

    io::printn(
        "7. Multiple instructions use a period (.)."
    );

    io::printn("");


    // --------------------------------------------------------
    // VALID EXAMPLES
    // --------------------------------------------------------

    io::printn(
        "VALID EXAMPLES"
    );

    io::printn(
        "begin SQR A1-C4 end"
    );

    io::printn(
        "begin TRI A1-C6-G3 end"
    );

    io::printn(
        "begin SQR A1-C4. TRI A1-C6-G3 end"
    );

    io::printn("");
}