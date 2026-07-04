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

addon.colorText = function (text, color)
    return "\124cff" .. color .. text .. "\124r"
end