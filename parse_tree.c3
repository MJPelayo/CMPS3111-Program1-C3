module parse_tree;

import std::io;


// ============================================================
// DISPLAY PARSE TREE
// ============================================================

fn void display_parse_tree(String input)
{
    io::printn("");
    io::printn("==================================================");
    io::printn("                    PARSE TREE");
    io::printn("==================================================");
    io::printn("");


    String instruction_text =
        input[6 .. input.len - 4];


    String[] instructions =
        instruction_text.split(tmem, ".");


    io::printn("<program>");
    io::printn("├── begin");

    io::printn("├── <instructions>");


    display_instructions_tree(
        instructions,
        0,
        "│   "
    );


    io::printn("└── end");

    io::printn("");
    io::printn("==================================================");
}


// ============================================================
// DISPLAY INSTRUCTIONS TREE
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


    if (last_instruction)
    {
        io::printfn(
            "%s└── <instruction>",
            prefix
        );


        display_instruction_tree(
            instruction,
            string::tformat(
                "%s    ",
                prefix
            )
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
            string::tformat(
                "%s│   ",
                prefix
            )
        );


        io::printfn(
            "%s├── .",
            prefix
        );


        io::printfn(
            "%s└── <instructions>",
            prefix
        );


        display_instructions_tree(
            instructions,
            index + 1,
            string::tformat(
                "%s    ",
                prefix
            )
        );
    }
}


// ============================================================
// DISPLAY INSTRUCTION TREE
// ============================================================

fn void display_instruction_tree(
    String instruction,
    String prefix
)
{
    String[] parts =
        instruction.split(tmem, " ");


    String command =
        parts[0];


    String coordinates_text =
        parts[1];


    String[] coordinates =
        coordinates_text.split(tmem, "-");


    // --------------------------------------------------------
    // SQR
    // --------------------------------------------------------

    if (command == "SQR")
    {
        io::printfn(
            "%s├── SQR",
            prefix
        );


        io::printfn(
            "%s├── <coord>",
            prefix
        );


        display_coordinate_tree(
            coordinates[0],
            string::tformat(
                "%s│   ",
                prefix
            )
        );


        io::printfn(
            "%s├── -",
            prefix
        );


        io::printfn(
            "%s└── <coord>",
            prefix
        );


        display_coordinate_tree(
            coordinates[1],
            string::tformat(
                "%s    ",
                prefix
            )
        );
    }


    // --------------------------------------------------------
    // TRI
    // --------------------------------------------------------

    else if (command == "TRI")
    {
        io::printfn(
            "%s├── TRI",
            prefix
        );


        io::printfn(
            "%s├── <coord>",
            prefix
        );


        display_coordinate_tree(
            coordinates[0],
            string::tformat(
                "%s│   ",
                prefix
            )
        );


        io::printfn(
            "%s├── -",
            prefix
        );


        io::printfn(
            "%s├── <coord>",
            prefix
        );


        display_coordinate_tree(
            coordinates[1],
            string::tformat(
                "%s│   ",
                prefix
            )
        );


        io::printfn(
            "%s├── -",
            prefix
        );


        io::printfn(
            "%s└── <coord>",
            prefix
        );


        display_coordinate_tree(
            coordinates[2],
            string::tformat(
                "%s    ",
                prefix
            )
        );
    }
}


// ============================================================
// DISPLAY COORDINATE TREE
// ============================================================

fn void display_coordinate_tree(
    String coordinate,
    String prefix
)
{
    char x =
        coordinate[0];


    char y =
        coordinate[1];


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