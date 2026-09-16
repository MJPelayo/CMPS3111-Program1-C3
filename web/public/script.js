

const programInput = document.getElementById("programInput");
const validateButton = document.getElementById("validateButton");
const resultContent = document.getElementById("resultContent");
const outputSection = document.getElementById("outputSection");

const derivationOutput =
    document.getElementById("derivationOutput");

const parseTreeOutput =
    document.getElementById("parseTreeOutput");

const connectionStatus =
    document.getElementById("connectionStatus");


// ============================================================
// EXAMPLE PROGRAMS
// ============================================================

const examples = {

    sqr:
        "begin SQR A1-C4 end",

    tri:
        "begin TRI A1-C6-G3 end",

    multiple:
        "begin SQR A1-C4. TRI A1-C6-G3 end"
};


// ============================================================
// LOAD EXAMPLE
// ============================================================

function loadExample(type) {

    if (examples[type]) {
        programInput.value = examples[type];
    }

    programInput.focus();
}


// ============================================================
// VALIDATE PROGRAM
// ============================================================

async function recognizeProgram() {

    // Do NOT trim the input.
    // Whitespace is significant in the grammar.

    const input = programInput.value;


    // --------------------------------------------------------
    // Check for empty input.
    // --------------------------------------------------------

    if (!input) {

        showError(
            "Please enter a program before validating."
        );

        return;
    }


    // --------------------------------------------------------
    // Show processing state.
    // --------------------------------------------------------

    setProcessingState(true);


    // --------------------------------------------------------
    // Hide old derivation / parse tree results.
    // They will only appear again if the complete program
    // is valid.
    // --------------------------------------------------------

    outputSection.classList.add("hidden");


    try {

        // ----------------------------------------------------
        // Send program to the C3 backend.
        // ----------------------------------------------------

        const response = await fetch(
            "/api/recognize",
            {
                method: "POST",

                headers: {
                    "Content-Type": "application/json"
                },

                body: JSON.stringify({
                    input: input
                })
            }
        );


        // ----------------------------------------------------
        // Read API response.
        // ----------------------------------------------------

        const data = await response.json();


        // ----------------------------------------------------
        // Handle HTTP errors.
        // ----------------------------------------------------

        if (!response.ok) {

            showError(
                data.error ||
                "The server could not process the program."
            );

            return;
        }


        // ----------------------------------------------------
        // Display the complete validation result.
        // ----------------------------------------------------

        displayRecognitionResult(data);

    }
    catch (error) {

        console.error(error);

        showError(
            "Could not connect to the C3 backend. " +
            "Make sure the API server is running."
        );

    }
    finally {

        // ----------------------------------------------------
        // Restore button.
        // ----------------------------------------------------

        setProcessingState(false);
    }
}


// ============================================================
// DISPLAY RECOGNITION RESULT
// ============================================================

function displayRecognitionResult(data) {

    const instructionResults =
        data.instructionResults || [];


    // --------------------------------------------------------
    // Count valid and invalid instructions.
    // --------------------------------------------------------

    const validCount =
        instructionResults.filter(
            instruction => instruction.valid
        ).length;

    const invalidCount =
        instructionResults.length - validCount;


    // ========================================================
    // COMPLETE PROGRAM VALID
    // ========================================================

    if (data.valid) {

        connectionStatus.textContent = "VALID";
        connectionStatus.className =
            "connection-status success-status";


        resultContent.className =
            "result-content success-result";


        resultContent.innerHTML = `

            <div class="result-icon success-icon">
                ✓
            </div>

            <h3>Program Valid</h3>

            <p>
                All ${instructionResults.length}
                instruction${instructionResults.length === 1 ? "" : "s"}
                follow the BNF grammar.
            </p>

            <div class="instruction-summary">
                <span class="summary-valid">
                    ✓ ${validCount} Correct
                </span>
            </div>

            <div class="instruction-results">
                ${buildInstructionResults(instructionResults)}
            </div>
        `;


        // ----------------------------------------------------
        // Display derivation and parse tree.
        // ----------------------------------------------------

        derivationOutput.textContent =
            data.derivation || "";

        parseTreeOutput.textContent =
            data.parseTree || "";

        outputSection.classList.remove("hidden");


        // ----------------------------------------------------
        // Make sure derivation tab is selected.
        // ----------------------------------------------------

        resetOutputTabs();

        return;
    }


    // ========================================================
    // COMPLETE PROGRAM INVALID
    // ========================================================

    connectionStatus.textContent = "INVALID";
    connectionStatus.className =
        "connection-status error-status";


    resultContent.className =
        "result-content error-result";


    resultContent.innerHTML = `

        <div class="result-icon error-icon">
            ✕
        </div>

        <h3>Program Invalid</h3>

        <p>
            ${invalidCount} of
            ${instructionResults.length}
            instruction${instructionResults.length === 1 ? "" : "s"}
            contain${invalidCount === 1 ? "s" : ""} error${invalidCount === 1 ? "" : "s"}.
        </p>

        <div class="instruction-summary">

            <span class="summary-valid">
                ✓ ${validCount} Correct
            </span>

            <span class="summary-invalid">
                ✕ ${invalidCount} Wrong
            </span>

        </div>

        <div class="instruction-results">
            ${buildInstructionResults(instructionResults)}
        </div>

        ${
            instructionResults.length === 0
                ? `
                    <div class="program-error">
                        <strong>Program Error</strong>
                        <p>
                            ${escapeHtml(
                                data.error ||
                                "The program does not follow the grammar."
                            )}
                        </p>
                    </div>
                  `
                : ""
        }

    `;
}


// ============================================================
// BUILD INDIVIDUAL INSTRUCTION RESULTS
// ============================================================

function buildInstructionResults(results) {

    if (!results || results.length === 0) {

        return `
            <div class="no-instructions">
                No individual instruction results available.
            </div>
        `;
    }


    return results.map(instruction => {

        // ----------------------------------------------------
        // VALID INSTRUCTION
        // ----------------------------------------------------

        if (instruction.valid) {

            return `

                <div class="instruction-card instruction-valid">

                    <div class="instruction-icon">
                        ✓
                    </div>

                    <div class="instruction-details">

                        <div class="instruction-heading">
                            Instruction ${instruction.number}
                        </div>

                        <div class="instruction-code">
                            ${escapeHtml(
                                instruction.instruction
                            )}
                        </div>

                        <div class="instruction-message valid-message">
                            Valid instruction
                        </div>

                    </div>

                </div>

            `;
        }


        // ----------------------------------------------------
        // INVALID INSTRUCTION
        // ----------------------------------------------------

        return `

            <div class="instruction-card instruction-invalid">

                <div class="instruction-icon">
                    ✕
                </div>

                <div class="instruction-details">

                    <div class="instruction-heading">
                        Instruction ${instruction.number}
                    </div>

                    <div class="instruction-code">
                        ${escapeHtml(
                            instruction.instruction
                        )}
                    </div>

                    <div class="instruction-message error-message">

                        <strong>What's wrong:</strong>

                        <p>
                            ${escapeHtml(
                                instruction.error
                            )}
                        </p>

                    </div>

                </div>

            </div>

        `;

    }).join("");
}


// ============================================================
// PROCESSING STATE
// ============================================================

function setProcessingState(isProcessing) {

    if (isProcessing) {

        validateButton.disabled = true;

        validateButton.innerHTML =
            "<span>⟳</span> VALIDATING...";

        connectionStatus.textContent =
            "CHECKING";

        connectionStatus.className =
            "connection-status processing-status";


        resultContent.className =
            "result-content processing-result";


        resultContent.innerHTML = `

            <div class="result-icon processing-icon">
                ⟳
            </div>

            <h3>Checking Program...</h3>

            <p>
                Sending your program to the
                C3 language recognizer.
            </p>

        `;

    }
    else {

        validateButton.disabled = false;

        validateButton.innerHTML =
            "<span>▶</span> VALIDATE PROGRAM";
    }
}


// ============================================================
// SHOW ERROR
// ============================================================

function showError(message) {

    connectionStatus.textContent = "ERROR";

    connectionStatus.className =
        "connection-status error-status";


    resultContent.className =
        "result-content error-result";


    resultContent.innerHTML = `

        <div class="result-icon error-icon">
            !
        </div>

        <h3>Unable to Validate</h3>

        <p>
            ${escapeHtml(message)}
        </p>

    `;


    outputSection.classList.add("hidden");
}


// ============================================================
// CLEAR PROGRAM
// ============================================================

function clearProgram() {

    programInput.value = "";

    connectionStatus.textContent =
        "READY";

    connectionStatus.className =
        "connection-status";


    resultContent.className =
        "result-content empty-result";


    resultContent.innerHTML = `

        <div class="result-icon">
            &lt;?&gt;
        </div>

        <h3>Waiting for input</h3>

        <p>
            Enter a program and select
            <strong>Validate Program</strong>.
        </p>

    `;


    outputSection.classList.add("hidden");

    programInput.focus();
}


// ============================================================
// TAB SWITCHING
// ============================================================

function showTab(tab, button) {

    const derivationTab =
        document.getElementById("derivationTab");

    const treeTab =
        document.getElementById("treeTab");

    const tabButtons =
        document.querySelectorAll(".tab-button");


    tabButtons.forEach(
        item => item.classList.remove("active")
    );


    if (tab === "derivation") {

        derivationTab.classList.add("active");
        treeTab.classList.remove("active");

        button.classList.add("active");

    }
    else if (tab === "tree") {

        treeTab.classList.add("active");
        derivationTab.classList.remove("active");

        button.classList.add("active");
    }
}


// ============================================================
// RESET OUTPUT TABS
// ============================================================

function resetOutputTabs() {

    const derivationTab =
        document.getElementById("derivationTab");

    const treeTab =
        document.getElementById("treeTab");

    const tabButtons =
        document.querySelectorAll(".tab-button");


    derivationTab.classList.add("active");
    treeTab.classList.remove("active");


    tabButtons.forEach(
        item => item.classList.remove("active")
    );


    if (tabButtons.length > 0) {
        tabButtons[0].classList.add("active");
    }
}


// ============================================================
// ESCAPE HTML
// ============================================================

function escapeHtml(value) {

    if (value === null || value === undefined) {
        return "";
    }


    return String(value)
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}


// ============================================================
// KEYBOARD SHORTCUT
// ============================================================

programInput.addEventListener(
    "keydown",
    function (event) {

        // Ctrl + Enter
        if (event.ctrlKey && event.key === "Enter") {

            event.preventDefault();

            recognizeProgram();
        }
    }
);


// ============================================================
// HELP / INSTRUCTIONS MODAL
// ============================================================

function openHelp() {

    const helpModal =
        document.getElementById("helpModal");

    if (!helpModal) {
        return;
    }

    helpModal.classList.remove("hidden");

    helpModal.setAttribute("aria-hidden", "false");

    const closeButton =
        document.getElementById("helpClose");

    if (closeButton) {
        closeButton.focus();
    }
}


function closeHelp() {

    const helpModal =
        document.getElementById("helpModal");

    if (!helpModal) {
        return;
    }

    helpModal.classList.add("hidden");

    helpModal.setAttribute("aria-hidden", "true");

    programInput.focus();
}


const helpModal =
    document.getElementById("helpModal");

if (helpModal) {

    helpModal.addEventListener(
        "click",
        function (event) {

            if (event.target === helpModal) {
                closeHelp();
            }
        }
    );
}


document.addEventListener(
    "keydown",
    function (event) {

        if (event.key === "Escape") {

            const modal =
                document.getElementById("helpModal");

            if (
                modal &&
                !modal.classList.contains("hidden")
            ) {
                closeHelp();
            }
        }
    }
);

