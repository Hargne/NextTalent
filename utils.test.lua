local addon = {}
_G.addon = addon

assert(loadfile("utils.lua"))("utils", addon)

print("Testing Utils Module")

print("| PrintMessage |")
print("--------------------")
addon:PrintMessage("This is a test message.")

print(" ")