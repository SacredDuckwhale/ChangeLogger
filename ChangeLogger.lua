-- Externals
local argparse = require "argparse"


-- Upvalues
local print = print
local pairs = pairs
local assert = assert
local dofile = dofile


-- Locals
local CL = {}
local settings = { -- These are the default settings. They can be overwritten if CLI arguments were supplied
	mode = "markdown",
	numReleases = 1,
	outputFile = "CHANGES.MD",
}
local tags = {} -- Will contain the ordered list of tags (so the newest ones can be found with ease)

-- Loads the inputFile stored in the script's settings and returns them as a Lua table (I know, technically it isn't really parsing it, but it works out the same way)
local function ParseInputFile()

	local changes = assert(dofile(settings.inputFile), "Failed to load input file!")
	return changes
	
end

-- Script execution always starts with this
function CL.Run(args)

	-- Replace default settings with (valid) CLI arguments
	print("\nDetected CLI arguments:\n")
	for k, v in pairs(args) do
		print(k, v)
		settings[k] = v -- If some settings were invalid, they just won't have any effect. Yes, I AM too lazy right now for sanity checks etc.
	end

	print("\nRunning script with the following parameters...\n")
	print("\Input file: " .. settings["inputFile"])
	print("\Output file: " .. settings["outputFile"])
	print("\Changelog format: " .. settings["mode"])
	
	local changes = ParseInputFile()
	
	-- Discover tags and add them to the ordered changelog list (so the newest ones can be found)
	print("\nFound the following changelogs:\n")
	for tag, changeLog in pairs(changes) do
		
		local numChanges = changeLog.changes and #changeLog.changes or 0
		local numAdditions = changeLog.additions and #changeLog.additions or 0
		local numFixes = changeLog.fixes and #changeLog.fixes or 0
		local hasNotes = changeLog.notes
		
		print("Tag: " .. tag .. " - " .. numChanges .. " Changes, " .. numAdditions .. " Additions, " .. numFixes .. " Fixes - Notes: " .. (hasNotes and "Yes" or "No"))
		
		-- Add tag to list so it can be sorted
		tags[#tags+1] = tag
		
	end
	
	print("\nDiscovered " .. #tags .. " tagged versions. Sorting them now...\n")
	table.sort(tags, function(a, b) return a > b end)
	for index, tag in ipairs(tags) do
		print("(" .. index .. ")", tag)
	end
	
	print("\nFinished sorting tags!")
	
end


-- Set up CLI parsing via argparse library
local parser = argparse("script", "ChangeLogger script")
parser:argument("inputFile", "Input file.")
parser:option("-o --outputFile", "Output file.")
parser:option("-m --mode", "Output mode")
parser:option("-n --numReleases", "Number of releases that should be included")

-- Get CLI arguments
local args = parser:parse()

-- Run script with the given arguments (no sanity check here)
CL.Run(args)
