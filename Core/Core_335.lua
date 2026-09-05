local ADDON_NAME = ...

RUQL_QUESTS = RUQL_QUESTS or {}
RUQL_TITLE_INDEX = RUQL_TITLE_INDEX or {}

local VERSION = "0.2.3"
local FONT_FILE = "Interface\\AddOns\\ProjectEpoch-Ru\\Fonts\\FRIZQT___CYR.ttf"
local FALLBACK_FONT_FILE = "Interface\\AddOns\\ProjectEpoch-Ru\\Fonts\\PTSans-Regular.ttf"
local state = {
    currentID = nil,
    currentKind = nil,
    original = {},
    pending = nil,
    elapsed = 0,
}

local raceNames = {
    Human = "человек", Orc = "орк", Dwarf = "дворф", NightElf = "ночной эльф",
    Scourge = "нежить", Tauren = "таурен", Gnome = "гном", Troll = "тролль",
    BloodElf = "эльф крови", Draenei = "дреней",
}

local classNames = {
    WARRIOR = "воин", PALADIN = "паладин", HUNTER = "охотник", ROGUE = "разбойник",
    PRIEST = "жрец", DEATHKNIGHT = "рыцарь смерти", SHAMAN = "шаман", MAGE = "маг",
    WARLOCK = "чернокнижник", DRUID = "друид",
}

local function chat(message)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cff58a6ffRUQL:|r " .. tostring(message))
    end
end

local function hashTitle(text)
    local value = 5381
    local index
    text = text or ""
    for index = 1, string.len(text) do
        value = math.fmod(value * 33 + string.byte(text, index), 4294967291)
    end
    return value
end

local function expandTokens(text)
    if not text or text == "" then return text end

    local playerName = UnitName("player") or "герой"
    local _, raceToken = UnitRace("player")
    local _, classToken = UnitClass("player")
    local female = UnitSex("player") == 3
    local raceName = raceNames[raceToken] or raceToken or "герой"
    local className = classNames[classToken] or classToken or "герой"

    text = string.gsub(text, "%$[Bb]", "\n")
    text = string.gsub(text, "%$[Nn]", playerName)
    text = string.gsub(text, "%$[Rr]", raceName)
    text = string.gsub(text, "%$[Cc]", className)
    text = string.gsub(text, "%$[Gg]([^:;]*):([^;]*);", function(male, woman)
        if female then return woman end
        return male
    end)
    text = string.gsub(text, "|3%-6%(([^,]*),([^%)]*)%)", function(male, woman)
        if female then return woman end
        return male
    end)
    return text
end

local function getText(region)
    if region and region.GetText then return region:GetText() end
    return nil
end

local function setText(region, text)
    if region and region.SetText and text and text ~= "" then
        region:SetText(expandTokens(text))
    end
end

local function applyFont(region, size, flags)
    if not region or not region.SetFont then return end
    local ok = region:SetFont(FONT_FILE, size, flags or "")
    if not ok then ok = region:SetFont(FALLBACK_FONT_FILE, size, flags or "") end
    if not ok and region.GetFont then
        local oldFont, oldSize, oldFlags = region:GetFont()
        if oldFont then region:SetFont(oldFont, oldSize or size, oldFlags or "") end
    end
end

local function translatedTitle(original)
    if not original or original == "" then return nil end
    local questID = RUQL_TITLE_INDEX[hashTitle(original)]
    local quest = questID and RUQL_QUESTS[questID]
    if quest and quest[1] and quest[1] ~= "" then return expandTokens(quest[1]) end
    return nil
end

local function translateVisibleQuestTitles()
    if not RUQL_Settings.enabled or RUQL_Settings.showOriginal then return end

    if QuestLogScrollFrame and QuestLogScrollFrame.buttons then
        local _, button
        for _, button in ipairs(QuestLogScrollFrame.buttons) do
            local index = button:GetID()
            if index and index > 0 then
                local title, _, _, _, isHeader, _, _, _, questID, displayQuestID = GetQuestLogTitle(index)
                local quest = questID and RUQL_QUESTS[questID]
                if not isHeader and quest and quest[1] then
                    local shown = expandTokens(quest[1])
                    if ENABLE_COLORBLIND_MODE == "1" then
                        local _, level = GetQuestLogTitle(index)
                        shown = "[" .. tostring(level) .. "] " .. shown
                    end
                    if displayQuestID then shown = tostring(questID) .. " - " .. shown end
                    button:SetText("  " .. shown)
                    applyFont(button, 12)
                end
            end
        end
    end

    if GetNumActiveQuests and GetNumAvailableQuests then
        local active = GetNumActiveQuests() or 0
        local available = GetNumAvailableQuests() or 0
        local index
        for index = 1, active + available do
            local button = _G["QuestTitleButton" .. index]
            local original
            if index <= active then
                original = GetActiveTitle(index)
            else
                original = GetAvailableTitle(index - active)
            end
            local title = translatedTitle(original)
            if button and title then
                button:SetFormattedText(NORMAL_QUEST_DISPLAY or "%s", title)
                applyFont(button, 13)
            end
        end
    end

    if GossipFrame and GossipFrame:IsVisible() then
        local available = { GetGossipAvailableQuests() }
        local active = { GetGossipActiveQuests() }
        local index
        for index = 1, (NUMGOSSIPBUTTONS or 32) do
            local button = _G["GossipTitleButton" .. index]
            if button and button:IsVisible() and (button.type == "Available" or button.type == "Active") then
                local values = button.type == "Available" and available or active
                local stride = button.type == "Available" and 5 or 4
                local original = values[(button:GetID() - 1) * stride + 1]
                local title = translatedTitle(original)
                if title then
                    button:SetFormattedText(NORMAL_QUEST_DISPLAY or "%s", title)
                    applyFont(button, 13)
                end
            end
        end
    end
end

local function getQuestLogID(index)
    if not index or index <= 0 then return nil end
    local _, _, _, _, _, _, _, _, questID = GetQuestLogTitle(index)
    questID = tonumber(questID)
    if questID and questID > 0 then return questID end
    return nil
end

local function findLogQuestByTitle(title)
    if not title or title == "" then return nil end
    local count = GetNumQuestLogEntries and GetNumQuestLogEntries() or 0
    local index
    for index = 1, count do
        local logTitle = GetQuestLogTitle(index)
        if logTitle == title then
            local questID = getQuestLogID(index)
            if questID then return questID end
        end
    end
    return nil
end

local function resolveQuestID()
    if type(GetQuestID) == "function" then
        local ok, questID = pcall(GetQuestID)
        questID = tonumber(questID)
        if ok and questID and questID > 0 then return questID end
    end

    if QuestLogFrame and QuestLogFrame:IsVisible() and GetQuestLogSelection then
        local questID = getQuestLogID(GetQuestLogSelection())
        if questID then return questID end
    end

    local title = GetTitleText and GetTitleText() or nil
    local questID = findLogQuestByTitle(title)
    if questID then return questID end
    if title and title ~= "" then
        questID = RUQL_TITLE_INDEX[hashTitle(title)]
        if questID then return questID end
    end
    return state.currentID
end

local function rememberOriginal(kind)
    state.original = {
        kind = kind,
        title = getText(QuestInfoTitleHeader),
        progressTitle = getText(QuestProgressTitleText),
        description = getText(QuestInfoDescriptionText),
        objectives = getText(QuestInfoObjectivesText),
        progress = getText(QuestProgressText),
        completion = getText(QuestInfoRewardText),
    }
end

local function restoreOriginal()
    local original = state.original
    if not original then return end
    setText(QuestInfoTitleHeader, original.title)
    setText(QuestProgressTitleText, original.progressTitle)
    setText(QuestInfoDescriptionText, original.description)
    setText(QuestInfoObjectivesText, original.objectives)
    setText(QuestProgressText, original.progress)
    setText(QuestInfoRewardText, original.completion)
end

local function captureMissing(questID, kind)
    if not RUQL_Settings.collectMissing then return end
    local title
    if kind == "log" and GetQuestLogSelection then
        title = GetQuestLogTitle(GetQuestLogSelection())
    else
        title = GetTitleText and GetTitleText() or nil
    end
    if not title or title == "" then title = getText(QuestInfoTitleHeader) end
    title = title or ""
    local key = questID and questID > 0 and tostring(questID) or ("TITLE:" .. title)
    local item = RUQL_Missing[key] or { id = questID or 0 }
    item.title = title
    item.npc = UnitName("npc")
    item.lastSeen = date and date("%Y-%m-%d %H:%M:%S") or nil
    if kind == "detail" then
        item.description = GetQuestText and GetQuestText() or getText(QuestInfoDescriptionText)
        item.objectives = GetObjectiveText and GetObjectiveText() or getText(QuestInfoObjectivesText)
    elseif kind == "log" then
        if GetQuestLogQuestText then
            local description, objectives = GetQuestLogQuestText()
            item.description = description or item.description
            item.objectives = objectives or item.objectives
        else
            item.description = getText(QuestInfoDescriptionText) or item.description
            item.objectives = getText(QuestInfoObjectivesText) or item.objectives
        end
    elseif kind == "progress" then
        item.progress = GetProgressText and GetProgressText() or getText(QuestProgressText)
    elseif kind == "complete" then
        item.completion = GetRewardText and GetRewardText() or getText(QuestInfoRewardText)
    end
    RUQL_Missing[key] = item
end

local function translateObjectiveLines(quest, logIndex)
    if not logIndex or not GetNumQuestLeaderBoards then return end
    local count = GetNumQuestLeaderBoards(logIndex) or 0
    local objective
    for objective = 1, count do
        local translated = quest[5 + objective]
        local region = _G["QuestLogObjective" .. objective]
        if translated and translated ~= "" and region then
            local description = GetQuestLogLeaderBoard(objective, logIndex)
            local suffix = description and string.match(description, "(:%s*%d+%s*/%s*%d+.*)$") or ""
            region:SetText(expandTokens(translated) .. suffix)
            applyFont(region, 12)
        end
    end
end

local function applyLabels()
    setText(QuestInfoRewardsHeader, "Награды")
    setText(QuestInfoItemChooseText, "Вы сможете выбрать одну из этих наград:")
    setText(QuestInfoItemReceiveText, "Вы получите:")
    setText(QuestInfoXPFrameReceiveText, "Опыт:")
    setText(QuestProgressRequiredItemsText, "Необходимые предметы:")
end

local function updateButton()
    local text = state.currentID and ("RU: " .. state.currentID) or "RU: ?"
    if RUQL_Settings.showOriginal then text = "EN: " .. (state.currentID or "?") end
    if RUQL_QuestButtonText then RUQL_QuestButtonText:SetText(text) end
    if RUQL_LogButtonText then RUQL_LogButtonText:SetText(text) end
end

local function applyTranslation(kind, forceOriginal)
    local questID = resolveQuestID()
    if questID and state.currentID and questID ~= state.currentID then
        -- Original/Russian is a per-quest viewing choice, not a global mode.
        RUQL_Settings.showOriginal = false
    end
    state.currentID = questID
    state.currentKind = kind

    local quest = questID and RUQL_QUESTS[questID] or nil
    if not quest then
        captureMissing(questID, kind)
        updateButton()
        return
    end

    if forceOriginal or not RUQL_Settings.enabled or RUQL_Settings.showOriginal then
        restoreOriginal()
        updateButton()
        return
    end

    applyFont(QuestInfoTitleHeader, 18)
    applyFont(QuestProgressTitleText, 18)
    applyFont(QuestInfoDescriptionText, 13)
    applyFont(QuestInfoObjectivesText, 13)
    applyFont(QuestProgressText, 13)
    applyFont(QuestInfoRewardText, 13)

    setText(QuestInfoTitleHeader, quest[1])
    setText(QuestProgressTitleText, quest[1])
    if kind == "detail" or kind == "log" then
        setText(QuestInfoDescriptionText, quest[2])
        setText(QuestInfoObjectivesText, quest[3])
    elseif kind == "progress" then
        setText(QuestProgressText, quest[4])
    elseif kind == "complete" then
        setText(QuestInfoRewardText, quest[5])
    end
    applyLabels()

    if kind == "log" and GetQuestLogSelection then
        translateObjectiveLines(quest, GetQuestLogSelection())
    end
    updateButton()
end

local function schedule(kind)
    state.pending = kind
    state.elapsed = 0
end

local function toggleOriginal()
    RUQL_Settings.showOriginal = not RUQL_Settings.showOriginal
    if RUQL_Settings.showOriginal then
        restoreOriginal()
        updateButton()
    else
        schedule(state.currentKind or "detail")
    end
end

local function makeButton(name, parent, point, x, y)
    if not parent or _G[name] then return end
    local button = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
    button:SetWidth(78)
    button:SetHeight(22)
    button:SetPoint(point, parent, point, x, y)
    button:SetText("RU: ?")
    button:SetScript("OnClick", toggleOriginal)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Переключить русский / оригинал")
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

local function initialize()
    RUQL_Settings = RUQL_Settings or {}
    if RUQL_Settings.enabled == nil then RUQL_Settings.enabled = true end
    if RUQL_Settings.collectMissing == nil then RUQL_Settings.collectMissing = true end
    -- Always begin a new UI session in Russian mode. The toggle is temporary.
    RUQL_Settings.showOriginal = false
    RUQL_Missing = RUQL_Missing or {}

    local questID, quest
    for questID, quest in pairs(RUQL_QUESTS) do
        if quest.originalTitle and quest.originalTitle ~= "" then
            RUQL_TITLE_INDEX[hashTitle(quest.originalTitle)] = questID
        end
    end

    makeButton("RUQL_QuestButton", QuestFrame, "TOPRIGHT", -30, -38)
    makeButton("RUQL_LogButton", QuestLogDetailFrame, "TOPRIGHT", -28, -4)
    if hooksecurefunc then
        if QuestLog_Update then hooksecurefunc("QuestLog_Update", translateVisibleQuestTitles) end
        if QuestFrameGreetingPanel_OnShow then hooksecurefunc("QuestFrameGreetingPanel_OnShow", translateVisibleQuestTitles) end
        if GossipFrameUpdate then hooksecurefunc("GossipFrameUpdate", translateVisibleQuestTitles) end
        if SelectQuestLogEntry then
            hooksecurefunc("SelectQuestLogEntry", function()
                rememberOriginal("log")
                schedule("log")
            end)
        end
        if QuestLog_UpdateQuestDetails then
            hooksecurefunc("QuestLog_UpdateQuestDetails", function()
                rememberOriginal("log")
                schedule("log")
            end)
        end
    end
    SLASH_RUQL1 = "/ruql"
    SlashCmdList.RUQL = function(message)
        message = string.lower(message or "")
        if message == "on" then
            RUQL_Settings.enabled = true
            RUQL_Settings.showOriginal = false
            schedule(state.currentKind or "detail")
            chat("перевод включен")
        elseif message == "off" then
            RUQL_Settings.enabled = false
            restoreOriginal()
            chat("перевод выключен")
        elseif message == "toggle" then
            toggleOriginal()
        elseif message == "id" then
            chat("ID текущего задания: " .. tostring(resolveQuestID() or "не определен"))
        elseif message == "missing" then
            local count = 0
            for _ in pairs(RUQL_Missing) do count = count + 1 end
            chat("собрано неизвестных заданий: " .. count)
        elseif RUQL_CollectorCommand and (string.sub(message, 1, 5) == "scan " or string.sub(message, 1, 8) == "collect ") then
            RUQL_CollectorCommand(message)
        else
            chat("v" .. VERSION .. " — /ruql on | off | toggle | id | missing | scan | collect status")
        end
    end
    local count = 0
    for _ in pairs(RUQL_QUESTS) do count = count + 1 end
    chat("загружен, база: " .. tostring(count) .. " записей. Команда /ruql")
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("QUEST_DETAIL")
frame:RegisterEvent("QUEST_PROGRESS")
frame:RegisterEvent("QUEST_COMPLETE")
frame:RegisterEvent("QUEST_LOG_UPDATE")
frame:RegisterEvent("QUEST_GREETING")
frame:RegisterEvent("GOSSIP_SHOW")
frame:SetScript("OnEvent", function(self, event, argument)
    if event == "ADDON_LOADED" then
        if argument == ADDON_NAME then initialize() end
    elseif event == "QUEST_DETAIL" then
        rememberOriginal("detail")
        schedule("detail")
    elseif event == "QUEST_PROGRESS" then
        rememberOriginal("progress")
        schedule("progress")
    elseif event == "QUEST_COMPLETE" then
        rememberOriginal("complete")
        schedule("complete")
    elseif event == "QUEST_LOG_UPDATE" and QuestLogFrame and QuestLogFrame:IsVisible() then
        rememberOriginal("log")
        schedule("log")
    elseif event == "QUEST_GREETING" or event == "GOSSIP_SHOW" then
        schedule("titles")
    end
end)

frame:SetScript("OnUpdate", function(self, elapsed)
    if not state.pending then return end
    state.elapsed = state.elapsed + elapsed
    if state.elapsed < 0.08 then return end
    local kind = state.pending
    state.pending = nil
    if kind == "titles" then
        translateVisibleQuestTitles()
    else
        applyTranslation(kind)
        translateVisibleQuestTitles()
    end
end)
