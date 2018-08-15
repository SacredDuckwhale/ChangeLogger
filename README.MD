# ChangeLogger

## Description
**ChangeLogger** is a (very basic) changelog creation tool written in **Lua**


## Usage

    lua ChangeLogger.lua "input.lua" --outputFile="test\changes.md" --mode="markdown" --numReleases=3

This runs the script and tells it to parse the file *input.lua*, saving to *output\changes.md* a changelog written in *markdown* format, which includes changes from the last *three* releases CL could find.

*Note: CL tries to determine which these are, but if your naming isn't somewhat similar to mine it might not work :(
Please open an issue and I will add support for it!*

Shortcuts: -o -m -n (for the three optional parameters, respectively)

## Required Libraries (externals)
* argparse: 	https://github.com/mpeterv/argparse
