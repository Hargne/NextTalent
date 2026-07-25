local addon = {}
_G.addon = addon

assert(loadfile("utils/specs.lua"))("specs", addon)
assert(loadfile("data/druid.lua"))("druid", addon)
assert(loadfile("data/hunter.lua"))("hunter", addon)
assert(loadfile("data/warrior.lua"))("warrior", addon)
assert(loadfile("data/mage.lua"))("mage", addon)
assert(loadfile("data/paladin.lua"))("paladin", addon)
assert(loadfile("data/priest.lua"))("priest", addon)
assert(loadfile("data/rogue.lua"))("rogue", addon)
assert(loadfile("data/shaman.lua"))("shaman", addon)
assert(loadfile("data/warlock.lua"))("warlock", addon)

local function assert_equal(actual, expected, message)
    assert(actual == expected, (message or "unexpected value") .. " (expected: " .. tostring(expected) .. ", got: " .. tostring(actual) .. ")")
end

local function assert_truthy(value, message)
    assert(value ~= nil and value ~= false, message or "expected a truthy value")
end

local hunter_specs = addon:GetSpecsForClass("Hunter")
assert_truthy(hunter_specs, "GetSpecsForClass should return specs for a known class")
assert_equal(#hunter_specs, 1, "Hunter should have exactly one registered spec")
assert_equal(hunter_specs[1], "BEAST MASTERY", "GetSpecsForClass should return the registered spec name")

local missing_specs = addon:GetSpecsForClass("UnknownClass")
assert_equal(missing_specs, nil, "GetSpecsForClass should return nil for an unknown class")

local hunter_talents = addon:GetSpecTalents("Hunter", "BEAST MASTERY")
assert_truthy(hunter_talents, "GetSpecTalents should return talents for a known class and spec")
assert_truthy(hunter_talents.leveling, "talent data should include a leveling list")
assert_equal(#hunter_talents.leveling, 51, "Hunter leveling build should contain 51 talents")
assert_equal(hunter_talents.leveling[1], "Impoved Aspect of the Hawk (Rank 1)", "The first leveling talent should match the expected entry")

local missing_talents = addon:GetSpecTalents("Hunter", "UNKNOWN SPEC")
assert_equal(missing_talents, nil, "GetSpecTalents should return nil for an unknown spec")

print("Specs module tests passed")