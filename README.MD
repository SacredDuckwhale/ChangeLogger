# ChangeLogger

## Description
**ChangeLogger** is a (very basic) changelog creation tool written in **Lua**


## Usage

    lua ChangeLogger.lua "input.lua" --outputFile="output\changes.md" --mode="markdown" --numReleases=3

This runs the script and tells it to parse the file *input.lua*, saving to *output\changes.md* a changelog written in *markdown* format, which includes changes from the last *three* releases CL could find.

*Note: CL tries to determine which these are, but if your naming isn't somewhat similar to mine it might not work :(
Please open an issue and I will add support for it!*

Shortcuts: -o -m -n (for the three optional parameters, respectively)

## Input Format

Currently, CL supports only a specific format written in Lua. This allows the changelogs to be used directly in other Lua programs, for example to display them inside the program they are shipped with (for users who haven't bothered with reading the actual changelog file that would usually be included as well).

Details on this format are as follows:
 
* For the time being, the input file must contain a Lua function that returns the changeLogs table (to be used with Lua's [loadfile](https://www.lua.org/pil/8.html) function)
* Valid keys for this table are: additions, fixes, changes, notes, isses
* Either of these can be omitted, as long as there exists at least one entry - surely creating a changelog would be pointless if nothing has changed, after all
* The changeLogs table can be named arbitrarily. It just needs to be valid, and contain entries in the specified format that CL understands

I'm aware these constraints are somewhat inconvenient, so it will likely be improved upon in the future. Like, eventually. Maybe. Possibly. You know how it is with these side projects...

Example:

    changes = { ["r42"] = {
		additions = {
			"Added some cool stuff",
		},
		fixes = {
			"Fixed a horrible bug that would end the world through dividing by zero",
		},
		changes = {
			"Everything was changed. New is ALWAYS better!",
		},
		notes = 
			"This Curse/Twitch \"feature\" caused many bug reports and offers little tangible benefit, as it was often done in error or automatically by the Twitch client; I ultimately chose to disable it in order to reduce the time spent on providing support instead of working on bugfixes or new features"
		},
	}
	
	return changes

Please note the outer structure allowing the file to be executed as a Lua function (which returns the table of changelogs).

## Required Libraries (externals)
* argparse: 	https://github.com/mpeterv/argparse
