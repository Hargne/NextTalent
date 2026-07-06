local addon = {}
_G.addon = addon

assert(loadfile("specs.lua"))("specs", addon)
assert(loadfile("data/hunter.lua"))("hunter", addon)
assert(loadfile("data/warrior.lua"))("warrior", addon)
assert(loadfile("data/priest.lua"))("priest", addon)
assert(loadfile("data/rogue.lua"))("rogue", addon)
assert(loadfile("data/shaman.lua"))("shaman", addon)

print("Testing Specs Module")

local classes = {
  "Hunter",
  "Warrior",
  "Priest",
  "Rogue",
  "Paladin",
  "Druid",
  "Shaman",
  "Mage",
  "Warlock"
}

print("| GetSpecsForClass |")
print("--------------------")
for _, class in ipairs(classes) do
    local specs = addon:GetSpecsForClass(class)
    if specs then
        print(class .. ": " .. table.concat(specs, ", "))
    else
        print("No specs found for class " .. class)
    end
end

print(" ")

print("| GetSpecTalents |")
print("--------------------")
for _, class in ipairs(classes) do
    local specs = addon:GetSpecsForClass(class)
    if specs then
        for _, spec in ipairs(specs) do
            local talents = addon:GetSpecTalents(class, spec)
            if not talents then
                error("No talents found for class " .. class .. " and spec " .. spec)
            end

            if not talents.leveling then
                error("No leveling talents found for class " .. class .. " and spec " .. spec)
            end

            if #talents.leveling < (60 - 10) then
                error("Spec " .. spec .. " for class " .. class .. " has less than 50 leveling talents")
            end

            print("Class: " .. class .. ", Spec: " .. spec .. ", Leveling Talents Count: " .. #talents.leveling)
        end
    end
end