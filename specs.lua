local name, addon = ...

addon.talents = addon.talents or {}

function addon:RegisterSpecs(className, specs)
    addon.talents[className] = specs
end

function addon:GetSpecsForClass(class)
    if class == nil or addon.talents == nil then
        return
    end

    local classTalents = addon.talents[string.upper(class)]
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

function addon:GetSpecTalents(class, spec)
    if class == nil or addon.talents == nil then
        return
    end

    local classTalents = addon.talents[string.upper(class)]
    if classTalents == nil then
        return
    end

    return classTalents[string.upper(spec)]
end