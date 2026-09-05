RUQL_INTERFACE_TEXT = RUQL_INTERFACE_TEXT or {}
RUQL_GLOBAL_STRINGS = RUQL_GLOBAL_STRINGS or {}

local FONT_FILE = "Interface\\AddOns\\ProjectEpoch-Ru\\Fonts\\FRIZQT___CYR.ttf"

local function applyFont(object)
    if not object or not object.SetFont or not object.GetFont then return end
    local _, size, flags = object:GetFont()
    object:SetFont(FONT_FILE, size or 12, flags or "")
end

local function applyInterfaceTranslation()
    local key, translation
    for key, translation in pairs(RUQL_GLOBAL_STRINGS) do
        if type(key) == "string" and type(translation) == "string" then
            _G[key] = translation
        end
    end
    for key, translation in pairs(RUQL_INTERFACE_TEXT) do
        local object = _G[key]
        if object and object.SetText and type(translation) == "string" then
            object:SetText(translation)
            applyFont(object)
        end
    end
end

-- Override translated globals immediately so load-on-demand Blizzard addons use them.
applyInterfaceTranslation()

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addonName)
    if event == "PLAYER_LOGIN" or addonName ~= "ProjectEpoch-Ru" then
        applyInterfaceTranslation()
    end
end)
