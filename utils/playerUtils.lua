local name, addon = ...

function addon:getPlayerClass()
    local guid = UnitGUID("player")
    if guid == nil then
        addon:PrintError("Player not found")
        return nil
    end
    local _, class = GetPlayerInfoByGUID(guid)
    return class
end