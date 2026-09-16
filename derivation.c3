module derivation;

import std::io;


// ============================================================
// DISPLAY RIGHTMOST DERIVATION
//
// A rightmost derivation always expands the rightmost
// nonterminal in the current sentential form.
//
// Grammar:
//
// <program> → begin <instructions> end
//
// <instructions> → <instruction>
//                 | <instruction> . <instructions>
//
// <instruction> → SQR <coord>-<coord>
//                | TRI <coord>-<coord>-<coord>
//
// <coord> → <x><y>
//
// <x> → A | B | C | D | E | F | G
//
// <y> → 1 | 2 | 3 | 4 | 5 | 6
// ============================================================

fn void display_rightmost_derivation(String input)
{
    io::printn("");
    io::printn("==================================================");
    io::printn("             RIGHTMOST DERIVATION");
    io::printn("==================================================");
    io::printn("");


    // --------------------------------------------------------
    // Extract the instruction section from the valid input.
    //
    // C#:
    // input.Substring(6, input.Length - 10)
    //
    // begin = 5 characters
    // following space = 1 character
    // ending " end" = 4 characters
    // --------------------------------------------------------

    String instruction_text =
        input[6 .. input.len - 4];

    String[] instructions =
        instruction_text.split('.');


    // --------------------------------------------------------
    // Start symbol.
    // --------------------------------------------------------

    String current = "<program>";

    io::printn(current);


    // --------------------------------------------------------
    // <program> → begin <instructions> end
    // --------------------------------------------------------

    current = "begin <instructions> end";

    io::printfn("=> %s", current);


    // --------------------------------------------------------
    // Expand <instructions>.
    //
    // For multiple instructions:
    //
    // <instructions>
    //     → <instruction> . <instructions>
    //
    // The rightmost <instructions> is expanded first.
    // --------------------------------------------------------

    if (instructions.len == 1)
    {
        current = replace_rightmost(
            current,
            "<instructions>",
            "<instruction>"
        );

        io::printfn("=> %s", current);
    }
    else
    {
        // Continue applying the recursive rule until there
        // is one <instruction> placeholder for every input
        // instruction.

        for (usz i = 0; i < instructions.len - 1; i++)
        {
            current = replace_rightmost(
                current,
                "<instructions>",
                "<instruction> . <instructions>"
            );

            io::printfn("=> %s", current);
        }


        // The final <instructions> becomes <instruction>.

        current = replace_rightmost(
            current,
            "<instructions>",
            "<instruction>"
        );

        io::printfn("=> %s", current);
    }


    // --------------------------------------------------------
    // Expand instructions from RIGHT TO LEFT.
    // --------------------------------------------------------

    for (usz i = instructions.len; i > 0; i--)
    {
        usz instruction_index = i - 1;

        String instruction =
            instructions[instruction_index].trim();


        // Split instruction into command and coordinates.

        String[] parts =
            instruction.split(" ", true);

        String command = parts[0];

        String coordinates_text = parts[1];

        String[] coordinates =
            coordinates_text.split('-');


        // ----------------------------------------------------
        // Replace the rightmost <instruction>.
        // ----------------------------------------------------

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


        current = replace_rightmost(
            current,
            "<instruction>",
            instruction_production
        );

        io::printfn("=> %s", current);


        // ----------------------------------------------------
        // Expand the coordinates from RIGHT TO LEFT.
        // ----------------------------------------------------

        for (usz j = coordinates.len; j > 0; j--)
        {
            usz coordinate_index = j - 1;

            String coordinate =
                coordinates[coordinate_index];


            // ------------------------------------------------
            // <coord> → <x><y>
            // ------------------------------------------------

            current = replace_rightmost(
                current,
                "<coord>",
                "<x><y>"
            );

            io::printfn("=> %s", current);


            // ------------------------------------------------
            // <y> → actual Y value
            // ------------------------------------------------

            current = replace_rightmost(
                current,
                "<y>",
                coordinate[1 .. 2]
            );

            io::printfn("=> %s", current);


            // ------------------------------------------------
            // <x> → actual X value
            // ------------------------------------------------

            current = replace_rightmost(
                current,
                "<x>",
                coordinate[0 .. 1]
            );

            io::printfn("=> %s", current);
        }
    }


    // --------------------------------------------------------
    // Final generated sentence.
    // --------------------------------------------------------

    io::printn("");
    io::printn("Final generated sentence:");
    io::printn(current);

    io::printn("");
    io::printn("==================================================");
}


// ============================================================
// REPLACE RIGHTMOST OCCURRENCE
//
// This helper allows the program to perform a true
// rightmost derivation.
// ============================================================

fn String replace_rightmost(
    String text,
    String old_value,
    String new_value
)
{
    // Find the final occurrence of old_value.

    isz position =
        text.rfind(old_value);


    // If the value does not exist, return the original text.

    if (position < 0)
    {
        return text;
    }


    // Build the resulting string:
    //
    // text before occurrence
    // +
    // new value
    // +
    // text after occurrence

    return text[0 .. position]
        + new_value
        + text[position + old_value.len .. text.len];
}