#!/usr/bin/env sh

BLUE='\033[0;34m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BOLD='\033[1m'
NOCOLOR='\033[0m'

CC=gcc
COVERAGE=""

EXAMPLE_NAME=""
EXAMPLE_ERROR_HINT=""
EXAMPLE_SUCCESS_RUN=""

echoAndRun() {
    printf "%bBuilding %b$EXAMPLE_NAME...%b" "$BLUE" "$BOLD" "$NOCOLOR"

    if ! "$@" > /dev/null; then
        printf "\n%bFAIL. POTENTIAL FIX: %b$EXAMPLE_ERROR_HINT\n"  "$RED" "$BOLD"
    else
        printf "%b\n" "$BLUE"
        for i in "$@"
        do
            printf "%s " "$i"
        done
        printf "\n%bRUN WITH %b$EXAMPLE_SUCCESS_RUN\n" "$GREEN" "$BOLD"
    fi
    printf "%b\n" "$NOCOLOR"
}

if [ "$#" -ge "1" ]; then CC=$1; fi
if [ "$2" = "--coverage" ]; then COVERAGE=$2; fi



EXAMPLE_NAME="example"
EXAMPLE_ERROR_HINT="Install $CC compiler? See http://www.amigaos.net/content/81/sdk"
EXAMPLE_SUCCESS_RUN="example"
echoAndRun "$CC" -O2 -std=c99 -Wall -Wextra -I . examples/example.c -lm -o example

EXAMPLE_NAME="stand alone unit test runner"
EXAMPLE_ERROR_HINT="$CC compiler might be missing, or there might be too little memory."
EXAMPLE_SUCCESS_RUN="octaspire-core-unit-test-runner"
echoAndRun "$CC" -O0 -std=c99 -Wall -Wextra -DOCTASPIRE_CORE_AMALGAMATED_UNIT_TEST_IMPLEMENTATION -DGREATEST_ENABLE_ANSI_COLORS $COVERAGE -I . octaspire-core-amalgamated.c -lm -o octaspire-core-unit-test-runner

