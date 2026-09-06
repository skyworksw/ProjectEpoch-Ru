-- Единая точка сбора "непереведённого" контента и окно отчёта для игрока.
-- Игрок сам решает, когда открыть отчёт (иконка на миникарте) и когда его отправить.
RUQL_Report = RUQL_Report or {}

local ADDON_TITLE = "ProjectEpoch-Ru"
local FONT_FILE = "Interface\\AddOns\\ProjectEpoch-Ru\\Fonts\\FRIZQT___CYR.ttf"

local CATEGORIES = {
    { key = "quests", label = "Квесты" },
    { key = "items", label = "Предметы" },
    { key = "spells", label = "Заклинания/Таланты" },
    { key = "achievements", label = "Ачивки" },
    { key = "chat", label = "Диалоги NPC" },
    { key = "npcs", label = "NPC" },
    { key = "objects", label = "Объекты" },
    { key = "interface", label = "Интерфейс" },
    { key = "zones", label = "Зоны" },
    { key = "globals", label = "Глобальные строки" },
}

local function now()
    if date then return date("%Y-%m-%d %H:%M:%S") end
    return nil
end

local function chat(text)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cff58a6ffRUQL Отчёт:|r " .. tostring(text))
    end
end

local function ensureTables()
    RUQL_Report.version = 1
    local _, category
    for _, category in ipairs(CATEGORIES) do
        RUQL_Report[category.key] = RUQL_Report[category.key] or {}
    end
end
ensureTables()

-- Единый API для записи "непереведённого" из любого модуля аддона.
-- fields заполняет отсутствующие поля записи и не перезаписывает уже известные.
function RUQL_ReportAdd(categoryKey, key, fields)
    if not key then return end
    ensureTables()
    local bucket = RUQL_Report[categoryKey]
    if not bucket then return end
    local entry = bucket[key] or {}
    local field, value
    for field, value in pairs(fields or {}) do
        if entry[field] == nil and value ~= nil then entry[field] = value end
    end
    entry.lastSeen = now()
    bucket[key] = entry
end

function RUQL_ReportClear()
    RUQL_Report = {}
    ensureTables()
    chat("отчёт очищен")
end

local function tableCount(value)
    local count = 0
    if value then local _ for _ in pairs(value) do count = count + 1 end end
    return count
end

local function containsCyrillic(text)
    local i
    for i = 1, string.len(text) do
        local byte = string.byte(text, i)
        if byte == 208 or byte == 209 then return true end
    end
    return false
end

-- Отсеиваем то, что заведомо не текст для перевода: уже переведённое
-- (содержит кириллицу) и чисто цифровые/служебные значения (хоткеи,
-- время, счётчики вида "0/25") — иначе скан тонет в шуме динамических чисел.
local function looksTranslatable(text)
    if containsCyrillic(text) then return false end
    if string.len(text) < 2 then return false end
    if not string.find(text, "%a") then return false end
    return true
end

-- Название кнопки панели действий (ActionButton11Name, MultiBarRightButton8Name
-- и т.д.) — это имя МАКРОСА игрока в этом слоте, а не текст интерфейса.
-- Переводить тут нечего, а шум от "/reload" и подобного только мешает отчёту.
local function isActionButtonMacroName(name)
    return string.find(name, "Button%d+Name$") ~= nil
end

-- Интерфейс не имеет единой точки "перевода нет" как квесты/предметы, поэтому
-- сканируется по явному запросу игрока (кнопка в окне отчёта), а не постоянно в фоне.
local function scanVisibleInterface()
    ensureTables()
    local bucket = RUQL_Report.interface
    local scanned = 0
    local name, object
    for name, object in pairs(_G) do
        if type(name) == "string" and string.sub(name, 1, 5) ~= "RUQL_"
            and not isActionButtonMacroName(name)
            and type(object) == "table" and object.GetText and object.IsVisible then
            local okVisible, visible = pcall(object.IsVisible, object)
            if okVisible and visible and not (RUQL_INTERFACE_TEXT and RUQL_INTERFACE_TEXT[name]) then
                local okText, text = pcall(object.GetText, object)
                if okText and type(text) == "string" and text ~= "" and string.len(text) <= 500
                    and looksTranslatable(text) and not bucket[name] then
                    bucket[name] = { text = text, lastSeen = now() }
                    scanned = scanned + 1
                end
            end
        end
    end
    return scanned
end

-- Тексты кнопок/лейблов интерфейса ловятся через видимые FontString (см. выше),
-- но часть текста клиент хранит как глобальные строковые константы
-- (ACCEPT, DECLINE, ERR_*, и т.д.) и подставляет их в код напрямую, без
-- отдельного видимого текстового региона на экране. Такие строки сканируем
-- отдельно — по всей таблице _G, а не только по видимым фреймам.
--
-- _G в клиенте WoW — это десятки тысяч записей (все фреймы, все переменные
-- всех аддонов, вся встроенная таблица строк клиента). Проход по ней целиком
-- за один тик легко превышает лимит времени выполнения Lua-скрипта в WoW и
-- подвешивает клиент. Поэтому сканируем маленькими порциями через OnUpdate:
-- каждый кадр обрабатываем не больше GLOBAL_SCAN_BATCH ключей и продолжаем
-- с того места, где остановились, пока не пройдём всю таблицу.
local GLOBAL_SCAN_BATCH = 400

local function scanGlobalStringsStep(bucket, key)
    local processed = 0
    local scanned = 0
    while processed < GLOBAL_SCAN_BATCH do
        local ok, nextKey, value = pcall(next, _G, key)
        if not ok then
            -- _G изменилась под нами (частая ситуация в WoW) — останавливаемся
            -- на достигнутом, а не рискуем зациклиться на невалидном ключе.
            return nil, scanned
        end
        key = nextKey
        if key == nil then
            return nil, scanned
        end
        if type(key) == "string" and type(value) == "string"
            and string.find(key, "^%u[%u%d_]*$")
            and not (RUQL_GLOBAL_STRINGS and RUQL_GLOBAL_STRINGS[key])
            and string.len(value) <= 200 and looksTranslatable(value)
            and not bucket[key] then
            bucket[key] = { text = value, lastSeen = now() }
            scanned = scanned + 1
        end
        processed = processed + 1
    end
    return key, scanned
end

-- Каждая запись форматируется в несколько строк: заголовок + вложенные
-- строки с полным оригинальным текстом (описание/цель/сырой тултип и т.д.),
-- чтобы разработчик мог переводить прямо по отчёту, без доступа к серверной БД.
local function appendField(out, label, value)
    if not value or value == "" then return end
    table.insert(out, "    " .. label .. ":")
    local line
    for line in string.gmatch(value .. "\n", "([^\n]*)\n") do
        table.insert(out, "      " .. line)
    end
end

local function formatEntry(categoryKey, key, entry, out)
    if categoryKey == "quests" then
        table.insert(out, "  " .. tostring(key) .. " — " .. (entry.title or "?"))
        appendField(out, "Описание", entry.description)
        appendField(out, "Цель", entry.objectives)
        appendField(out, "Прогресс", entry.progress)
        appendField(out, "Завершение", entry.completion)
        appendField(out, "Строки цели без чисел (нужны quest[6], quest[7]...)", entry.objectiveLines)
    elseif categoryKey == "items" then
        table.insert(out, "  " .. tostring(key) .. " — " .. (entry.name or "?"))
        appendField(out, "Тултип целиком", entry.raw)
    elseif categoryKey == "spells" then
        local rank = entry.rank and entry.rank ~= "" and (" (" .. entry.rank .. ")") or ""
        table.insert(out, "  " .. tostring(key) .. " — " .. (entry.name or "?") .. rank)
        appendField(out, "Тултип целиком", entry.raw)
    elseif categoryKey == "achievements" then
        table.insert(out, "  " .. tostring(key) .. " — " .. (entry.name or "?"))
        appendField(out, "Описание", entry.description)
        appendField(out, "Награда", entry.reward)
    elseif categoryKey == "chat" then
        table.insert(out, "  " .. (entry.author or "?") .. ": \"" .. tostring(key) .. "\"")
    elseif categoryKey == "npcs" then
        table.insert(out, "  " .. tostring(key) .. " — " .. (entry.name or "?") .. " (" .. (entry.zone or "?") .. ")")
        appendField(out, "Подзаголовок", entry.subtitle)
    elseif categoryKey == "objects" then
        table.insert(out, "  " .. (entry.name or tostring(key)) .. " (" .. (entry.zone or "?") .. ")")
    elseif categoryKey == "interface" then
        table.insert(out, "  " .. tostring(key) .. " — \"" .. (entry.text or "") .. "\"")
    elseif categoryKey == "zones" then
        table.insert(out, "  " .. tostring(key))
    elseif categoryKey == "globals" then
        table.insert(out, "  " .. tostring(key) .. " = \"" .. (entry.text or "") .. "\"")
    else
        table.insert(out, "  " .. tostring(key))
    end
end

-- Категория "globals" за долгую игровую сессию накапливает тысячи записей
-- (реально наблюдалось 8000+, ~1 МБ текста). EditBox:SetText на клиенте
-- 3.3.5 с текстом такого размера (и тем более на 8000+ строк, из-за
-- SetHeight под них) подвешивает клиент намертво — именно это происходило
-- при клике на кнопку миникарты 2026-09-06. Полные данные никуда не
-- деваются — они всегда лежат в SavedVariables/ProjectEpoch-Ru.lua на диске;
-- в окно отчёта попадает только ограниченное превью.
local MAX_PREVIEW_ENTRIES = 200

local function buildReportText()
    ensureTables()
    local lines = {}
    table.insert(lines, ADDON_TITLE .. " — отчёт о непереведённом (" .. tostring(now() or "?") .. ")")
    local _, category
    for _, category in ipairs(CATEGORIES) do
        local bucket = RUQL_Report[category.key]
        local count = tableCount(bucket)
        table.insert(lines, "")
        table.insert(lines, category.label .. " (" .. count .. "):")
        if count == 0 then
            table.insert(lines, "  —")
        else
            local key, entry
            local shown = 0
            for key, entry in pairs(bucket) do
                if shown >= MAX_PREVIEW_ENTRIES then
                    table.insert(lines, "  ... и ещё " .. (count - shown)
                        .. " (полный список — в файле WTF/Account/.../SavedVariables/ProjectEpoch-Ru.lua)")
                    break
                end
                formatEntry(category.key, key, entry, lines)
                shown = shown + 1
            end
        end
    end
    return table.concat(lines, "\n")
end

local function applyFont(region, size)
    if not region then return end
    if not region.SetFont and region.GetFontString then region = region:GetFontString() end
    if not region or not region.SetFont then return end
    region:SetFont(FONT_FILE, size or 12, "")
end

-- WoW 3.3.5 конвертирует текст EditBox в системную ANSI-кодировку при Ctrl+C.
-- На клиенте без русской локали ОС кириллица необратимо превращается в "?"
-- ещё до попадания в буфер обмена. Base64 — чистый ASCII, который эту
-- конвертацию переживает в любой кодировке; разработчик раскодирует его сам.
local BASE64_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function base64Encode(data)
    local result = {}
    local length = string.len(data)
    local i = 1
    while i <= length do
        local b1 = string.byte(data, i)
        local b2 = string.byte(data, i + 1)
        local b3 = string.byte(data, i + 2)
        local n = b1 * 65536 + (b2 or 0) * 256 + (b3 or 0)
        local c1 = math.floor(n / 262144) % 64
        local c2 = math.floor(n / 4096) % 64
        local c3 = math.floor(n / 64) % 64
        local c4 = n % 64
        table.insert(result, string.sub(BASE64_CHARS, c1 + 1, c1 + 1))
        table.insert(result, string.sub(BASE64_CHARS, c2 + 1, c2 + 1))
        table.insert(result, b2 and string.sub(BASE64_CHARS, c3 + 1, c3 + 1) or "=")
        table.insert(result, b3 and string.sub(BASE64_CHARS, c4 + 1, c4 + 1) or "=")
        i = i + 3
    end
    return table.concat(result)
end

local reportFrame

local function createReportFrame()
    local frame = CreateFrame("Frame", "RUQL_ReportFrame", UIParent)
    frame:SetWidth(640)
    frame:SetHeight(420)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })
    tinsert(UISpecialFrames, "RUQL_ReportFrame")

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -16)
    title:SetText(ADDON_TITLE .. " — отчёт о непереведённом")
    applyFont(title, 16)

    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", -4, -4)

    local scrollFrame = CreateFrame("ScrollFrame", "RUQL_ReportScrollFrame", frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 16, -44)
    scrollFrame:SetPoint("BOTTOMRIGHT", -34, 76)

    local editBox = CreateFrame("EditBox", nil, scrollFrame)
    editBox:SetMultiLine(true)
    editBox:SetWidth(572)
    editBox:SetHeight(300)
    editBox:SetAutoFocus(false)
    applyFont(editBox, 12)
    editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    scrollFrame:SetScrollChild(editBox)

    local hint = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("BOTTOMLEFT", 16, 52)
    hint:SetPoint("BOTTOMRIGHT", -16, 52)
    hint:SetJustifyH("LEFT")
    hint:SetText("Это предпросмотр (до " .. MAX_PREVIEW_ENTRIES .. " записей на категорию — иначе клиент виснет). Нажми «Копировать» — текст закодируется в Base64 (WoW иначе портит кириллицу при Ctrl+C) и выделится для отправки разработчику. Полные данные всегда доступны в SavedVariables/ProjectEpoch-Ru.lua.")
    applyFont(hint, 11)

    local reportText = ""

    -- Верхняя граница на высоту EditBox — даже с MAX_PREVIEW_ENTRIES по всем
    -- категориям высота не должна улетать в десятки тысяч пикселей (именно
    -- это подвешивало клиент раньше).
    local function setEditBoxText(text)
        local _, lineBreaks = string.gsub(text, "\n", "\n")
        editBox:SetHeight(math.min(6000, math.max(300, (lineBreaks + 1) * 14)))
        editBox:SetText(text)
        editBox:SetCursorPosition(0)
    end

    local function refresh()
        reportText = buildReportText()
        setEditBoxText(reportText)
    end
    frame.refresh = refresh

    local copyButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    copyButton:SetWidth(110)
    copyButton:SetHeight(22)
    copyButton:SetPoint("BOTTOMLEFT", 16, 16)
    copyButton:SetText("Копировать")
    applyFont(copyButton, 12)
    copyButton:SetScript("OnClick", function()
        setEditBoxText(base64Encode(reportText))
        editBox:SetFocus()
        editBox:HighlightText()
        chat("текст закодирован и выделен — жми Ctrl+C и присылай разработчику")
    end)

    local rescanButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    rescanButton:SetWidth(170)
    rescanButton:SetHeight(22)
    rescanButton:SetPoint("LEFT", copyButton, "RIGHT", 8, 0)
    rescanButton:SetText("Сканировать интерфейс")
    applyFont(rescanButton, 12)
    rescanButton:SetScript("OnClick", function()
        local scanned = scanVisibleInterface()
        refresh()
        chat("новых элементов интерфейса: " .. scanned)
    end)

    local globalsButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    globalsButton:SetWidth(170)
    globalsButton:SetHeight(22)
    globalsButton:SetPoint("LEFT", rescanButton, "RIGHT", 8, 0)
    globalsButton:SetText("Сканировать строки клиента")
    applyFont(globalsButton, 12)

    local globalScanDriver = CreateFrame("Frame")
    globalScanDriver:Hide()
    local globalScanKey, globalScanTotal

    globalScanDriver:SetScript("OnUpdate", function()
        ensureTables()
        local bucket = RUQL_Report.globals
        local nextKey, scanned = scanGlobalStringsStep(bucket, globalScanKey)
        globalScanTotal = globalScanTotal + scanned
        globalScanKey = nextKey
        if not nextKey then
            globalScanDriver:Hide()
            globalsButton:Enable()
            globalsButton:SetText("Сканировать строки клиента")
            refresh()
            chat("новых глобальных строк: " .. globalScanTotal)
        end
    end)

    globalsButton:SetScript("OnClick", function()
        if globalScanDriver:IsShown() then return end
        globalScanKey, globalScanTotal = nil, 0
        globalsButton:Disable()
        globalsButton:SetText("Сканирование…")
        globalScanDriver:Show()
    end)

    local clearButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    clearButton:SetWidth(110)
    clearButton:SetHeight(22)
    clearButton:SetPoint("BOTTOMRIGHT", -16, 16)
    clearButton:SetText("Очистить")
    applyFont(clearButton, 12)
    clearButton:SetScript("OnClick", function()
        RUQL_ReportClear()
        refresh()
    end)

    frame:Hide()
    return frame
end

function RUQL_ToggleReportFrame()
    if not reportFrame then reportFrame = createReportFrame() end
    if reportFrame:IsShown() then
        reportFrame:Hide()
    else
        reportFrame.refresh()
        reportFrame:Show()
    end
end

local function createMinimapButton()
    local button = CreateFrame("Button", "RUQL_MinimapButton", Minimap)
    button:SetWidth(31)
    button:SetHeight(31)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(8)
    button:RegisterForClicks("LeftButtonUp")
    button:RegisterForDrag("LeftButton")

    local overlay = button:CreateTexture(nil, "OVERLAY")
    overlay:SetWidth(53)
    overlay:SetHeight(53)
    overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    overlay:SetPoint("TOPLEFT")

    local icon = button:CreateTexture(nil, "BACKGROUND")
    icon:SetWidth(18)
    icon:SetHeight(18)
    icon:SetTexture("Interface\\Icons\\INV_Misc_Note_01")
    icon:SetPoint("CENTER", 0, 1)

    local function updatePosition()
        local angle = math.rad(RUQL_Settings.minimapAngle or 215)
        local radius = 80
        button:ClearAllPoints()
        button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
    end

    button:SetScript("OnDragStart", function(self) self.dragging = true end)
    button:SetScript("OnDragStop", function(self) self.dragging = false end)
    button:SetScript("OnUpdate", function(self)
        if not self.dragging then return end
        local mx, my = Minimap:GetCenter()
        local px, py = GetCursorPosition()
        local scale = Minimap:GetEffectiveScale()
        px, py = px / scale, py / scale
        RUQL_Settings.minimapAngle = math.deg(math.atan2(py - my, px - mx))
        updatePosition()
    end)

    button:SetScript("OnClick", function() RUQL_ToggleReportFrame() end)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(ADDON_TITLE)
        GameTooltip:AddLine("Отчёт о непереведённом контенте", 1, 1, 1)
        GameTooltip:AddLine("ЛКМ — открыть/закрыть, перетащить — переместить", 0.8, 0.8, 0.8)
        local tooltipName = GameTooltip:GetName()
        local line
        for line = 1, GameTooltip:NumLines() do
            applyFont(_G[tooltipName .. "TextLeft" .. line], 12)
        end
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)

    updatePosition()
    return button
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
    RUQL_Settings = RUQL_Settings or {}
    ensureTables()
    createMinimapButton()
end)
