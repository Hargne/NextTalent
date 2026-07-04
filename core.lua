local name, addon = ...;

local frame = CreateFrame("FRAME", "NextTalentAddonFrame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LEVEL_CHANGED")

local function getPlayerClass()
    guid = UnitGUID("player")
    if guid == nil then
        print("Player not found")
    end
    return GetPlayerInfoByGUID(guid)
end

local function printPlayerClass()
    local class, englishClass = getPlayerClass()
    if englishClass == nil then
        return "FFFFFF"
    end
    local rPerc, gPerc, bPerc, argbHex = GetClassColor(englishClass)
    return addon.colorText(class, string.format("%02x%02x%02x", rPerc * 255, gPerc * 255, bPerc * 255))
end

local function printAvailableSpecs()
    local availableSpecs = getAvailableSpecs()
    print("Available specs for " .. printPlayerClass() .. ": " .. table.concat(availableSpecs, ", "))
end

local function addonMessage(message)
    print(addon.colorText("[NextTalent]: ", addon.colors.YELLOW) .. message)
end

local function printNoSpecSelected()
    addonMessage("No spec selected. Type /nexttalent spec <spec> to select a spec.")
end

local function getAvailableSpecs()
    local class = getPlayerClass()
    if class == nil then
        return
    end

    if addon.talents == nil then
        return
    end

    local classTalents = addon.talents[class]
    if classTalents == nil then
        return
    end

    local specs = {}
    for specName in pairs(classTalents) do
        table.insert(specs, specName)
    end

    table.sort(specs, function(a, b)
        return string.lower(a) < string.lower(b)
    end)

    return specs
end

local function getNextTalent()
    local class = getPlayerClass()
    if class == nil then
        return
    end

    if CharacterSpec == nil then
        printNoSpecSelected()
        return
    end

    local availableSpecs = addon.talents[class]

    if availableSpecs == nil then
        addonMessage("No talents found for class " .. printPlayerClass())
        return
    elseif availableSpecs[CharacterSpec] == nil then
        addonMessage("No talents found for spec " .. CharacterSpec)
        return
    end

    local level = UnitLevel("player")
    local nextTalentToLearn = availableSpecs[CharacterSpec][level - 9]

    if nextTalentToLearn == nil then
        addonMessage(addon.colorText("Not implemented yet", addon.colors.RED))
        return
    end

    addonMessage("Talent to learn this level (" .. level .. "): " .. addon.colorText(nextTalentToLearn, addon.colors.YELLOW))
end

local function listTalentsToLearn()
    local class = getPlayerClass()
    if class == nil then
        return
    end

    if CharacterSpec == nil then
        printNoSpecSelected()
        return
    end

    local level = UnitLevel("player")

    -- Skip levels below 10, as talents are not available yet
    if level < 10 then
        return
    end

    local availableSpecs = addon.talents[class]

    if availableSpecs == nil then
        addonMessage("No talents found for class " .. printPlayerClass())
        return
    elseif availableSpecs[CharacterSpec] == nil then
        addonMessage("No talents found for spec " .. CharacterSpec)
        return
    end

    local unspentTalentPoints = GetUnspentTalentPoints()

    if unspentTalentPoints == 0 then
        addonMessage("No unspent talent points available")
        return
    end

    -- List the talents to learn based on the number of unspent talent points
    addonMessage("Talents to learn for spec " .. CharacterSpec .. ":")
    local startIndex = level - 9
    for i = 0, unspentTalentPoints - 1 do
        local talent = availableSpecs[CharacterSpec][startIndex + i]
        if talent ~= nil then
            addonMessage((i + 1) .. ": " .. addon.colorText(talent, addon.colors.YELLOW))
        end
    end
end

local function listTalentsForSpec(spec)
    local class = getPlayerClass()
    if class == nil then
        return
    end
    if addon.talents == nil then
        return
    end
    local classTalents = addon.talents[class]
    if classTalents == nil then
        return
    end
    local specTalents = classTalents[spec]
    if specTalents == nil then
        addonMessage("No talents found for spec " .. spec)
        return
    end
    addonMessage("Talents for spec " .. spec .. ":")
    for level, talent in ipairs(specTalents) do
        addonMessage("Level " .. (level + 9) .. ": " .. addon.colorText(talent, addon.colors.YELLOW))
    end
end

local function eventHandler(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "NextTalent" then
        if CharacterSpec == nil then
            printNoSpecSelected()
        else
            addonMessage("Current spec: '" .. addon.colorText(CharacterSpec, addon.colors.GREEN) .. "'")
        end
    end
    if event == "PLAYER_LEVEL_CHANGED" then
        listTalentsToLearn()
    end
end
frame:SetScript("OnEvent", eventHandler)

SLASH_NEXTTALENT1 = "/nexttalent"
SLASH_NEXTTALENT2 = "/nt"

SlashCmdList["NEXTTALENT"] = function(message, editbox)
    local cmd, argument = message:match("^(%S*)%s*(.-)$")
    local command = string.lower(cmd)

    if command == "" or command == nil then
        return listTalentsToLearn()

    elseif command == "spec" then
        local class = getPlayerClass()
        if class == nil then
            return
        end

        if argument == "" or argument == nil then
            if CharacterSpec == nil then
                printNoSpecSelected()
            else
                addonMessage("Current spec: " .. addon.colorText(CharacterSpec, addon.colors.YELLOW))
            end
            printAvailableSpecs()
            return
        end

        -- Find the spec that matches the input
        local availableSpecs = getAvailableSpecs()
        for _, spec in pairs(availableSpecs) do
            if string.lower(spec) == string.lower(argument) then
                CharacterSpec = spec
                print("Spec selected: " .. addon.colorText(CharacterSpec, addon.colors.YELLOW))
                return
            end
        end
        -- Spec not found
        addonMessage("The selected spec is not available")
        printAvailableSpecs()
        return

    elseif command == "list" then
        if CharacterSpec == nil then
            printNoSpecSelected()
            return
        end
        listTalentsForSpec(CharacterSpec)
        return

    elseif command == "help" then
        addonMessage("Available commands:")
        print("/nexttalent spec <spec> - select a spec")
        print("/nexttalent - show the next talent to learn")
        print("/nexttalent list - list all talents for the selected spec")
        print("/nexttalent help - show this help")
        return
    end

    print("Unknown command. Type /nexttalent help to see available commands.")
end
