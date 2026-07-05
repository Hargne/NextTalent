local name, addon = ...;

local frame = CreateFrame("FRAME", "NextTalentAddonFrame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LEVEL_CHANGED")

local specType = "leveling"

local function getPlayerClass()
    local guid = UnitGUID("player")
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

local function listAvailableSpecs()
    local class = getPlayerClass()
    if class == nil then
        return
    end

    local specs = addon:GetSpecsForClass(class)
    if specs == nil then
        addon:PrintMessage("No specs found for class " .. class)
        return
    end
    
    addon:PrintMessage("Available specs for " .. class .. ": " .. table.concat(specs, ", "))
end

local function printNoSpecSelected()
    addon:PrintMessage("No spec selected. Type /nexttalent spec <spec> to select a spec.")
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

    local unspentTalentPoints = GetUnspentTalentPoints()
    if unspentTalentPoints == 0 then
        addon:PrintMessage("No unspent talent points available")
        return
    end

    local talents = addon:GetSpecTalents(class, CharacterSpec)
    if talents == nil then
        addon:PrintMessage("No talents found for spec " .. CharacterSpec)
        return
    end

    -- List the talents to learn based on the number of unspent talent points
    addon:PrintMessage("Talents to learn for spec " .. CharacterSpec .. ":")
    local startIndex = level - 9
    for i = 0, unspentTalentPoints - 1 do
        local talent = talents[specType][startIndex + i]
        if talent ~= nil then
            addon:PrintMessage((i + 1) .. ": " .. addon.colorText(talent, addon.colors.YELLOW))
        end
    end
end

local function listTalentsForCurrentSpec()
    local class = getPlayerClass()
    if class == nil then
        return
    end

    if CharacterSpec == nil then
        printNoSpecSelected()
        return
    end

    local specTypes = addon:GetSpecTalents(class, CharacterSpec)
    if specTypes == nil then
        addon:PrintMessage("No talents found for spec " .. CharacterSpec)
        return
    end

    local talents = specTypes[specType]
    if talents == nil then
        return
    end

    addon:PrintMessage("Talents for spec " .. CharacterSpec .. ":")
    for level, talent in ipairs(talents) do
        addon:PrintMessage("Level " .. (level + 9) .. ": " .. addon.colorText(talent, addon.colors.YELLOW))
    end
end

local function eventHandler(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "NextTalent" then
        if CharacterSpec == nil then
            printNoSpecSelected()
        else
            addon:PrintMessage("Current spec: '" .. addon.colorText(CharacterSpec, addon.colors.GREEN) .. "'")
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
    local playerClass = getPlayerClass()
    -- No need to continue if there is no class available
    if playerClass == nil then
        return
    end
        
    local cmd, argument = message:match("^(%S*)%s*(.-)$")
    local command = string.lower(cmd)

    if command == "" or command == nil then
        return listTalentsToLearn()

    elseif command == "spec" then
        if argument == "" or argument == nil then
            if CharacterSpec == nil then
                printNoSpecSelected()
            else
                addon:PrintMessage("Current spec: " .. addon.colorText(CharacterSpec, addon.colors.YELLOW))
            end
            listAvailableSpecs()
            return
        end

        -- Find the spec that matches the input
        local availableSpecs = addon:GetSpecsForClass(playerClass)
        for _, spec in pairs(availableSpecs) do
            if string.lower(spec) == string.lower(argument) then
                CharacterSpec = spec
                addon:PrintMessage("Spec selected: " .. addon.colorText(CharacterSpec, addon.colors.YELLOW))
                return
            end
        end
        -- Spec not found
        addon:PrintMessage("The selected spec is not available")
        listAvailableSpecs()
        return

    elseif command == "list" then
        listTalentsForCurrentSpec()
        return

    elseif command == "help" then
        addon:PrintMessage("Available commands:")
        print("/nexttalent spec <spec> - select a spec")
        print("/nexttalent - show the next talent to learn")
        print("/nexttalent list - list all talents for the selected spec")
        print("/nexttalent help - show this help")
        return
    end

    print("Unknown command. Type /nexttalent help to see available commands.")
end
