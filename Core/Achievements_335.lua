RUQL_ACHIEVEMENTS = RUQL_ACHIEVEMENTS or {}

local FONT_FILE = "Interface\\AddOns\\ProjectEpoch-Ru\\Fonts\\PTSans-Regular.ttf"

local function showAchievementTranslation(tooltip, link)
    local achievementID = link and tonumber(string.match(link, "achievement:(%d+)"))
    local achievement = achievementID and RUQL_ACHIEVEMENTS[achievementID]
    if not achievement then return end
    local first = tooltip:NumLines() + 1
    tooltip:AddLine(" ")
    tooltip:AddLine("Русский перевод", 0.35, 0.65, 1)
    if achievement[1] then tooltip:AddLine(achievement[1], 1, 0.82, 0, true) end
    if achievement[2] then tooltip:AddLine(achievement[2], 1, 1, 1, true) end
    if achievement[3] then tooltip:AddLine(achievement[3], 0.35, 1, 0.35, true) end
    local name = tooltip:GetName()
    local line
    for line = first, tooltip:NumLines() do
        local region = name and _G[name .. "TextLeft" .. line]
        if region and region.SetFont then region:SetFont(FONT_FILE, 12, "") end
    end
    tooltip:Show()
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
    local tooltips = { GameTooltip, ItemRefTooltip }
    local _, tooltip
    for _, tooltip in ipairs(tooltips) do
        if tooltip and hooksecurefunc then
            hooksecurefunc(tooltip, "SetHyperlink", showAchievementTranslation)
        end
    end
end)
