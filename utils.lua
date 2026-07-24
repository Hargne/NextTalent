local name, addon = ...;

addon.colors = {
    RED = "FF0000",
    GREEN = "00FF00",
    YELLOW = "FFFF00",
    BLUE = "0000FF",
    PURPLE = "FF00FF",
    CYAN = "00FFFF",
    WHITE = "FFFFFF"
}

addon.colorText = function(text, color)
    return "\124cff" .. color .. text .. "\124r"
end

function addon:PrintMessage(message)
    print(addon.colorText("[NextTalent]:", addon.colors.YELLOW) .. " " .. message)
end

function addon:PrintError(message)
    print(addon.colorText("[NextTalent]:", addon.colors.RED) .. " " .. message)
end

function addon:getPlayerClass()
    local guid = UnitGUID("player")
    if guid == nil then
        addon:PrintError("Player not found")
        return nil
    end
    return GetPlayerInfoByGUID(guid)
end
