#!/bin/bash

VERBOSE_MODE=0 # When enabled, all commands that are being executed are echoed to stdout
DEBUG_MODE=0   # When enabled, commands are only echoed to stdout and not actually run
TRACE_MODE=1   # When enabled, trace information is echoed to stdout
DIR_PREFIX=""  # Used when testing on local machine - empty on check-in

#
# check number of Arguments, Exit it not desired number
#
# Input:
#   numberOfArguments         - Number of arguments in argument list
#   expectedNumberOfArguments - Number of arguments expected to be on the list
#   errorMessage              - Error message to display if argument list is not the right size
#
# Output:
#   Error message if Arguments mismatch and exit
#
function exitOnBadArgs()
{
    # Precondtion check for parameter
    if [ $# != 3 ]; then
        printf "exitOnBadArgs: Number of Arguments must be 3. Recieved only $ args received: $*\n"
        exit 1
    fi

    # Initialize Arguments
    local numberOfArguments=$1
    local expectedNumberOfArguments=$2
    local errorMessage=$3

    # Check if the Arguments Matches
    if [ "$numberOfArguments" -ne "$expectedNumberOfArguments" ]; then
        echo $errorMessage
        exit 1
    fi
}

#
# Exit if the result is non zero
#
# Input:
#   result  - Result status being checked
#   message - Message to be displayed
#
# Output:
#   Error message displayed and exits if reslt is not 0
#
function exitOnError()
{
    # Precondition check - exit on error
    exitOnBadArgs $# 2 "exitOnError: expecte 2 args, got $#.  Args: $*"


    # Accept the arguments and check if the last command was executed 
    result=$1
    message=$2

    if [ "$result" != 0 ];then
        echo "ERROR: $message"
        exit 1
    fi
}

#
# Print a trace statement to the log file and to standard out if
# verbose is enabled.
#
# Input:
#   message - Message to display if trace is enabled
#
function trace()
{
    # Precondition check - exit on error
    exitOnBadArgs $# 1 "exitOnError: expecte 1 args, got $#.  Args: $*"
    
    # Get Args
    message=$1

    # Display message
    if [ $TRACE_MODE -eq 1 ]; then
        # local dateTime=`date "+%Y-%m-%d %H:%M:%S"`
        echo "==== $message" >> $LOG_FILE 2>&1
        echo "==== $message"
    fi
}


#
# Runs the passed in command
#
# Input:
#   callingFunction - Function that requests the command for error reporting
#   command         - Command being run
#
function runCommand()
{
    # precondition check - exit on error
    exitOnBadArgs $# 2 "$FUNCNAME: expected 2 args, got $#.  Args: $*"

    callingFunction=$1
    command=$2

    # Display the command if verbose mode enabled
    if [ $VERBOSE_MODE -eq 1 ]; then
        echo "$command"
    fi

    # Run the command and exit on error
    # Skip running the command if we are in debug mode
    if [ $DEBUG_MODE -eq 0 ]; then
        echo "$command" >> $LOG_FILE 2>&1
        $command >> $LOG_FILE 2>&1
        exitOnError $? "$callingFunction: $command"
    fi
}


#
# Runs the passed in command with output going to the specified file
#
# Input:
#   callingFunction - Function that requests the command for error reporting
#   command         - Command being run
#   outputFile      - File to capture output from command
#   append          - 1 if appending to an existing file; 0 otherwise
#
function runCommandToFile()
{
    # precondition check - exit on error
    exitOnBadArgs $# 4 "$FUNCNAME: expected 4 args, got $#.  Args: $*"

    callingFunction=$1
    command=$2
    outputFile=$3
    append=$4

    # Display the command if verbose mode enabled
    if [ $VERBOSE_MODE -eq 1 ]; then
        echo "$command > $outputFile"
    fi

    # Run the command and exit on error
    # Skip running the command if we are in debug mode
    if [ $DEBUG_MODE -eq 0 ]; then
        if [ $append -eq 1 ]; then
            echo "$command > $outputFile" >> $LOG_FILE 2>&1
            $command >> $outputFile
            exitOnError $? "$callingFunction: $command"
        else
            echo "$command > $outputFile" >> $LOG_FILE 2>&1
            $command > $outputFile
            exitOnError $? "$callingFunction: $command"
        fi
    fi
}

