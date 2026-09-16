module validator;

import std::io;


// ============================================================
// VALIDATE COORDINATE
//
// Grammar:
// <coord> → <x><y>
// <x>    → A | B | C | D | E | F | G
// <y>    → 1 | 2 | 3 | 4 | 5 | 6
// ============================================================

fn bool validate_coordinate(String coordinate)
{
    return get_coordinate_error(coordinate).len == 0;
}


// ============================================================
// GET COORDINATE ERROR
// ============================================================

fn String get_coordinate_error(String coordinate)
{
    // A coordinate must contain exactly two characters.
    if (coordinate.len != 2)
    {
        return string::tformat(
            "Invalid coordinate '%s'. A coordinate must contain exactly two characters.",
            coordinate
        );
    }

    // --------------------------------------------------------
    // Validate X value.
    // --------------------------------------------------------

    char x = coordinate[0];

    if (
        x != 'A'
        && x != 'B'
        && x != 'C'
        && x != 'D'
        && x != 'E'
        && x != 'F'
        && x != 'G'
    )
    {
        return string::tformat(
            "Invalid coordinate '%s'. '%c' is not a valid X value. X must be A-G.",
            coordinate,
            x
        );
    }

    // --------------------------------------------------------
    // Validate Y value.
    // --------------------------------------------------------

    char y = coordinate[1];

    if (
        y != '1'
        && y != '2'
        && y != '3'
        && y != '4'
        && y != '5'
        && y != '6'
    )
    {
        return string::tformat(
            "Invalid coordinate '%s'. '%c' is not a valid Y value. Y must be 1-6.",
            coordinate,
            y
        );
    }

    return "";
}


// ============================================================
// VALIDATE INSTRUCTION
// ============================================================

fn bool validate_instruction(String instruction)
{
    return get_instruction_error(instruction).len == 0;
}


// ============================================================
// GET INSTRUCTION ERROR
//
// Grammar:
//
// <instruction> → SQR <coord>-<coord>
//               | TRI <coord>-<coord>-<coord>
//
// Exactly one space is required between the command and
// its coordinates.
// ============================================================

fn String get_instruction_error(String instruction)
{
    if (instruction.len == 0)
    {
        return "The instruction cannot be empty.";
    }

    // --------------------------------------------------------
    // Find the command/coordinate separator.
    // --------------------------------------------------------

    sz? space_position =
        instruction.index_of(" ");

    if (catch space_position)
    {
        return string::tformat(
            "Invalid instruction '%s'. The instruction must contain exactly one space between the command and its coordinates.",
            instruction
        );
    }

    // --------------------------------------------------------
    // A space cannot be the first character.
    // --------------------------------------------------------

    if (space_position == 0)
    {
        return string::tformat(
            "Invalid instruction '%s'. The instruction must begin with SQR or TRI.",
            instruction
        );
    }

    // --------------------------------------------------------
    // A space cannot be the final character.
    // --------------------------------------------------------

    if (space_position >= instruction.len - 1)
    {
        return string::tformat(
            "Invalid instruction '%s'. Coordinates are required after the command.",
            instruction
        );
    }

    // --------------------------------------------------------
    // Exactly ONE space is allowed in the instruction.
    // --------------------------------------------------------

    for (usz i = 0; i < instruction.len; i++)
    {
        if (
            instruction[i] == ' '
            && i != (usz)space_position
        )
        {
            return string::tformat(
                "Invalid instruction '%s'. The instruction must contain exactly one space between the command and its coordinates.",
                instruction
            );
        }
    }

    // --------------------------------------------------------
    // Extract command.
    // --------------------------------------------------------

    String command =
        instruction[0 .. space_position - 1];

    // --------------------------------------------------------
    // Extract coordinates.
    // --------------------------------------------------------

    String coordinates =
        instruction[
            space_position + 1
            .. instruction.len - 1
        ];

    // ========================================================
    // SQR
    // ========================================================

    if (command == "SQR")
    {
        String[] coords =
            coordinates.split(tmem, "-");

        if (coords.len != 2)
        {
            return "Invalid SQR instruction. SQR requires exactly two coordinates separated by a dash (-).";
        }

        String error =
            get_coordinate_error(coords[0]);

        if (error.len != 0)
        {
            return error;
        }

        error =
            get_coordinate_error(coords[1]);

        if (error.len != 0)
        {
            return error;
        }

        return "";
    }

    // ========================================================
    // TRI
    // ========================================================

    if (command == "TRI")
    {
        String[] coords =
            coordinates.split(tmem, "-");

        if (coords.len != 3)
        {
            return "Invalid TRI instruction. TRI requires exactly three coordinates separated by dashes (-).";
        }

        String error =
            get_coordinate_error(coords[0]);

        if (error.len != 0)
        {
            return error;
        }

        error =
            get_coordinate_error(coords[1]);

        if (error.len != 0)
        {
            return error;
        }

        error =
            get_coordinate_error(coords[2]);

        if (error.len != 0)
        {
            return error;
        }

        return "";
    }

    // --------------------------------------------------------
    // Unknown command.
    // --------------------------------------------------------

    return string::tformat(
        "Invalid command '%s'. The only valid commands are SQR and TRI.",
        command
    );
}


// ============================================================
// VALIDATE COMPLETE PROGRAM
// ============================================================

fn bool validate_program(String input)
{
    return get_program_error(input).len == 0;
}


// ============================================================
// GET PROGRAM ERROR
//
// Returns the first program-level or instruction-level error.
//
// The diagnostic function below checks EVERY instruction.
// ============================================================

fn String get_program_error(String input)
{
    // --------------------------------------------------------
    // Protect against slicing short input.
    // --------------------------------------------------------

    if (input.len < 10)
    {
        return "Invalid program. The input is too short to contain a valid program.";
    }

    // --------------------------------------------------------
    // Required beginning:
    //
//     begin <instructions> end
//          ^
//          exactly one space
// --------------------------------------------------------

    if (!input.starts_with("begin "))
    {
        return "Invalid program. The input must begin with 'begin' followed by exactly one space.";
    }

    // --------------------------------------------------------
    // Required ending:
    //
//     begin <instructions> end
//                          ^
//                          exactly one space
// --------------------------------------------------------

    if (!input.ends_with(" end"))
    {
        return "Invalid program. The input must end with exactly one space followed by 'end'.";
    }

    // --------------------------------------------------------
    // Extract instruction section.
//
//     begin SQR A1-C4 end
//           ^^^^^^^^^
// --------------------------------------------------------

    String instruction_text =
        input[6 .. input.len - 5];

    if (instruction_text.len == 0)
    {
        return "Invalid program. At least one instruction is required.";
    }

    // --------------------------------------------------------
    // Split instructions at periods.
    // --------------------------------------------------------

    String[] instructions =
        instruction_text.split(tmem, ".");

    for (usz i = 0; i < instructions.len; i++)
    {
        String instruction =
            instructions[i];

        // ----------------------------------------------------
        // First instruction must begin immediately.
        // ----------------------------------------------------

        if (i == 0)
        {
            if (instruction.len == 0)
            {
                return string::tformat(
                    "Instruction %d is empty.",
                    i + 1
                );
            }
        }
        else
        {
            // ------------------------------------------------
            // The grammar requires:
            //
            // <instruction> . <instruction>
            //               ^
            //          one space after period
            //
            // split() leaves that space attached to the next
            // instruction, so remove exactly that one separator
            // space.
            // ------------------------------------------------

            if (instruction.len == 0)
            {
                return string::tformat(
                    "Instruction %d is empty.",
                    i + 1
                );
            }

            if (instruction[0] != ' ')
            {
                return string::tformat(
                    "Instruction %d: A period must be followed by exactly one space.",
                    i + 1
                );
            }

            // Remove exactly one separator space.
            instruction =
                instruction[1 .. instruction.len - 1];

            if (instruction.len == 0)
            {
                return string::tformat(
                    "Instruction %d is empty.",
                    i + 1
                );
            }

            // Reject multiple spaces after the period.
            if (instruction[0] == ' ')
            {
                return string::tformat(
                    "Instruction %d: A period must be followed by exactly one space.",
                    i + 1
                );
            }
        }

        // ----------------------------------------------------
        // Validate the individual instruction.
        // ----------------------------------------------------

        String error =
            get_instruction_error(instruction);

        if (error.len != 0)
        {
            return string::tformat(
                "Instruction %d: %s",
                i + 1,
                error
            );
        }
    }

    return "";
}


// ============================================================
// DISPLAY PROGRAM DIAGNOSTICS
//
// Checks EVERY instruction instead of stopping at the first
// error.
//
// Returns:
// true  = complete program is valid
// false = program contains an error
//
// Example:
//
// ERROR: Invalid program.
//
// Instruction 1: VALID
//   SQR A1-C4
//
// Instruction 2: INVALID
//   TRI H1-G3
//   Reason: ...
//
// Overall result: INVALID PROGRAM
// ============================================================

fn bool display_program_diagnostics(String input)
{
    // --------------------------------------------------------
    // Check minimum length before slicing.
    // --------------------------------------------------------

    if (input.len < 10)
    {
        io::printn("ERROR: Invalid program.");
        io::printn("");
        io::printn(
            "Reason: The input is too short to contain a valid program."
        );
        io::printn("");
        io::printn("Overall result: INVALID PROGRAM");

        return false;
    }

    // --------------------------------------------------------
    // Check beginning.
    // --------------------------------------------------------

    if (!input.starts_with("begin "))
    {
        io::printn("ERROR: Invalid program.");
        io::printn("");
        io::printn(
            "Reason: The input must begin with 'begin' followed by exactly one space."
        );
        io::printn("");
        io::printn("Overall result: INVALID PROGRAM");

        return false;
    }

    // --------------------------------------------------------
    // Check ending.
    // --------------------------------------------------------

    if (!input.ends_with(" end"))
    {
        io::printn("ERROR: Invalid program.");
        io::printn("");
        io::printn(
            "Reason: The input must end with exactly one space followed by 'end'."
        );
        io::printn("");
        io::printn("Overall result: INVALID PROGRAM");

        return false;
    }

    // --------------------------------------------------------
    // Extract instructions.
    // --------------------------------------------------------

    String instruction_text =
        input[6 .. input.len - 5];

    if (instruction_text.len == 0)
    {
        io::printn("ERROR: Invalid program.");
        io::printn("");
        io::printn(
            "Reason: At least one instruction is required."
        );
        io::printn("");
        io::printn("Overall result: INVALID PROGRAM");

        return false;
    }

    String[] instructions =
        instruction_text.split(tmem, ".");

    bool overall_valid = true;

    io::printn("ERROR: Invalid program.");
    io::printn("");

    // --------------------------------------------------------
    // Check every instruction.
    // --------------------------------------------------------

    for (usz i = 0; i < instructions.len; i++)
    {
        String instruction =
            instructions[i];

        // ----------------------------------------------------
        // Remove exactly one required separator space from
        // instructions after the first one.
        // ----------------------------------------------------

        if (i > 0)
        {
            if (instruction.len > 0 && instruction[0] == ' ')
            {
                instruction =
                    instruction[1 .. instruction.len - 1];
            }
        }

        String error;

        if (instruction.len == 0)
        {
            error = "The instruction is empty.";
        }
        else
        {
            error =
                get_instruction_error(instruction);
        }

        io::printfn(
            "Instruction %d: %s",
            i + 1,
            error.len == 0 ? "VALID" : "INVALID"
        );

        io::printfn(
            "  %s",
            instruction
        );

        if (error.len != 0)
        {
            io::printfn(
                "  Reason: %s",
                error
            );

            overall_valid = false;
        }

        io::printn("");
    }

    // --------------------------------------------------------
    // Overall result.
    // --------------------------------------------------------

    if (overall_valid)
    {
        io::printn("Overall result: VALID PROGRAM");
    }
    else
    {
        io::printn("Overall result: INVALID PROGRAM");
    }

    return overall_valid;
}