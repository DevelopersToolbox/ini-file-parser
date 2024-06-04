#!/usr/bin/env bash

# This script receives a JSON string containing job results and checks for any failures.

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "jq could not be found, please install jq to run this script."
    exit 1
fi

# Read the JSON string from the first script argument
job_results_json=$1

# Check if the job results JSON is not empty
if [[ -z "$job_results_json" ]]; then
    echo "No job results JSON provided."
    exit 1
fi

# Set default state
failed_jobs=false

# Use jq to parse the JSON and check each job's result
while IFS= read -r line; do
    job_name=$(echo "$line" | awk '{print $1}')
    result=$(echo "$line" | awk '{print $3}')

    if [ "$result" != "success" ]; then
        echo "$job_name failed."
        failed_jobs=true
    else
        echo "$job_name succeed."
    fi
done <<< "$( echo "$job_results_json" | jq -r 'to_entries[] | "\(.key) result: \(.value.result)"' )"

if [ "$failed_jobs" = true ] ; then
    exit 1
fi
