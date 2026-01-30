#!/bin/bash
# functions.sh

hello_user() {
    echo "Hello, $1! Welcome to Julia-Shell integration."
}

check_space() {
    echo "Checking directory: $1"
    du -sh "$1"
}

# This script is for testing purposes only!