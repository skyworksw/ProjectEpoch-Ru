RUQL_NPCS = RUQL_NPCS or {}
RUQL_OBJECTS = RUQL_OBJECTS or {}

local FONT_FILE = "Interface\\AddOns\\ProjectEpoch-Ru\\Fonts\\FRIZQT___CYR.ttf"
local guard = false

local function creatureIDFromGUID(guid)
    if not guid or string.sub(guid, 1, 2) ~= "0x" then return nil end
    local high = string.sub(guid, 3, 6)
    if high ~= "F130" and high ~= "F140" and high ~= "F150" then return nil end
    return tonumber(string.sub(guid, 7, 12), 16)
end

local function replaceLine(line, translation)
    if not line or not translation or translation == "" then return end
    line:SetText(translation)
    if line.SetFont and line.GetFont then
        local _, size, flags = line:GetFont()
        line:SetFont(FONT_FILE, size or 12, flags or "")
    end
end

local function replaceWorldTooltip(tooltip, title, subtitle)
    if guard or not title or title == "" then return end
    local name = tooltip:GetName()
    if not name then return end

    guard = true
    replaceLine(_G[name .. "TextLeft1"], title)
    if subtitle and subtitle ~= "" then
        replaceLine(_G[name .. "TextLeft2"], subtitle)
    end
    tooltip:Show()
    guard = false
end

local function onUnit(tooltip)
    if not RUQL_Settings or not RUQL_Settings.tooltips then return end
    local _, unit = tooltip:GetUnit()
    if not unit then return end
    local creatureID = creatureIDFromGUID(UnitGUID(unit))
    local translation = creatureID and RUQL_NPCS[creatureID]
    if translation then
        replaceWorldTooltip(tooltip, translation[1], translation[2])
    elseif creatureID and RUQL_ReportAdd then
        RUQL_ReportAdd("npcs", creatureID, {
            name = UnitName(unit),
            zone = GetRealZoneText and GetRealZoneText() or nil,
        })
    end
end

local function onShow(tooltip)
    if guard or not RUQL_Settings or not RUQL_Settings.tooltips
        or not WorldFrame or tooltip:GetOwner() ~= WorldFrame then return end
    local _, unit = tooltip:GetUnit()
    if unit then return end
    local name = tooltip:GetName()
    local firstLine = name and _G[name .. "TextLeft1"]
    local original = firstLine and firstLine:GetText()
    if not original or original == "" then return end
    local translation = RUQL_OBJECTS[original]
    if translation then
        replaceWorldTooltip(tooltip, translation)
    elseif RUQL_ReportAdd then
        local zone = GetRealZoneText and GetRealZoneText() or "?"
        RUQL_ReportAdd("objects", zone .. "::" .. original, { name = original, zone = zone })
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
    if GameTooltip and GameTooltip.HookScript then
        GameTooltip:HookScript("OnTooltipSetUnit", onUnit)
        GameTooltip:HookScript("OnShow", onShow)
    end
end)
