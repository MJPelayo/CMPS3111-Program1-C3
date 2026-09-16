module parse_tree;

import std::io;


// ============================================================
// DISPLAY PARSE TREE
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

fn void display_parse_tree(String input)
{
    io::printn("");
    io::printn("==================================================");
    io::printn("                    PARSE TREE");
    io::printn("==================================================");
    io::printn("");

    // Extract the instruction section.
    String instruction_text = input[6 .. input.len - 4];

    // Separate instructions using the period.
    String[] instructions = instruction_text.split('.');

    io::printn("<program>");
    io::printn("├── begin");

    // <instructions> is a child of <program>.
    io::printn("├── <instructions>");

    display_instructions_tree(
        instructions,
        0,
        "│   "
    );

    // end is the final child of <program>.
    io::printn("└── end");

    io::printn("");
    io::printn("==================================================");
}


// ============================================================
// DISPLAY <instructions> TREE
//
// Grammar:
//
// <instructions> → <instruction>
//                 | <instruction> . <instructions>
//
// This method recursively displays the structure of
// multiple instructions.
// ============================================================

fn void display_instructions_tree(
    String[] instructions,
    usz index,
    String prefix
)
{
    String instruction =
        instructions[index].trim();

    bool last_instruction =
        index == instructions.len - 1;


    // --------------------------------------------------------
    // <instruction>
    // --------------------------------------------------------

    if (last_instruction)
    {
        io::printfn(
            "%s└── <instruction>",
            prefix
        );

        display_instruction_tree(
            instruction,
            prefix + "    "
        );
    }
    else
    {
        io::printfn(
            "%s├── <instruction>",
            prefix
        );

        display_instruction_tree(
            instruction,
            prefix + "│   "
        );


        // ----------------------------------------------------
        // Period between instructions.
        // ----------------------------------------------------

        io::printfn(
            "%s├── .",
            prefix
        );


        // ----------------------------------------------------
        // Recursive <instructions>.
        // ----------------------------------------------------

        io::printfn(
            "%s└── <instructions>",
            prefix
        );

        display_instructions_tree(
            instructions,
            index + 1,
            prefix + "    "
        );
    }
}


// ============================================================
// DISPLAY <instruction> TREE
// ============================================================

fn void display_instruction_tree(
    String instruction,
    String prefix
)
{
    String[] parts =
        instruction.split(" ", true);

    String command = parts[0];

    String coordinates_text = parts[1];

    String[] coordinates =
        coordinates_text.split('-');


    // ========================================================
    // SQR
    // ========================================================

    if (command == "SQR")
    {
        io::printfn(
            "%s├── SQR",
            prefix
        );


        // First coordinate.

        io::printfn(
            "%s├── <coord>",
            prefix
        );

        display_coordinate_tree(
            coordinates[0],
            prefix + "│   "
        );


        // Dash.

        io::printfn(
            "%s├── -",
            prefix
        );


        // Second coordinate.

        io::printfn(
            "%s└── <coord>",
            prefix
        );

        display_coordinate_tree(
            coordinates[1],
            prefix + "    "
        );
    }


    // ========================================================
    // TRI
    // ========================================================

    else if (command == "TRI")
    {
        io::printfn(
            "%s├── TRI",
            prefix
        );


        // First coordinate.

        io::printfn(
            "%s├── <coord>",
            prefix
        );

        display_coordinate_tree(
            coordinates[0],
            prefix + "│   "
        );


        // First dash.

        io::printfn(
            "%s├── -",
            prefix
        );


        // Second coordinate.

        io::printfn(
            "%s├── <coord>",
            prefix
        );

        display_coordinate_tree(
            coordinates[1],
            prefix + "│   "
        );


        // Second dash.

        io::printfn(
            "%s├── -",
            prefix
        );


        // Third coordinate.

        io::printfn(
            "%s└── <coord>",
            prefix
        );

        display_coordinate_tree(
            coordinates[2],
            prefix + "    "
        );
    }
}


// ============================================================
// DISPLAY <coord> TREE
//
// Grammar:
//
// <coord> → <x><y>
// ============================================================

fn void display_coordinate_tree(
    String coordinate,
    String prefix
)
{
    char x = coordinate[0];
    char y = coordinate[1];


    io::printfn(
        "%s├── <x>",
        prefix
    );

    io::printfn(
        "%s│   └── %c",
        prefix,
        x
    );


    io::printfn(
        "%s└── <y>",
        prefix
    );

    io::printfn(
        "%s    └── %c",
        prefix,
        y
    );
}