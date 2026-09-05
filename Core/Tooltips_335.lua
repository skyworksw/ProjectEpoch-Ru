RUQL_ITEMS = RUQL_ITEMS or {}
RUQL_SPELLS = RUQL_SPELLS or {}

local FONT_FILE = "Interface\\AddOns\\ProjectEpoch-Ru\\Fonts\\FRIZQT___CYR.ttf"
-- FRIZQT___CYR.ttf renders noticeably larger than the stock Latin Friz
-- Quadrata at the same point size, so scale down to match the original
-- proportions (e.g. item title vs. body text).
local CYRILLIC_SCALE = 0.85
local guard = false

local function applyFont(line)
    if not line or not line.SetFont or not line.GetFont then return end
    local _, size, flags = line:GetFont()
    line:SetFont(FONT_FILE, math.floor((size or 12) * CYRILLIC_SCALE + 0.5), flags or "")
end

local function isQuotedDescription(text)
    if not text or string.len(text) < 2 then return false end
    return string.sub(text, 1, 1) == '"' and string.sub(text, -1) == '"'
end

local function replaceMatchingRank(tooltip, originalRank, translatedRank)
    if not originalRank or originalRank == "" or not translatedRank or translatedRank == "" then return end
    local name = tooltip:GetName()
    if not name then return end

    local lineNumber
    for lineNumber = 1, tooltip:NumLines() do
        local left = _G[name .. "TextLeft" .. lineNumber]
        local right = _G[name .. "TextRight" .. lineNumber]
        if left and left:GetText() == originalRank then
            left:SetText(translatedRank)
            applyFont(left)
            return
        end
        if right and right:GetText() == originalRank then
            right:SetText(translatedRank)
            applyFont(right)
            return
        end
    end
end

local function findSpellDescriptionLine(tooltip, originalName, originalRank)
    local name = tooltip:GetName()
    if not name then return nil end

    local bestLine
    local bestLength = 0
    local lineNumber
    for lineNumber = 2, tooltip:NumLines() do
        local left = _G[name .. "TextLeft" .. lineNumber]
        local right = _G[name .. "TextRight" .. lineNumber]
        local text = left and left:GetText()
        local rightText = right and right:GetText()
        if text and text ~= "" and text ~= originalName and text ~= originalRank
            and (not rightText or rightText == "") then
            local red, green, blue
            if left.GetTextColor then red, green, blue = left:GetTextColor() end
            local isError = red and green and blue and red > 0.8 and green < 0.35 and blue < 0.35
            local length = string.len(text)
            if not isError and length > bestLength then
                bestLine = left
                bestLength = length
            end
        end
    end
    return bestLine
end

local function replaceSpellText(tooltip, spell, originalName, originalRank)
    local name = tooltip:GetName()
    if not name then return end

    local title = _G[name .. "TextLeft1"]
    if title and spell[1] and spell[1] ~= "" then
        title:SetText(spell[1])
        applyFont(title)
    end

    replaceMatchingRank(tooltip, originalRank, spell[2])

    if spell[3] and spell[3] ~= "" then
        local description = findSpellDescriptionLine(tooltip, originalName, originalRank)
        if description then
            description:SetText(spell[3])
            applyFont(description)
        end
    end
end

local function replaceItemText(tooltip, item)
    local name = tooltip:GetName()
    if not name then return end

    local title = _G[name .. "TextLeft1"]
    if title and item[1] and item[1] ~= "" then
        title:SetText(item[1])
        applyFont(title)
    end

    if not item[2] or item[2] == "" then return end

    local lineNumber
    for lineNumber = 2, tooltip:NumLines() do
        local line = _G[name .. "TextLeft" .. lineNumber]
        local text = line and line:GetText()
        if isQuotedDescription(text) then
            line:SetText('"' .. item[2] .. '"')
            applyFont(line)
            return
        end
    end
end

-- Стандартные строки тултипа предметов не поступают через RUQL_ITEMS — их
-- строит сам клиент по флагам предмета. Переопределять их через глобальные
-- переменные (ITEM_BIND_ON_PICKUP и т.п.) нельзя: та часть тултипа рисуется
-- default-шрифтом без кириллицы, и текст превращается в "???". Поэтому строки
-- ищутся построчно в уже отрисованном тултипе и заменяются с applyFont().
local EXACT_LINE_TRANSLATIONS = {
    ["Binds when picked up"] = "Привязывается при получении",
    ["Binds when equipped"] = "Привязывается при экипировке",
    ["Binds when used"] = "Привязывается при использовании",
    ["Quest Item"] = "Квестовый предмет",
    ["Unique"] = "Уникальный",
    ["Unique-Equipped"] = "Уникальный (в экипировке)",
}

local PREFIX_TRANSLATIONS = {
    ["Use: "] = "Использование: ",
    ["Equip: "] = "Экипировка: ",
    ["Chance on hit: "] = "Шанс при ударе: ",
}

local function translateBoilerplateLines(tooltip)
    local name = tooltip:GetName()
    if not name then return end

    local lineNumber
    for lineNumber = 2, tooltip:NumLines() do
        local line = _G[name .. "TextLeft" .. lineNumber]
        local text = line and line:GetText()
        if text and text ~= "" then
            local exact = EXACT_LINE_TRANSLATIONS[text]
            local uniqueCount = not exact and string.match(text, "^Unique %((%d+)%)$")
            if exact then
                line:SetText(exact)
                applyFont(line)
            elseif uniqueCount then
                line:SetText("Уникальный (" .. uniqueCount .. ")")
                applyFont(line)
            else
                local prefix, translatedPrefix
                for prefix, translatedPrefix in pairs(PREFIX_TRANSLATIONS) do
                    if string.sub(text, 1, string.len(prefix)) == prefix then
                        line:SetText(translatedPrefix .. string.sub(text, string.len(prefix) + 1))
                        applyFont(line)
                        break
                    end
                end
            end
        end
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

    local item = itemID and RUQL_ITEMS[itemID]
    if itemID and not item and RUQL_ReportAdd then
        RUQL_ReportAdd("items", itemID, { name = originalName })
    end

    guard = true
    if item then replaceItemText(tooltip, item) end
    translateBoilerplateLines(tooltip)
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
        if RUQL_ReportAdd then RUQL_ReportAdd("spells", spellID, { name = originalName, rank = originalRank }) end
        return
    end

    guard = true
    replaceSpellText(tooltip, spell, originalName, originalRank)
    tooltip:Show()
    guard = false
end

local function onTalent(tooltip)
    -- SetTalent does not consistently emit OnTooltipSetSpell on every 3.3.5 client.
    -- Reuse the spell lookup when the tooltip exposes the underlying spell ID.
    onSpell(tooltip)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
    if RUQL_Settings.tooltips == nil then RUQL_Settings.tooltips = true end

    local tooltips = { GameTooltip, ItemRefTooltip, ShoppingTooltip1, ShoppingTooltip2 }
    local _, tooltip
    for _, tooltip in ipairs(tooltips) do
        if tooltip and tooltip.HookScript then
            tooltip:HookScript("OnTooltipSetItem", onItem)
            tooltip:HookScript("OnTooltipSetSpell", onSpell)
        end
    end

    if GameTooltip and GameTooltip.SetTalent and hooksecurefunc then
        hooksecurefunc(GameTooltip, "SetTalent", onTalent)
    end
end)
