module derivation;

import std::io;


// ============================================================
// DISPLAY RIGHTMOST DERIVATION
// ============================================================

fn void display_rightmost_derivation(String input)
{
    io::printn("");
    io::printn("==================================================");
    io::printn("             RIGHTMOST DERIVATION");
    io::printn("==================================================");
    io::printn("");

    String instruction_text =
        input[6 .. input.len - 5];

    String[] instructions =
        instruction_text.split(tmem, ".");

    String current = "<program>";

    io::printn(current);

    current = "begin <instructions> end";

    io::printfn("=> %s", current);

    // --------------------------------------------------------
    // Expand <instructions>
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
        for (usz i = 0; i < instructions.len - 1; i++)
        {
            current = replace_rightmost(
                current,
                "<instructions>",
                "<instruction> . <instructions>"
            );

            io::printfn("=> %s", current);
        }

        current = replace_rightmost(
            current,
            "<instructions>",
            "<instruction>"
        );

        io::printfn("=> %s", current);
    }

    // --------------------------------------------------------
    // Expand instructions RIGHT TO LEFT
    // --------------------------------------------------------

    for (usz i = instructions.len; i > 0; i--)
    {
        usz instruction_index = i - 1;

        String instruction =
            instructions[instruction_index].trim();

        String[] parts =
            instruction.split(tmem, " ");

        String command =
            parts[0];

        String coordinates_text =
            parts[1];

        String[] coordinates =
            coordinates_text.split(tmem, "-");

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
        // Expand coordinates RIGHT TO LEFT
        // ----------------------------------------------------

        for (usz j = coordinates.len; j > 0; j--)
        {
            usz coordinate_index = j - 1;

            String coordinate =
                coordinates[coordinate_index];

            current = replace_rightmost(
                current,
                "<coord>",
                "<x><y>"
            );

            io::printfn("=> %s", current);

            // Replace <y> with the actual Y character.
            current = replace_rightmost(
                current,
                "<y>",
                coordinate[1 .. 1]
            );

            io::printfn("=> %s", current);

            // Replace <x> with the actual X character.
            current = replace_rightmost(
                current,
                "<x>",
                coordinate[0 .. 0]
            );

            io::printfn("=> %s", current);
        }
    }

    io::printn("");
    io::printn("Final generated sentence:");
    io::printn(current);

    io::printn("");
    io::printn("==================================================");
}


// ============================================================
// REPLACE RIGHTMOST OCCURRENCE
// ============================================================

fn String replace_rightmost(
    String text,
    String old_value,
    String new_value
)
{
    sz? position =
        text.rindex_of(old_value);

    if (catch position)
    {
        return text;
    }

    String before;

    if (position == 0)
    {
        before = "";
    }
    else
    {
        before =
            text[0 .. position - 1];
    }

    sz after_start =
        position + old_value.len;

    String after;

    if (after_start >= text.len)
    {
        after = "";
    }
    else
    {
        after =
            text[after_start .. text.len - 1];
    }

    return string::tformat(
        "%s%s%s",
        before,
        new_value,
        after
    );
}