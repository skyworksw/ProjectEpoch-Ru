-- Перевод названий зон/подзон. В отличие от квестов и тултипов, эти строки
-- не приходят через текстовый регион фрейма — клиент отдаёт их функциями
-- GetZoneText/GetSubZoneText/GetRealZoneText/GetMinimapZoneText, поэтому
-- переопределяем сами функции, а не хукаем SetText.
RUQL_ZONES = RUQL_ZONES or {}

local FONT_FILE = "Interface\\AddOns\\ProjectEpoch-Ru\\Fonts\\FRIZQT___CYR.ttf"

local realGetZoneText = GetZoneText
local realGetSubZoneText = GetSubZoneText
local realGetRealZoneText = GetRealZoneText
local realGetMinimapZoneText = GetMinimapZoneText

local function applyFont(region)
    if not region or not region.SetFont or not region.GetFont then return end
    local _, size, flags = region:GetFont()
    region:SetFont(FONT_FILE, size or 12, flags or "")
end

local function translationEnabled()
    return not RUQL_Settings or (RUQL_Settings.enabled ~= false and not RUQL_Settings.showOriginal)
end

local function translateZone(name)
    if not name or name == "" or not translationEnabled() then return name end
    local translated = RUQL_ZONES[name]
    if translated then return translated end
    if RUQL_ReportAdd then RUQL_ReportAdd("zones", name, { name = name }) end
    return name
end

if realGetZoneText then
    GetZoneText = function(...) return translateZone(realGetZoneText(...)) end
end
if realGetSubZoneText then
    GetSubZoneText = function(...) return translateZone(realGetSubZoneText(...)) end
end
if realGetRealZoneText then
    GetRealZoneText = function(...) return translateZone(realGetRealZoneText(...)) end
end
if realGetMinimapZoneText then
    GetMinimapZoneText = function(...) return translateZone(realGetMinimapZoneText(...)) end
end

-- Сама подмена текста происходит внутри стандартного Blizzard-обработчика
-- (он читает GetMinimapZoneText()/GetRealZoneText() и сам вызывает SetText),
-- нам остаётся только досадить кириллический шрифт поверх результата.
local zoneFrame = CreateFrame("Frame")
zoneFrame:RegisterEvent("ZONE_CHANGED")
zoneFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
zoneFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
zoneFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
zoneFrame:SetScript("OnEvent", function()
    applyFont(MinimapZoneText)
    applyFont(PVPInfoZoneText)
end)
