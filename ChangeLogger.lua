-- Externals
local argparse = require "argparse"


-- Locals
local CL = {}


-- Script execution always starts with this
function CL.Run(args)

	print("\nDetected CLI arguments:\n")
	for k, v in pairs(args) do print(k, v) end

end


-- Set up CLI parsing via argparse library
local parser = argparse("script", "ChangeLogger script")
parser:argument("inputFile", "Input file.")
parser:option("-o --outputFile", "Output file.", "CHANGES.MD")
parser:option("-m --mode", "Output mode")
parser:option("-n --numReleases", "Number of releases that should be included")

-- Get CLI arguments
local args = parser:parse()

-- Run script with the given arguments (no sanity check here)
CL.Run(args)
