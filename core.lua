local name, addon = ...;

local frame = CreateFrame("FRAME", "NextTalentAddonFrame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LEVEL_CHANGED")
frame:RegisterEvent("PLAYER_TALENT_UPDATE")

local selectedSpec = CharacterSpec or nil
local specType = "leveling"
local previousUnspentTalentPoints = GetUnspentTalentPoints()

local function listAvailableSpecs()
    local class = addon:getPlayerClass()
    if class == nil then
        return
    end

    local specs = addon:GetSpecsForClass(class)
    if specs == nil then
        addon:PrintMessage("No specs found for " .. class)
        return
    end

    addon:PrintMessage("Available specs for " .. class .. ": " .. table.concat(specs, ", "))
end

local function printNoSpecSelected()
    addon:PrintMessage("No spec selected. Type /nexttalent spec <spec> to select a spec.")
end

local function listTalentsToLearn()
    local class = addon:getPlayerClass()
    if class == nil then
        return
    end

    if not selectedSpec then
        printNoSpecSelected()
        return
    end

    local level = UnitLevel("player")

    if level < 10 then
        return
    end

    local talents = addon:GetSpecTalents(class, selectedSpec)
    if talents == nil then
        addon:PrintMessage("No talents found for spec " .. selectedSpec)
        return
    end

    local unspentTalentPoints = GetUnspentTalentPoints()
    local nextTalentIndex = (level - 9) - unspentTalentPoints + 1
    if unspentTalentPoints == 0 then
        addon:PrintMessage("You have no unspent talent points.")
        addon:PrintMessage("Talent to learn next level: " .. addon.colorText(talents[specType][nextTalentIndex], addon.colors.YELLOW))
        return
    end

    -- If the player has more than one unspent talent point, list the talents to learn for the current spec
    if unspentTalentPoints > 1 then
        addon:PrintMessage("Talents to learn for spec " .. selectedSpec .. ":")
        local startIndex = nextTalentIndex
        for i = 0, unspentTalentPoints - 1 do
            local talent = talents[specType][startIndex + i]
            if talent ~= nil then
                addon:PrintMessage((i + 1) .. ": " .. addon.colorText(talent, addon.colors.YELLOW))
            end
        end
    end

    addon:PrintMessage("Next talent to learn: " .. addon.colorText(talents[specType][nextTalentIndex], addon.colors.YELLOW))
end

local function selectSpec(inputSpec)
    if inputSpec == "" or inputSpec == nil then
        return
    end

    local class = addon:getPlayerClass()
    if class == nil then
        return
    end

    local availableSpecs = addon:GetSpecsForClass(class)
    for _, spec in pairs(availableSpecs) do
        if string.lower(spec) == string.lower(inputSpec) then
            CharacterSpec = spec
            selectedSpec = spec
            PlaySound(236, "master")
            addon:PrintMessage("Spec selected: " .. addon.colorText(selectedSpec, addon.colors.YELLOW))
            return
        end
    end

    addon:PrintMessage("The spec you selected is not available for this class!")
    listAvailableSpecs()
    return
end

local function listAllTalents()
    local class = addon:getPlayerClass()
    if class == nil then
        return
    end

    if not selectedSpec then
        printNoSpecSelected()
        return
    end

    local specTypes = addon:GetSpecTalents(class, selectedSpec)
    if specTypes == nil then
        addon:PrintMessage("No talents found for spec " .. selectedSpec)
        return
    end

    local talents = specTypes[specType]
    if talents == nil then
        return
    end

    addon:PrintMessage("Talents for spec " .. selectedSpec .. ":")
    for level, talent in ipairs(talents) do
        addon:PrintMessage("Level " .. (level + 9) .. ": " .. addon.colorText(talent, addon.colors.YELLOW))
    end
end

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "NextTalent" then
        if not selectedSpec then
            printNoSpecSelected()
            listAvailableSpecs()
        else
            addon:PrintMessage("Current spec: '" .. addon.colorText(selectedSpec, addon.colors.GREEN) .. "'")
        end
    end

    if event == "PLAYER_LEVEL_CHANGED" then
        listTalentsToLearn()
    end

    if event == "PLAYER_TALENT_UPDATE" then
        local currentUnspentPoints = GetUnspentTalentPoints()
        -- By caching the number of unspent talent points, we prevent the PLAYER_TALENT_UPDATE event from triggering listTalentsToLearn() upon login
        if currentUnspentPoints > 0 and currentUnspentPoints ~= previousUnspentTalentPoints then
            previousUnspentTalentPoints = currentUnspentPoints
            listTalentsToLearn()
        end
    end
end)

SLASH_NEXTTALENT1 = "/nexttalent"
SLASH_NEXTTALENT2 = "/nt"

SlashCmdList["NEXTTALENT"] = function(message, editbox)
    local playerClass = addon:getPlayerClass()
    -- No need to continue if there is no class available
    if playerClass == nil then
        return
    end

    local cmd, argument = (message or ""):match("^(%S*)%s*(.-)$")
    local command = cmd and string.lower(cmd) or ""

    if command == "" or command == nil then
        local level = UnitLevel("player")
        if level < 10 then
            addon:PrintMessage("You are below level 10. Talents are not available yet.")
            return
        end
        return listTalentsToLearn()

    elseif command == "spec" then
        if argument == "" or argument == nil then
            if not selectedSpec then
                printNoSpecSelected()
            else
                addon:PrintMessage("Current spec: " .. addon.colorText(selectedSpec, addon.colors.YELLOW))
            end
            listAvailableSpecs()
            return
        end

        selectSpec(argument)
        return

    elseif command == "list" then
        listAllTalents()
        return

    elseif command == "help" then
        addon:PrintMessage("Available commands:")
        print("/nexttalent spec <spec> - select a spec")
        print("/nexttalent - show the next talent to learn")
        print("/nexttalent list - list all talents for the selected spec")
        print("/nexttalent help - show this help")
        return
    end

    addon:PrintError("Unknown command. Type /nexttalent help to see available commands.")
end
