module validator;


// ============================================================
// VALIDATE COORDINATE
//
// Grammar:
// <coord> → <x><y>
// <x> → A | B | C | D | E | F | G
// <y> → 1 | 2 | 3 | 4 | 5 | 6
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
        return "Invalid coordinate '%s'. A coordinate must contain exactly two characters."
            .format(coordinate);
    }

    char x = coordinate[0];
    char y = coordinate[1];

    // X must be A through G.
    bool valid_x = x >= 'A' && x <= 'G';

    // Y must be 1 through 6.
    bool valid_y = y >= '1' && y <= '6';


    // Both X and Y are invalid.
    if (!valid_x && !valid_y)
    {
        return "Invalid coordinate '%s'. '%c' is not a valid X value and '%c' is not a valid Y value. X must be A through G and Y must be 1 through 6."
            .format(coordinate, x, y);
    }


    // X is invalid.
    if (!valid_x)
    {
        return "Invalid coordinate '%s'. '%c' is not a valid X value. X must be A through G."
            .format(coordinate, x);
    }


    // Y is invalid.
    if (!valid_y)
    {
        return "Invalid coordinate '%s'. %c is a valid X value, but %c is not a valid Y value. Y must be 1 through 6."
            .format(coordinate, x, y);
    }


    // The coordinate is valid.
    return "";
}


// ============================================================
// VALIDATE INSTRUCTION
//
// Grammar:
// <instruction> → SQR <coord>-<coord>
//                | TRI <coord>-<coord>-<coord>
// ============================================================

fn bool validate_instruction(String instruction)
{
    return get_instruction_error(instruction).len == 0;
}


// ============================================================
// GET INSTRUCTION ERROR
// ============================================================

fn String get_instruction_error(String instruction)
{
    String[] parts = instruction.split(" ", true);

    // An instruction requires a command and coordinates.
    if (parts.len != 2)
    {
        return "Invalid instruction '%s'. The instruction must contain a command followed by its coordinates."
            .format(instruction);
    }

    String command = parts[0];
    String coordinates = parts[1];


    // ========================================================
    // SQR
    // ========================================================

    if (command == "SQR")
    {
        String[] coords = coordinates.split("-");

        // SQR requires exactly two coordinates.
        if (coords.len != 2)
        {
            return "Invalid SQR instruction. SQR requires exactly two coordinates separated by a dash (-).";
        }

        // Validate first coordinate.
        String error = get_coordinate_error(coords[0]);

        if (error.len != 0)
        {
            return error;
        }

        // Validate second coordinate.
        error = get_coordinate_error(coords[1]);

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
        String[] coords = coordinates.split("-");

        // TRI requires exactly three coordinates.
        if (coords.len != 3)
        {
            return "Invalid TRI instruction. TRI requires exactly three coordinates separated by dashes (-).";
        }

        // Validate first coordinate.
        String error = get_coordinate_error(coords[0]);

        if (error.len != 0)
        {
            return error;
        }

        // Validate second coordinate.
        error = get_coordinate_error(coords[1]);

        if (error.len != 0)
        {
            return error;
        }

        // Validate third coordinate.
        error = get_coordinate_error(coords[2]);

        if (error.len != 0)
        {
            return error;
        }

        return "";
    }


    // Unknown command.
    return "Invalid command '%s'. The only valid commands are SQR and TRI."
        .format(command);
}


// ============================================================
// VALIDATE COMPLETE PROGRAM
//
// Grammar:
// <program> → begin <instructions> end
//
// <instructions> → <instruction>
//                 | <instruction> . <instructions>
// ============================================================

fn bool validate_program(String input)
{
    return get_program_error(input).len == 0;
}


// ============================================================
// GET PROGRAM ERROR
// ============================================================

fn String get_program_error(String input)
{
    // The program must begin with "begin ".
    if (!input.starts_with("begin "))
    {
        return "Invalid program. The input must begin with 'begin'.";
    }

    // The program must end with " end".
    if (!input.ends_with(" end"))
    {
        return "Invalid program. The input must end with 'end'.";
    }

    // Extract everything between begin and end.
    String instruction_text =
        input[6 .. input.len - 4];

    // At least one instruction is required.
    if (instruction_text.trim().len == 0)
    {
        return "Invalid program. At least one instruction is required.";
    }

    // Multiple instructions are separated by periods.
    String[] instructions =
        instruction_text.split('.');

    // Validate every instruction.
    for (usz i = 0; i < instructions.len; i++)
    {
        String instruction =
            instructions[i].trim();

        // Check for an empty instruction.
        if (instruction.len == 0)
        {
            return "Invalid program. An empty instruction was found.";
        }

        // Validate the instruction.
        String error =
            get_instruction_error(instruction);

        if (error.len != 0)
        {
            return "Instruction %d: %s"
                .format(i + 1, error);
        }
    }

    // Everything follows the grammar.
    return "";
}