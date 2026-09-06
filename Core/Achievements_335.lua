RUQL_ACHIEVEMENTS = RUQL_ACHIEVEMENTS or {}

local FONT_FILE = "Interface\\AddOns\\ProjectEpoch-Ru\\Fonts\\FRIZQT___CYR.ttf"

local function applyFont(region)
    if not region or not region.SetFont or not region.GetFont then return end
    local _, size, flags = region:GetFont()
    region:SetFont(FONT_FILE, size or 12, flags or "")
end

-- Панель ачивок (AchievementFrame) переиспользует одни и те же кнопки
-- (AchievementFrameCategoriesContainerButtonN, AchievementFrameAchievementsContainerButtonN)
-- под РАЗНЫЕ категории/ачивки в зависимости от скролла и раскрытых
-- подкатегорий — см. InterfaceData_Custom_RU.lua, где раньше был перевод
-- "по номеру кнопки" и он путал категории между собой. Здесь переводим по
-- ТЕКСТУ, который в моменте реально показан в кнопке — так же, как аддон
-- уже переводит квесты (по названию через RUQL_TITLE_INDEX) и NPC/предметы
-- (по данным, захваченным на живом клиенте), а не по позиции в списке.

-- Список категорий ачивок фиксирован и одинаков у всех игроков (это не
-- игровой контент, а разделы самого интерфейса), поэтому единственный
-- надёжный ключ здесь — само английское название категории.
local CATEGORY_NAMES = {
    ["Summary"] = "Сводка",
    ["General"] = "Общее",
    ["Quests"] = "Задания",
    ["Exploration"] = "Исследование",
    ["Player vs. Player"] = "PvP",
    ["Dungeons & Raids"] = "Подземелья и рейды",
    ["Professions"] = "Профессии",
    ["Reputation"] = "Репутация",
    ["World Events"] = "Мировые события",
    ["Feats of Strength"] = "Подвиги",
    ["Statistics"] = "Статистика",
    ["Engineering"] = "Инженерное дело",
    ["Leatherworking"] = "Кожевничество",
    ["Tailoring"] = "Портняжное дело",
    ["Herbalism"] = "Травничество",
    ["Mining"] = "Горное дело",
    ["Skinning"] = "Снятие шкур",
    ["Blacksmithing"] = "Кузнечное дело",
    ["Alchemy"] = "Алхимия",
    ["Enchanting"] = "Зачарование",
    ["Jewelcrafting"] = "Ювелирное дело",
    ["Cooking"] = "Кулинария",
    ["Fishing"] = "Рыбная ловля",
    ["First Aid"] = "Первая помощь",
}

-- Индекс "английское название ачивки -> ключ в RUQL_ACHIEVEMENTS". Ключом
-- может быть либо настоящий numeric achievementID (когда он уже известен —
-- см. showAchievementTranslation ниже, там ID приходит из ссылки), либо
-- само английское название строкой (когда ID ещё не захвачен, а название
-- панели уже нужно перевести). Строковый ключ никогда не совпадёт с
-- настоящим numeric ID, так что это не портит перевод тултипов по ссылке.
local nameIndex = {}
local function rebuildNameIndex()
    nameIndex = {}
    local key, entry
    for key, entry in pairs(RUQL_ACHIEVEMENTS) do
        local name = entry.originalTitle or (type(key) == "string" and key) or nil
        if name and name ~= "" then
            nameIndex[name] = key
        end
    end
end
rebuildNameIndex()

local function translateCategoryButtons(prefix, maxButtons)
    local i
    for i = 1, maxButtons do
        local label = _G[prefix .. i .. "Label"]
        if not label then break end
        local text = label.GetText and label:GetText()
        local translation = text and CATEGORY_NAMES[text]
        if translation and text ~= translation then
            label:SetText(translation)
            applyFont(label)
        end
    end
end

local function translateAchievementButtons(prefix, maxButtons)
    local i
    for i = 1, maxButtons do
        local label = _G[prefix .. i .. "Label"]
        if not label then break end
        local description = _G[prefix .. i .. "Description"]
        local text = label.GetText and label:GetText()
        local achievementKey = text and nameIndex[text]
        local achievement = achievementKey and RUQL_ACHIEVEMENTS[achievementKey]
        if achievement then
            if achievement[1] and achievement[1] ~= "" then
                label:SetText(achievement[1])
                applyFont(label)
            end
            if achievement[2] and achievement[2] ~= "" and description then
                description:SetText(achievement[2])
                applyFont(description)
            end
        elseif text and text ~= "" and RUQL_ReportAdd then
            RUQL_ReportAdd("achievements", "NAME:" .. text, {
                name = text,
                description = description and description.GetText and description:GetText(),
            })
        end
    end
end

-- До 30 категорий/ачивок с запасом — реальных кнопок в этих скролл-списках
-- меньше, цикл просто останавливается, как только очередная кнопка не найдена.
local function translateAchievementPanel()
    translateCategoryButtons("AchievementFrameCategoriesContainerButton", 30)
    translateAchievementButtons("AchievementFrameAchievementsContainerButton", 30)
    translateAchievementButtons("AchievementFrameSummaryAchievement", 10)
end

-- Панель обновляется на скролл/клик по категории/раскрытие подкатегории —
-- моментов, в которые Blizzard перерисовывает кнопки, без доступа к живому
-- клиенту точно перечислить нельзя. Поэтому вместо хука конкретной функции
-- (легко угадать неверное имя и получить тихо неработающий хук) гоняем
-- лёгкий поллинг по таймеру, только пока панель видима — тот же приём, что
-- и OnUpdate-сборщик в Report_335.lua.
local pollDriver = CreateFrame("Frame")
pollDriver:Hide()
local pollElapsed = 0
pollDriver:SetScript("OnUpdate", function(self, elapsed)
    pollElapsed = pollElapsed + elapsed
    if pollElapsed < 0.2 then return end
    pollElapsed = 0
    translateAchievementPanel()
end)

local achievementFrameHooked = false
local function hookAchievementFrame()
    if achievementFrameHooked or not AchievementFrame or not AchievementFrame.HookScript then return end
    achievementFrameHooked = true
    AchievementFrame:HookScript("OnShow", function()
        pollElapsed = 0
        translateAchievementPanel()
        pollDriver:Show()
    end)
    AchievementFrame:HookScript("OnHide", function() pollDriver:Hide() end)
    if AchievementFrame:IsVisible() then
        translateAchievementPanel()
        pollDriver:Show()
    end
end

local function showAchievementTranslation(tooltip, link)
    local achievementID = link and tonumber(string.match(link, "achievement:(%d+)"))
    if not achievementID then return end
    local achievement = RUQL_ACHIEVEMENTS[achievementID]
    if not achievement then
        if RUQL_ReportAdd and GetAchievementInfo then
            local id, name, _, _, _, _, _, description, _, _, reward = GetAchievementInfo(achievementID)
            if id then
                RUQL_ReportAdd("achievements", achievementID, { name = name, description = description, reward = reward })
            end
        end
        return
    end
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
        applyFont(region)
    end
    tooltip:Show()
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addonName)
    if event == "PLAYER_LOGIN" then
        local tooltips = { GameTooltip, ItemRefTooltip }
        local _, tooltip
        for _, tooltip in ipairs(tooltips) do
            if tooltip and hooksecurefunc then
                hooksecurefunc(tooltip, "SetHyperlink", showAchievementTranslation)
            end
        end
    end
    -- Blizzard_AchievementUI грузится по требованию (при первом открытии
    -- панели), поэтому AchievementFrame может ещё не существовать на
    -- PLAYER_LOGIN — пробуем хукнуть и на ADDON_LOADED (в т.ч. своего же
    -- ADDON_LOADED, когда порядок загрузки окажется обратным).
    hookAchievementFrame()
end)
