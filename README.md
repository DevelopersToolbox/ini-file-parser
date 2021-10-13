<p align="center">
    <a href="https://github.com/DevelopersToolbox/">
        <img src="https://cdn.wolfsoftware.com/assets/images/github/organisations/developerstoolbox/black-and-white-circle-256.png" alt="DevelopersToolbox logo" />
    </a>
    <br />
    <a href="https://github.com/DevelopersToolbox/ini-file-parser/actions/workflows/pipeline.yml">
        <img src="https://img.shields.io/github/workflow/status/DevelopersToolbox/ini-file-parser/pipeline/master?style=for-the-badge" alt="Github Build Status">
    </a>
    <a href="https://github.com/DevelopersToolbox/ini-file-parser/releases/latest">
        <img src="https://img.shields.io/github/v/release/DevelopersToolbox/ini-file-parser?color=blue&label=Latest%20Release&style=for-the-badge" alt="Release">
    </a>
    <a href="https://github.com/DevelopersToolbox/ini-file-parser/releases/latest">
        <img src="https://img.shields.io/github/commits-since/DevelopersToolbox/ini-file-parser/latest.svg?color=blue&style=for-the-badge" alt="Commits since release">
    </a>
    <br />
    <a href=".github/CODE_OF_CONDUCT.md">
        <img src="https://img.shields.io/badge/Code%20of%20Conduct-blue?style=for-the-badge" />
    </a>
    <a href=".github/CONTRIBUTING.md">
        <img src="https://img.shields.io/badge/Contributing-blue?style=for-the-badge" />
    </a>
    <a href=".github/SECURITY.md">
        <img src="https://img.shields.io/badge/Report%20Security%20Concern-blue?style=for-the-badge" />
    </a>
    <a href="https://github.com/DevelopersToolbox/ini-file-parser/issues">
        <img src="https://img.shields.io/badge/Get%20Support-blue?style=for-the-badge" />
    </a>
    <br />
    <a href="https://wolfsoftware.com/">
        <img src="https://img.shields.io/badge/Created%20by%20Wolf%20Software-blue?style=for-the-badge" />
    </a>
</p>

## Overview

Bash does not come with a way to process ini/config files, this script is an attempt at creating a generic easy to use solution to this problem and for no other reason than because I could.

## How it works

The script works by reading in a normal ini file and creates 2 arrays per section. One for the keys and one for the values. The reason of this is that you cannot declare an associative array globally from within a loop which is within a function  (in bash 4.3 at least) so this was the best work around that was available. 

## Example ini file

There are 2 config files provided as examples.

| Name | Description |
| --- | --- |
| [simple example](tests/simple-example.conf) | Simple config file, demonstrating sections and key=value key pairs. |
| [complete example](tests/complete-example.conf) | Complex config file, demonstrating all of the processing rules, warnings and error conditions.|

### Simple config file
```
[section1]
value1=abcd
value2=1234

[section2]
value1=1234
value2=5678

[section3]
value1=abcd
value2=1234
value3=a1b2
value_4=c3d4
```

## Example usage

There is a complete working example available, [parse-example.sh](tests/parse-example.sh), but a 'snippet' example is given below, to show a simple single value extraction.

```shell
#!/usr/bin/env bash

# Load in the ini file parser
source ini-file-parser.sh

# Load and process the ini/config file
process_ini_file 'example.conf'

# Display a specific value from a specific section
echo $(get_value 'section1' 'value1')

# Display the same value as above but using the global variables created as part of the processing.
echo $section1_value1
```

## Processing rules

There are a number of rules / assumptions that have been coded in that might give you a result different to the one you might expect:

1. Empty lines are ignored.
2. Lines starting with comments (# or ;) are ignored.
3. The 'default' section is called 'default' - This is for any name=value pair defined before the first section.
4. Section names will only contains alpha-numberic characters and underscores - everything else is removed.
5. Section names are case sensitive (by default).
6. Key names have leading and trailing spaces removed.
7. Key names replace all punctuation and blank characters (space, tab etc)  with underscore and squish (remove multiple underscores).
8. Value fields have in-line comments removed.
9. Value fields have leading and trailing spaces removed.
10. Value fields have leading and trailing quotes removed.

In attition to the data arrays that are created a set of variables are also creted to allow for simple direction access to values, these are in the format: section_key=value.

It is worth noting that the global variables are created AFTER the processing rules have been applied, so the section name and the key name might differ from what you expect.

## Subroutines

There are currently 4 subroutines that are exposed.

1. process\_ini\_file - Load a names ini/config file and create the required arrays.
2. get\_value - Request a specific value (by key name) from a specific section.
3. disply\_config - Display the processed (clean) ini/config in ini/config file format.
4. display\_config\_by\_section - As above but for a specific named section.

## Global overrides

These variables allow us to override the parse script defaults, they can be used by the calling script, but they must be set **BEFORE** the ini/config file is processed.

| Name | Description | Default | Accepted Values |
| --- | --- | --- | --- |
| case\_sensitive\_sections | Should section names be case sensitive? | true | true / false |
| case\_sensitive\_keys | Should key names be case sensitive? | true | true / false |
| show\_config\_warnings | Should we show config warnings? | true | true / false |
| show\_config\_errors | Should we show config errors? | true | true / false |

### Example override usage

```shell
#!/usr/bin/env bash

# Turn off config warnings
show_config_warnings=false

# Make Section names case-insensitive
case_sensitive_sections=false

# Load in the ini file parser
source ini-file-parser.sh

# Load and process the ini/config file
process_ini_file 'example.conf'

# Display a specific value from a specific section
echo $(get_value 'section1' 'value1')

# Display a value using the global variable created as part of the processing.
echo $section1_value1
```
