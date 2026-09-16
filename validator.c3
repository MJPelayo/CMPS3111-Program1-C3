module validator;


// ============================================================
// VALIDATE COORDINATE
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
    if (coordinate.len != 2)
    {
        return string::tformat(
            "Invalid coordinate '%s'. A coordinate must contain exactly two characters.",
            coordinate
        );
    }

    char x = coordinate[0];
    char y = coordinate[1];

    bool valid_x = x >= 'A' && x <= 'G';
    bool valid_y = y >= '1' && y <= '6';


    if (!valid_x && !valid_y)
    {
        return string::tformat(
            "Invalid coordinate '%s'. '%c' is not a valid X value and '%c' is not a valid Y value. X must be A through G and Y must be 1 through 6.",
            coordinate,
            x,
            y
        );
    }


    if (!valid_x)
    {
        return string::tformat(
            "Invalid coordinate '%s'. '%c' is not a valid X value. X must be A through G.",
            coordinate,
            x
        );
    }


    if (!valid_y)
    {
        return string::tformat(
            "Invalid coordinate '%s'. '%c' is a valid X value, but '%c' is not a valid Y value. Y must be 1 through 6.",
            coordinate,
            x,
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
// ============================================================

fn String get_instruction_error(String instruction)
{
    String[] parts =
        instruction.split(tmem, " ");

    if (parts.len != 2)
    {
        return string::tformat(
            "Invalid instruction '%s'. The instruction must contain a command followed by its coordinates.",
            instruction
        );
    }

    String command = parts[0];
    String coordinates = parts[1];


    // --------------------------------------------------------
    // SQR
    // --------------------------------------------------------

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


    // --------------------------------------------------------
    // TRI
    // --------------------------------------------------------

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
// ============================================================

fn String get_program_error(String input)
{
    if (!input.starts_with("begin "))
    {
        return "Invalid program. The input must begin with 'begin'.";
    }


    if (!input.ends_with(" end"))
    {
        return "Invalid program. The input must end with 'end'.";
    }


    String instruction_text =
        input[6 .. input.len - 4];


    if (instruction_text.trim().len == 0)
    {
        return "Invalid program. At least one instruction is required.";
    }


    String[] instructions =
        instruction_text.split(tmem, ".");


    for (usz i = 0; i < instructions.len; i++)
    {
        String instruction =
            instructions[i].trim();


        if (instruction.len == 0)
        {
            return "Invalid program. An empty instruction was found.";
        }


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