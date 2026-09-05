RUQL_NPCS = RUQL_NPCS or {}
RUQL_OBJECTS = RUQL_OBJECTS or {}

local FONT_FILE = "Interface\\AddOns\\WoWQuestLocalizer_RU\\Fonts\\PTSans-Regular.ttf"
local guard = false

local function creatureIDFromGUID(guid)
    if not guid or string.sub(guid, 1, 2) ~= "0x" then return nil end
    local high = string.sub(guid, 3, 6)
    if high ~= "F130" and high ~= "F140" and high ~= "F150" then return nil end
    return tonumber(string.sub(guid, 7, 12), 16)
end

local function addRussianLine(tooltip, translation)
    if guard or not translation or translation == "" then return end
    guard = true
    tooltip:AddLine(translation, 0.35, 0.75, 1, true)
    local name = tooltip:GetName()
    local line = name and _G[name .. "TextLeft" .. tooltip:NumLines()]
    if line and line.SetFont then line:SetFont(FONT_FILE, 12, "") end
    tooltip:Show()
    guard = false
end

local function onUnit(tooltip)
    local _, unit = tooltip:GetUnit()
    if not unit then return end
    if RUQL_CollectUnit then RUQL_CollectUnit(unit) end
    local creatureID = creatureIDFromGUID(UnitGUID(unit))
    local translation = creatureID and RUQL_NPCS[creatureID]
    if translation then addRussianLine(tooltip, translation[1]) end
end

local function onShow(tooltip)
    if guard or not WorldFrame or tooltip:GetOwner() ~= WorldFrame then return end
    local _, unit = tooltip:GetUnit()
    if unit then return end
    local name = tooltip:GetName()
    local firstLine = name and _G[name .. "TextLeft1"]
    local original = firstLine and firstLine:GetText()
    if not original or original == "" then return end
    if RUQL_CollectObject then RUQL_CollectObject(original) end
    addRussianLine(tooltip, RUQL_OBJECTS[original])
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
    if GameTooltip and GameTooltip.HookScript then
        GameTooltip:HookScript("OnTooltipSetUnit", onUnit)
        GameTooltip:HookScript("OnShow", onShow)
    end
end)
