#!/bin/bash

# Script to automate Nikto scans with user-friendly options

NIKTO_PATH="/path/to/your/nikto-master/program" # IMPORTANT: Update this to your Nikto program directory
PERL_COMMAND="perl" # Adjust if your perl command is different (e.g., /usr/bin/perl)

echo "--- Nikto Automated Scan Script ---"
echo "This script helps you run Nikto scans with various options."
echo "Please ensure Nikto is installed and the NIKTO_PATH is correctly set in the script."
echo "------------------------------------"

# Function to display help
display_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --host <target_host>     Specify the target host (IP or URL)."
    echo "  -p, --port <port_number>     Specify the target port (default: 80)."
    echo "  -v, --verbose                Enable verbose output (-Display V)."
    echo "  -o, --output <filename>      Specify output filename (e.g., results.html). Format inferred from extension."
    echo "  -f, --format <format_type>   Specify output format (csv, htm, msf+, nbe, txt, xml). Overrides extension inference."
    echo "  -e, --evasion <techniques>   Comma-separated list of evasion techniques (e.g., 1,2,A)."
    echo "                                  1: Random URI encoding (non-UTF8)"
    echo "                                  2: Directory self-reference (/./)"
    echo "                                  3: Premature URL ending"
    echo "                                  4: Prepend long random string"
    echo "                                  5: Fake parameter"
    echo "                                  6: TAB as request spacer"
    echo "                                  7: Change the case of the URL"
    echo "                                  8: Use Windows directory separator (\\)"
    echo "                                  A: Use a carriage return (0x0d) as a request spacer"
    echo "                                  B: Use binary value 0x0b as a request spacer"
    echo "  -m, --mutate <types>         Comma-separated list of mutate types (e.g., 1,2,6)."
    echo "                                  1: Test all files with all root directories"
    echo "                                  2: Guess for password file names"
    echo "                                  3: Enumerate user names via Apache (/~user type requests)"
    echo "                                  4: Enumerate user names via cgiwrap (/cgi-bin/cgiwrap/~user type requests)"
    echo "                                  5: Attempt to brute force sub-domain names"
    echo "                                  6: Attempt to guess directory names from dictionary"
    echo "  -t, --tuning <types>         Comma-separated list of scan tuning types (e.g., 1,3,8)."
    echo "                                  See Nikto --help for full list (1-9,0,a,b,c,x)."
    echo "  --ssl                        Force SSL mode."
    echo "  --timeout <seconds>          Set timeout for requests (default: 10)."
    echo "  --pause <seconds>            Pause between tests (integer or float)."
    echo "  --nointeractive              Disable interactive features."
    echo "  --nolookup                   Disable DNS lookups."
    echo "  --no404                      Disable 404 page guessing."
    echo "  --dbcheck                    Check database for syntax errors."
    echo "  --list-plugins               List all available plugins and exit."
    echo "  --update                     Update databases and plugins."
    echo "  --help                       Display this help message."
    echo ""
    echo "Examples:"
    echo "  $0 -h localhost -p 8080 -v -o webgoat_scan.html -e 1,2 -m 1,6"
    echo "  $0 --host 192.168.1.1 --ssl --tuning 3,8"
    exit 0
}

# Parse command line arguments
TARGET_HOST=""
TARGET_PORT=""
DISPLAY_OPTIONS=""
OUTPUT_FILE=""
OUTPUT_FORMAT=""
EVASION_TECHNIQUES=""
MUTATE_TYPES=""
TUNING_TYPES=""
FORCE_SSL=""
TIMEOUT=""
PAUSE=""
NO_INTERACTIVE=""
NO_LOOKUP=""
NO_404=""
DB_CHECK=""
LIST_PLUGINS=""
UPDATE_DB=""

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -h|--host)
            TARGET_HOST="$2"
            shift
            ;;
        -p|--port)
            TARGET_PORT="$2"
            shift
            ;;
        -v|--verbose)
            DISPLAY_OPTIONS="${DISPLAY_OPTIONS}V"
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift
            ;;
        -f|--format)
            OUTPUT_FORMAT="$2"
            shift
            ;;
        -e|--evasion)
            EVASION_TECHNIQUES="$2"
            shift
            ;;
        -m|--mutate)
            MUTATE_TYPES="$2"
            shift
            ;;
        -t|--tuning)
            TUNING_TYPES="$2"
            shift
            ;;
        --ssl)
            FORCE_SSL="--ssl"
            ;;
        --timeout)
            TIMEOUT="-timeout $2"
            shift
            ;;
        --pause)
            PAUSE="-Pause $2"
            shift
            ;;
        --nointeractive)
            NO_INTERACTIVE="--nointeractive"
            ;;
        --nolookup)
            NO_LOOKUP="--nolookup"
            ;;
        --no404)
            NO_404="--no404"
            ;;
        --dbcheck)
            DB_CHECK="--dbcheck"
            ;;
        --list-plugins)
            LIST_PLUGINS="--list-plugins"
            ;;
        --update)
            UPDATE_DB="--update"
            ;;
        --help)
            display_help
            ;;
        *)
            echo "Unknown option: $1"
            display_help
            ;;
    esac
    shift
done

# Validate essential arguments
if [[ -z "$TARGET_HOST" && -z "$LIST_PLUGINS" && -z "$UPDATE_DB" && -z "$DB_CHECK" ]]; then
    echo "Error: Target host (-h or --host) is required for a scan."
    display_help
fi

# Build the Nikto command
NIKTO_COMMAND="${PERL_COMMAND} ${NIKTO_PATH}/nikto.pl"

if [[ -n "$TARGET_HOST" ]]; then
    NIKTO_COMMAND="${NIKTO_COMMAND} -h ${TARGET_HOST}"
fi

if [[ -n "$TARGET_PORT" ]]; then
    NIKTO_COMMAND="${NIKTO_COMMAND} -p ${TARGET_PORT}"
fi

if [[ -n "$DISPLAY_OPTIONS" ]]; then
    NIKTO_COMMAND="${NIKTO_COMMAND} -Display ${DISPLAY_OPTIONS}"
fi

if [[ -n "$OUTPUT_FILE" ]]; then
    NIKTO_COMMAND="${NIKTO_COMMAND} -o ${OUTPUT_FILE}"
fi

if [[ -n "$OUTPUT_FORMAT" ]]; then
    NIKTO_COMMAND="${NIKTO_COMMAND} -Format ${OUTPUT_FORMAT}"
fi

# Handle evasion techniques
if [[ -n "$EVASION_TECHNIQUES" ]]; then
    IFS=',' read -ra EVASION_ARRAY <<< "$EVASION_TECHNIQUES"
    for tech in "${EVASION_ARRAY[@]}"; do
        NIKTO_COMMAND="${NIKTO_COMMAND} -evasion ${tech}"
    done
fi

# Handle mutate types
if [[ -n "$MUTATE_TYPES" ]]; then
    IFS=',' read -ra MUTATE_ARRAY <<< "$MUTATE_TYPES"
    for type in "${MUTATE_ARRAY[@]}"; do
        NIKTO_COMMAND="${NIKTO_COMMAND} -mutate ${type}"
    done
fi

# Handle tuning types
if [[ -n "$TUNING_TYPES" ]]; then
    IFS=',' read -ra TUNING_ARRAY <<< "$TUNING_TYPES"
    for type in "${TUNING_ARRAY[@]}"; do
        NIKTO_COMMAND="${NIKTO_COMMAND} -Tuning ${type}"
    done
fi

if [[ -n "$FORCE_SSL" ]]; then
    NIKTO_COMMAND="${NIKTO_COMMAND} ${FORCE_SSL}"
fi

if [[ -n "$TIMEOUT" ]]; then
    NIKTO_COMMAND="${NIKTO_COMMAND} ${TIMEOUT}"
fi

if [[ -n "$PAUSE" ]]; then
    NIKTO_COMMAND="${NIKTO_COMMAND} ${PAUSE}"
fi

if [[ -n "$NO_INTERACTIVE" ]]; then
    NIKTO_COMMAND="${NIKTO_COMMAND} ${NO_INTERACTIVE}"
fi

if [[ -n "$NO_LOOKUP" ]]; then
    NIKTO_COMMAND="${NIKTO_COMMAND} ${NO_LOOKUP}"
fi

if [[ -n "$NO_404" ]]; then
    NIKTO_COMMAND="${NIKTO_COMMAND} ${NO_404}"
fi

if [[ -n "$DB_CHECK" ]]; then
    NIKTO_COMMAND="${NIKTO_COMMAND} ${DB_CHECK}"
fi

if [[ -n "$LIST_PLUGINS" ]]; then
    NIKTO_COMMAND="${NIKTO_COMMAND} ${LIST_PLUGINS}"
fi

if [[ -n "$UPDATE_DB" ]]; then
    NIKTO_COMMAND="${NIKTO_COMMAND} ${UPDATE_DB}"
fi

echo ""
echo "Executing Nikto command:"
echo "$NIKTO_COMMAND"
echo ""

# Execute the Nikto command
eval "$NIKTO_COMMAND"

echo ""
echo "--- Nikto scan complete ---"