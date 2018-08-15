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
local changes = {} -- Will contain the changelog entries, referenced by their tag (used as key)
local tags = {} -- Will contain the ordered list of tags (so the newest ones can be found with ease)


-- Writes the outputFile according to the script's settings
-- Note: Will only function if tags have been added (and sorted) first
local function WriteOutputFile()
	
	print("\nWriting " .. settings.outputFile .. " in mode = " .. settings.mode .. "...\n")
	
	-- Initialize by opening a stream to the outputFile
	
	
	-- Write individual tags
	local numWritten = 0
	for index, tag in ipairs(tags) do -- Write as many notes as the settings dictate

		if numWritten == tonumber(settings.numReleases) then -- Wrote the required number of changes already
			print("\nStopping after " .. numWritten .. " tags have been written. Finalizing...")
			break
		end

		numWritten = numWritten + 1
		
	end
	
	-- Finalize by closing the open file connection
	
	
	
end

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
	
	changes = ParseInputFile()
	
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
	
	WriteOutputFile()

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
