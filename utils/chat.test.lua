local addon = {}
local output = {}
local original_print = print

_G.print = function(message)
    table.insert(output, message)
end

assert(loadfile("utils/chat.lua"))("chat", addon)

assert(addon.colors ~= nil, "colors table should be defined")
assert(addon.colors.YELLOW == "FFFF00", "expected yellow color code")
assert(addon.colors.RED == "FF0000", "expected red color code")

local colored = addon.colorText("Hello", addon.colors.GREEN)
assert(colored == "\124cff00FF00Hello\124r", "colorText should wrap the text with WoW color tags")

addon:PrintMessage("hello world")
assert(#output >= 1, "PrintMessage should write output")
assert(output[#output]:find("hello world") ~= nil, "PrintMessage should include the message")
assert(output[#output]:find("NextTalent") ~= nil, "PrintMessage should include the addon prefix")

output = {}
addon:PrintError("boom")
assert(#output >= 1, "PrintError should write output")
assert(output[#output]:find("boom") ~= nil, "PrintError should include the message")
assert(output[#output]:find("NextTalent") ~= nil, "PrintError should include the addon prefix")

original_print("Chat module tests passed")
