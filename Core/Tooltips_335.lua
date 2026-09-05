RUQL_ITEMS = RUQL_ITEMS or {}
RUQL_SPELLS = RUQL_SPELLS or {}

local FONT_FILE = "Interface\\AddOns\\ProjectEpoch-Ru\\Fonts\\PTSans-Regular.ttf"
local guard = false

local function fontLastLines(tooltip, firstLine)
    local name = tooltip:GetName()
    if not name then return end
    local line
    for line = firstLine, tooltip:NumLines() do
        local left = _G[name .. "TextLeft" .. line]
        local right = _G[name .. "TextRight" .. line]
        if left then left:SetFont(FONT_FILE, 12, "") end
        if right then right:SetFont(FONT_FILE, 12, "") end
    end
end

local function itemIDFromLink(link)
    if not link then return nil end
    return tonumber(string.match(link, "item:(%d+)"))
end

local function onItem(tooltip)
    if guard or not RUQL_Settings or not RUQL_Settings.tooltips then return end
    local originalName, link = tooltip:GetItem()
    local itemID = itemIDFromLink(link)
    if not itemID then return end

    local item = RUQL_ITEMS[itemID]
    if not item then
        RUQL_MissingItems = RUQL_MissingItems or {}
        RUQL_MissingItems[itemID] = originalName or true
        if RUQL_CollectItem then RUQL_CollectItem(itemID, originalName) end
        return
    end

    guard = true
    local firstLine = tooltip:NumLines() + 1
    tooltip:AddLine(" ")
    tooltip:AddLine("Русский перевод", 0.35, 0.65, 1)
    if item[1] and item[1] ~= "" then tooltip:AddLine(item[1], 1, 0.82, 0, true) end
    if item[2] and item[2] ~= "" then tooltip:AddLine(item[2], 1, 1, 1, true) end
    fontLastLines(tooltip, firstLine)
    tooltip:Show()
    guard = false
end

local function onSpell(tooltip)
    if guard or not RUQL_Settings or not RUQL_Settings.tooltips then return end
    if not tooltip.GetSpell then return end
    local ok, originalName, originalRank, spellID = pcall(tooltip.GetSpell, tooltip)
    spellID = tonumber(spellID)
    if not ok or not spellID then return end

    local spell = RUQL_SPELLS[spellID]
    if not spell then
        RUQL_MissingSpells = RUQL_MissingSpells or {}
        RUQL_MissingSpells[spellID] = { originalName, originalRank }
        if RUQL_CollectSpell then RUQL_CollectSpell(spellID, originalName, originalRank) end
        return
    end

    guard = true
    local firstLine = tooltip:NumLines() + 1
    tooltip:AddLine(" ")
    tooltip:AddLine("Русский перевод", 0.35, 0.65, 1)
    tooltip:AddLine(spell[1] or originalName or "", 1, 0.82, 0, true)
    if spell[2] and spell[2] ~= "" then tooltip:AddLine(spell[2], 0.7, 0.7, 0.7, true) end
    if spell[3] and spell[3] ~= "" then tooltip:AddLine(spell[3], 1, 1, 1, true) end
    fontLastLines(tooltip, firstLine)
    tooltip:Show()
    guard = false
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
    if RUQL_Settings.tooltips == nil then RUQL_Settings.tooltips = true end
    RUQL_MissingItems = RUQL_MissingItems or {}
    RUQL_MissingSpells = RUQL_MissingSpells or {}

    local tooltips = { GameTooltip, ItemRefTooltip, ShoppingTooltip1, ShoppingTooltip2 }
    local _, tooltip
    for _, tooltip in ipairs(tooltips) do
        if tooltip and tooltip.HookScript then
            tooltip:HookScript("OnTooltipSetItem", onItem)
            tooltip:HookScript("OnTooltipSetSpell", onSpell)
        end
    end
end)
