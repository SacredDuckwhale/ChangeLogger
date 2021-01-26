-- Externals
local argparse = require "argparse"


-- Upvalues
local print = print
local pairs = pairs
local assert = assert
local dofile = dofile
local tonumber = tonumber
local format = string.format
local tconcat = table.concat
local tinsert = table.insert
local tremove = table.remove

-- Locals
local CL = {}
local settings = { -- These are the default settings. They can be overwritten if CLI arguments were supplied
	mode = "markdown",
	numReleases = 1,
	outputFile = "CHANGES.MD",
	orderedCategories = { -- Predefined order of the given changelog entry types (TODO: Allow changing this?)
		[1] = "additions",
		[2] = "changes",
		[3] = "fixes",
		[4] = "issues",
		[5] = "notes",
		[6] = "contributors"
	},
}
local changes = {} -- Will contain the changelog entries, referenced by their tag (used as key)
local tags = {} -- Will contain the ordered list of tags (so the newest ones can be found with ease)


-- Writes the outputFile according to the script's settings
-- Note: Will only function if tags have been added (and sorted) first
local function WriteOutputFile()

	print("\nWriting " .. settings.outputFile .. " in mode = " .. settings.mode .. "...\n")

	-- Initialize by opening a stream to the outputFile
	local file = assert(io.open(settings.outputFile, "w"), "Error opening output file!")

	local outputStrings = {} -- Will be concatenated when this is done

	-- Write individual tags
	--	Format: <tag>:\n\n<additions>\n<changes>\n<fixes>\n<notes>\n
	local numTagsWritten = 0
	for index, tag in ipairs(tags) do -- Write as many notes as the settings dictate

		if numTagsWritten == tonumber(settings.numReleases) then -- Wrote the required number of changes already
			print("\nStopping after " .. numTagsWritten .. " tags have been written. Finalizing...")
			break
		end

		print("(" .. index .. ") Adding changes for tag: " .. tag .. "\n")

		local changeLog = changes[tag]

		-- Add tag info
		tinsert(outputStrings, "**" .. tag .. ":**\n")

		-- Add individual entries (in order)
		for order, category in ipairs(settings.orderedCategories) do -- Add entries in the correct order
			--print(order, category)
			local entries = changeLog[category]
			if entries then -- Add this entry
				if category == "notes" then tinsert(outputStrings, "Developer Notes:") end
				if category == "issues" then tinsert(outputStrings, "Known Issues:") end
				if category == "contributors" then tinsert(outputStrings, "Contributors (in alphabetical order):") end
				print("Preparing to write "  .. #entries .. " " .. category .. "...")
				for index, entry in ipairs(entries) do -- Write notes in the original order
					tinsert(outputStrings, ((index > 1) and "<br>" or "> ") .. entry)
				end

				-- Add line break between entries
				tinsert(outputStrings, "") -- separator is set to \n at the end, so this will only add one line break and not two

			end -- Skip types that have no entry for this tag

		end

		-- Add line break between tags
		tinsert(outputStrings, "-----\n") -- Will add two line breaks, since the separator (below) is also a \n symbol

		-- Keep count (used for the numReleases parameter)
		numTagsWritten = numTagsWritten + 1

	end

	-- Remove final separator (as it's not needed at the end of the file)
	tremove(outputStrings)

	-- Concatenate everything
	local outputString = tconcat(outputStrings, "\n")
	print("\nAssembled output string:\n\n" .. outputString)

	-- Write the results to the specified output file
	print("Writing to output file...")
	file:write(outputString)

	-- Finalize by closing the open file connection
	file:close()
	print("Closed output file - all done!")


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
	print("\nInput file: " .. settings["inputFile"])
	print("\nOutput file: " .. settings["outputFile"])
	print("\nChangelog format: " .. settings["mode"])

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
