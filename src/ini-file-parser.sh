#!/usr/bin/env bash

# -------------------------------------------------------------------------------- #
# Description                                                                      #
# -------------------------------------------------------------------------------- #
# A 'complete' ini file parsers written in pure bash (4), it was written for no    #
# other reason that one did not exist. It is completely pointless apart from some  #
# clever tricks.                                                                   #
# -------------------------------------------------------------------------------- #

# -------------------------------------------------------------------------------- #
# Global Variables                                                                 #
# -------------------------------------------------------------------------------- #
# Global variables which can be set by the calling script, but need to be declared #
# here also to ensure the script is clean and error free.                          #
#                                                                                  #
# case_sensitive_sections - should section names be case sensitive                 #
# case_sensitive_keys     - should key names be case sensitive                     #
# default_to_uppercase    - If we are using case insensitive, default to uppercase #
# show_config_warnings    - should we show config warnings                         #
# show_config_errors      - should we show config errors                           #
# -------------------------------------------------------------------------------- #

declare case_sensitive_sections
declare case_sensitive_keys
declare default_to_uppercase
declare show_config_warnings
declare show_config_errors

# -------------------------------------------------------------------------------- #
# Default Section                                                                  #
# -------------------------------------------------------------------------------- #
# Any values that are found outside of a defined section need to be put somewhere  #
# so they can be recalled as needed. Sections is set up with a 'default' for this  #
# purpose.                                                                         #
# -------------------------------------------------------------------------------- #

DEFAULT_SECTION='default'

sections=()

# -------------------------------------------------------------------------------- #
# Local Variables                                                                  #
# -------------------------------------------------------------------------------- #
# The local variables which can be overridden by the global variables above.       #
#                                                                                  #
# local_case_sensitive_sections - should section names be case sensitive           #
# local_case_sensitive_keys     - should key names be case sensitive               #
# default_to_uppercase          - should we default to uppercase                   #
# local_show_config_warnings    - should we show config warnings                   #
# local_show_config_errors      - should we show config errors                     #
# -------------------------------------------------------------------------------- #

local_case_sensitive_sections=true
local_case_sensitive_keys=true
local_default_to_uppercase=false
local_show_config_warnings=true
local_show_config_errors=true

# -------------------------------------------------------------------------------- #
# Set Global Variables                                                             #
# -------------------------------------------------------------------------------- #
# Check to see if the global overrides are set and if so, override the defaults.   #
#                                                                                  #
# Error checking is in place to ensure that the override contains a valid value of #
# true or false, anything else is ignored.
# -------------------------------------------------------------------------------- #

function setup_global_variables
{
    if [[ -n "${case_sensitive_sections}" ]] && [[ "${case_sensitive_sections}" = false || "${case_sensitive_sections}" = true ]]; then
         local_case_sensitive_sections=${case_sensitive_sections}
    fi

    if [[ -n "${case_sensitive_keys}" ]] && [[ "${case_sensitive_keys}" = false || "${case_sensitive_keys}" = true ]]; then
         local_case_sensitive_keys=${case_sensitive_keys}
    fi

    if [[ -n "${default_to_uppercase}" ]] && [[ "${default_to_uppercase}" = false || "${default_to_uppercase}" = true ]]; then
         local_default_to_uppercase=${default_to_uppercase}
    fi

    if [[ -n "${show_config_warnings}" ]] && [[ "${show_config_warnings}" = false || "${show_config_warnings}" = true ]]; then
         local_show_config_warnings=${show_config_warnings}
    fi

    if [[ -n "${show_config_errors}" ]] && [[ "${show_config_errors}" = false || "${show_config_errors}" = true ]]; then
         local_show_config_errors=${show_config_errors}
    fi

    DEFAULT_SECTION=$(handle_default_case "${DEFAULT_SECTION}")

    # Move to from global settting to handle default uppercase option
    sections+=("${DEFAULT_SECTION}")
}

# -------------------------------------------------------------------------------- #
# in Array                                                                         #
# -------------------------------------------------------------------------------- #
# A function to check to see if a given value exists in a given array.             #
# -------------------------------------------------------------------------------- #

function in_array()
{
    local haystack="${1}[@]"
    local needle=${2}

    for i in ${!haystack}; do
        if [[ ${i} == "${needle}" ]]; then
            return 0
        fi
    done
    return 1
}

# -------------------------------------------------------------------------------- #
# Show Warning                                                                     #
# -------------------------------------------------------------------------------- #
# A wrapper to display any configuration warnings, taking into account if the      #
# local_show_config_warnings flag is set to true.                                  #
# -------------------------------------------------------------------------------- #

function show_warning()
{
    if [[ "${local_show_config_warnings}" = true ]]; then
        format=$1
        shift;

        # shellcheck disable=SC2059
        printf "[ WARNING ] ${format}" "$@";
    fi
}

# -------------------------------------------------------------------------------- #
# Show Error                                                                       #
# -------------------------------------------------------------------------------- #
# A wrapper to display any configuration errors, taking into account if the        #
# local_show_config_errorss flag is set to true.                                   #
# -------------------------------------------------------------------------------- #

function show_error()
{
    if [[ "${local_show_config_errors}" = true ]]; then
        format=$1
        shift;

        # shellcheck disable=SC2059
        printf "[ ERROR ] ${format}" "$@" >&2;
    fi
}

# -------------------------------------------------------------------------------- #
# Handle Default Case                                                              #
# -------------------------------------------------------------------------------- #
# Handle the default case of a section or key.                                     #
# -------------------------------------------------------------------------------- #

function handle_default_case()
{
    local str=$1

    if [[ "${local_default_to_uppercase}" = false ]]; then
        str=$(echo -e "${str}" | tr '[:upper:]' '[:lower:]')               # Lowercase the string
    else
        str=$(echo -e "${str}" | tr '[:lower:]' '[:upper:]')               # Uppercase the str
    fi
    echo "${str}"
}


# -------------------------------------------------------------------------------- #
# Process Section Name                                                             #
# -------------------------------------------------------------------------------- #
# Once we have located a section name within the given config file, we need to     #
# 'cleanse' the value.                                                             #
# -------------------------------------------------------------------------------- #

function process_section_name()
{
    local section=$1

    section="${section##*( )}"                                                     # Remove leading spaces
    section="${section%%*( )}"                                                     # Remove trailing spaces
    section=$(echo -e "${section}" | tr -s '[:punct:] [:blank:]' '_')              # Replace all :punct: and :blank: with underscore and squish
    section=$(echo -e "${section}" | sed 's/[^a-zA-Z0-9_]//g')                     # Remove non-alphanumberics (except underscore)

    if [[ "${local_case_sensitive_sections}" = false ]]; then
        section=$(handle_default_case "${section}")
    fi
    echo "${section}"
}

# -------------------------------------------------------------------------------- #
# Process Key Name                                                                 #
# -------------------------------------------------------------------------------- #
# Once we have located a key name on a given line, we need to 'cleanse' the value. #
# -------------------------------------------------------------------------------- #

function process_key_name()
{
    local key=$1

    key="${key##*( )}"                                                             # Remove leading spaces
    key="${key%%*( )}"                                                             # Remove trailing spaces
    key=$(echo -e "${key}" | tr -s '[:punct:] [:blank:]' '_')                      # Replace all :punct: and :blank: with underscore and squish
    key=$(echo -e "${key}" | sed 's/[^a-zA-Z0-9_]//g')                             # Remove non-alphanumberics (except underscore)

    if [[ "${local_case_sensitive_keys}" = false ]]; then
        key=$(handle_default_case "${key}")
    fi
    echo "${key}"
}

# -------------------------------------------------------------------------------- #
# Process Value                                                                    #
# -------------------------------------------------------------------------------- #
# Once we have located a value attached to a key, we need to 'cleanse' the value.  #
# -------------------------------------------------------------------------------- #

function process_value()
{
    local value=$1

    value="${value%%\;*}"                                                          # Remove in line right comments
    value="${value%%\#*}"                                                          # Remove in line right comments
    value="${value##*( )}"                                                         # Remove leading spaces
    value="${value%%*( )}"                                                         # Remove trailing spaces

    value=$(escape_string "${value}")

    echo "${value}"
}

# -------------------------------------------------------------------------------- #
# Escape string                                                                    #
# -------------------------------------------------------------------------------- #
# Replace ' with SINGLE_QUOTE to avoid issues with eval.                           #
# -------------------------------------------------------------------------------- #

function escape_string()
{
    local clean

    clean=${1//\'/SINGLE_QUOTE}
    echo "${clean}"
}

# -------------------------------------------------------------------------------- #
# Un-Escape string                                                                 #
# -------------------------------------------------------------------------------- #
# Convert SINGLE_QUOTE back to ' when returning the value to the caller.           #
# -------------------------------------------------------------------------------- #

function unescape_string()
{
    local orig

    orig=${1//SINGLE_QUOTE/\'}
    echo "${orig}"
}

# -------------------------------------------------------------------------------- #
# Parse ini file                                                                   #
# -------------------------------------------------------------------------------- #
# Read a named file line by line and process as required.                          #
# -------------------------------------------------------------------------------- #

function process_ini_file()
{
    local line_number=0
    local section="${DEFAULT_SECTION}"
    local key_array_name=''

    setup_global_variables

    shopt -s extglob

    while IFS= read -r line || [ -n "$line" ]; do
        line=$(echo "$line" | tr -d '\r')  # Remove carriage return if present
        line_number=$((line_number+1))

        if [[ ${line} =~ ^# || ${line} =~ ^\; || -z ${line} ]]; then  # Ignore comments / empty lines
            continue;
        fi

        if [[ ${line} =~ ^"["(.+)"]"$ ]]; then  # Match pattern for a 'section'
            section=$(process_section_name "${BASH_REMATCH[1]}")

            if ! in_array sections "${section}"; then
                eval "${section}_keys=()"  # Use eval to declare the keys array
                eval "${section}_values=()"  # Use eval to declare the values array
                sections+=("${section}")  # Add the section name to the list
            fi
        elif [[ ${line} =~ ^(.*)"="(.*) ]]; then  # Match pattern for a key=value pair
            key=$(process_key_name "${BASH_REMATCH[1]}")
            value=$(process_value "${BASH_REMATCH[2]}")

            if [[ -z ${key} ]]; then
                show_error 'line %d: No key name\n' "${line_number}"
            else
                if [[ "${section}" == "${DEFAULT_SECTION}" ]]; then
                    show_warning '%s=%s - Defined on line %s before first section - added to "%s" group\n' "${key}" "${value}" "${line_number}" "${DEFAULT_SECTION}"
                fi

                eval key_array_name="${section}_keys"

                if in_array "${key_array_name}" "${key}"; then
                    show_warning 'key %s - Defined multiple times within section %s\n' "${key}" "${section}"
                fi
                eval "${section}_keys+=(${key})"  # Use eval to add to the keys array
                eval "${section}_values+=('${value}')"  # Use eval to add to the values array
                eval "${section}_${key}='${value}'"  # Use eval to declare a variable
            fi
        fi
    done < "$1"
}

# -------------------------------------------------------------------------------- #
# Get Value                                                                        #
# -------------------------------------------------------------------------------- #
# Retrieve a value for a specific key from a named section.                        #
# -------------------------------------------------------------------------------- #

function get_value()
{
    local section=''
    local key=''
    local value=''
    local keys=''
    local values=''

    section=$(process_section_name "${1}")
    key=$(process_key_name "${2}")

    section=$(handle_default_case "${section}")
    key=$(handle_default_case "${key}")

    eval "keys=( \"\${${section}_keys[@]}\" )"
    eval "values=( \"\${${section}_values[@]}\" )"

    for i in "${!keys[@]}"; do
        if [[ "${keys[${i}]}" = "${key}" ]]; then
            orig=$(unescape_string "${values[${i}]}")
            printf '%s' "${orig}"
        fi
    done
}

# -------------------------------------------------------------------------------- #
# Display Config                                                                   #
# -------------------------------------------------------------------------------- #
# Display all of the post processed configuration.                                 #
#                                                                                  #
# NOTE: This is without comments etec.                                             #
# -------------------------------------------------------------------------------- #

function display_config()
{
    local section=''
    local key=''
    local value=''

    for s in "${!sections[@]}"; do
        section=${sections[${s}]}

        printf '[%s]\n' "${section}"

        eval "keys=( \"\${${section}_keys[@]}\" )"
        eval "values=( \"\${${section}_values[@]}\" )"

        for i in "${!keys[@]}"; do
            orig=$(unescape_string "${values[${i}]}")
            printf '%s=%s\n' "${keys[${i}]}" "${orig}"
        done
    printf '\n'
    done
}

# -------------------------------------------------------------------------------- #
# Display Config by Section                                                        #
# -------------------------------------------------------------------------------- #
# Display all of the post processed configuration for a given section.             #
#                                                                                  #
# NOTE: This is without comments etec.                                             #
# -------------------------------------------------------------------------------- #

function display_config_by_section()
{
    local section=$1
    local key=''
    local value=''
    local keys=''
    local values=''

    section=$(handle_default_case "${section}")
    printf '[%s]\n' "${section}"

    eval "keys=( \"\${${section}_keys[@]}\" )"
    eval "values=( \"\${${section}_values[@]}\" )"

    for i in "${!keys[@]}"; do
        orig=$(unescape_string "${values[${i}]}")
        printf '%s=%s\n' "${keys[${i}]}" "${orig}"
    done
    printf '\n'
}

# -------------------------------------------------------------------------------- #
# End of Script                                                                    #
# -------------------------------------------------------------------------------- #
# This is the end - nothing more to see here.                                      #
# -------------------------------------------------------------------------------- #
