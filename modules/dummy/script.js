// This script is executed by Terraform's 'external' data source.
// It must read JSON from STDIN and output JSON to STDOUT.
// All process logs (console.error, console.log not in the final output) go to STDERR.

const { execSync } = require('child_process');

/**
 * Sleeps synchronously by calling the system's sleep command.
 * This is used to block the process thread as required by the 'external' data source.
 * @param {number} seconds - The duration to sleep.
 */
const sleepSync = (seconds) => {
    if (seconds > 0) {
        console.error(`Starting synchronous sleep for ${seconds} seconds...`);
        // Use 'execSync' to call the system's sleep command (sh-compatible)
        // This blocks the Node.js process until the shell command finishes.
        try {
            execSync(`sh -c "sleep ${seconds}"`);
            console.error("Sleep finished.");
        } catch (e) {
            console.error(`Error during sleep: ${e.message}`);
        }
    }
};

/**
 * Forces the Node.js process to exit with a non-zero code (1), 
 * which Terraform's 'external' data source interprets as a failure.
 */
const crash = () => {
    // Write a clear message to stderr (which Terraform displays)
    console.error("--- PLAN-TIME CRASH INITIATED: Calling process.exit(1) ---");
    // Force immediate process exit with error code 1
    process.exit(1);
};

// --- Main Execution Logic ---

let input = {};
let inputData = '';

try {
    // Read the entire STDIN (the JSON query from Terraform)
    inputData = require('fs').readFileSync(0, 'utf8');
    input = JSON.parse(inputData);
} catch (e) {
    // Output error to STDERR, which Terraform shows as a log
    console.error("Failed to read or parse JSON input from STDIN:", e.message);
    // Crash immediately if input is invalid
    process.exit(1);
}

// Extract variables
const { instance_name, sleep_duration, enable_crash } = input;

let slept_for = 0;
let did_crash = "false";
let message = `Execution successful for instance: ${instance_name}`;

// Feature 1: Crash logic
// Check for both boolean true and string "true" for robust input handling
if (enable_crash === true || enable_crash === "true") {
    did_crash = "true";
    message = `Plan failure requested for instance: ${instance_name}`;
    crash(); // This line exits the process if reached
}

// Feature 2: Sleep logic (only if not crashing)
const sleepSeconds = Number(sleep_duration);
if (sleepSeconds > 0) {
    sleepSync(sleepSeconds);
    slept_for = sleepSeconds;
}

// The script MUST write a single JSON object to STDOUT
// All values MUST be strings for Terraform's 'external' data source compatibility.
const output = {
    message: String(message),
    timestamp: String(new Date().toISOString()),
    diag_slept_for_s: String(slept_for),
    diag_crashed: String(did_crash)
};

// Write the final JSON result to STDOUT
console.log(JSON.stringify(output));

// Exit successfully
process.exit(0);

