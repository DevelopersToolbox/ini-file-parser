#!/usr/bin/env bash

# -------------------------------------------------------------------------------- #
# Description                                                                      #
# -------------------------------------------------------------------------------- #
# This is a very simple (almost trivial) example of how to make use of the         #
# os-detect script and embed os detection into your scripts.                       #
# -------------------------------------------------------------------------------- #

# -------------------------------------------------------------------------------- #
# Declaration                                                                      #
# -------------------------------------------------------------------------------- #
# Declare variables that we are going to use later, these are variables that are   #
# dynamically created by the parsing script. This isn't 100% needed but it is      #
# cleaner to do it this way and also makes sure that shellcheck is 100% clean.     #
# -------------------------------------------------------------------------------- #

declare sections

declare section1_value1
declare section1_keys
declare section1_values

declare SECTION1_VALUE1
declare SECTION1_keys
declare SECTION1_values

# -------------------------------------------------------------------------------- #
# Global Overrides                                                                 #
# -------------------------------------------------------------------------------- #
# These variables allow us to override the parse script defaults.                  #
#                                                                                  #
# case_sensitive_sections - should section names be case sensitive                 #
# case_sensitive_keys     - should key names be case sensitive                     #
# default_to_uppercase    - should we default to uppercase?                        #
# show_config_warnings    - should we show config warnings                         #
# show_config_errors      - should we show config errors                           #
#                                                                                  #
# You can uncomment either (or both) of the values below to override the default   #
# value of true.                                                                   #
# -------------------------------------------------------------------------------- #

export case_sensitive_sections=false
export case_sensitive_keys=false
export default_to_uppercase=true
#export show_config_warnings=false
#export show_config_errors=false

# -------------------------------------------------------------------------------- #
# Use the source                                                                   #
# -------------------------------------------------------------------------------- #
# Source the os-detect script to make the variables available.                     #
# -------------------------------------------------------------------------------- #

SCRIPTPATH="$( dirname "$( cd "$(dirname "$0")" >/dev/null 2>&1 || exit ; pwd -P )" || true)"

# shellcheck disable=SC1090,SC1091
source "${SCRIPTPATH}"/src/ini-file-parser.sh

# -------------------------------------------------------------------------------- #
# Profile ini file                                                                 #
# -------------------------------------------------------------------------------- #
# Tell the parser which ini file to process.                                       #
# -------------------------------------------------------------------------------- #

process_ini_file 'complete-example.conf'
global_reset
process_ini_file 'complete-example.conf'

# -------------------------------------------------------------------------------- #
# Display Config                                                                   #
# -------------------------------------------------------------------------------- #
# Tell the parser to display ALL of the loaded and parsed config.                  #
# -------------------------------------------------------------------------------- #

echo "Display Config"
display_config

# -------------------------------------------------------------------------------- #
# Display Config bu Section                                                        #
# -------------------------------------------------------------------------------- #
# Tell the parser to display ALL of the loaded and parsed config for a specific    #
# named section.                                                                   #
# -------------------------------------------------------------------------------- #

echo "Display Section 2"
display_config_by_section 'section2'

# -------------------------------------------------------------------------------- #
# Get Value                                                                        #
# -------------------------------------------------------------------------------- #
# Retrieve a specific value from a specific section.                               #
# -------------------------------------------------------------------------------- #

echo "Display Section 1 - Value 1 (get_value lookup)"
value=$(get_value 'section1' 'value1')
echo "${value}"

# -------------------------------------------------------------------------------- #
# Dynamic Variables                                                                #
# -------------------------------------------------------------------------------- #
# Use a dynamicalled created variable directly.                                    #
# -------------------------------------------------------------------------------- #

echo "Display Section 1 - Value 1 (Named variable)"
if [[ "${default_to_uppercase}" = false ]]; then
    echo "${section1_value1}"
else
    echo "${SECTION1_VALUE1}"
fi

# -------------------------------------------------------------------------------- #
# Section, Key and Value Traversals                                                #
# -------------------------------------------------------------------------------- #
# Traverse sections, keys and values of the section.                               #
# -------------------------------------------------------------------------------- #

echo
echo "Display Section, Key and Value Traversals"

echo "${sections[@]}"

if [[ "${default_to_uppercase}" = false ]]; then
    echo "${section1_keys[@]}"
    echo "${section1_values[@]}"
else
    echo "${SECTION1_keys[@]}"
    echo "${SECTION1_values[@]}"
fi

# -------------------------------------------------------------------------------- #
# End of Script                                                                    #
# -------------------------------------------------------------------------------- #
# This is the end - nothing more to see here.                                      #
# -------------------------------------------------------------------------------- #


