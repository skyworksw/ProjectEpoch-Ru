-- Необязательный мост в pfQuest (если он установлен): подставляет наши
-- переводы квестов в базу pfQuest, чтобы его тултипы/карта/окно журнала
-- тоже показывали текст на русском, а не только стандартный QuestLogFrame.
--
-- pfQuest хранит текст квестов в pfDB.quests["enUS"][ID] = { T=, O=, D= }
-- (T=название, O=цель, D=описание) и читает эту таблицу напрямую при каждом
-- показе — без собственного кеша копии текста. Поэтому достаточно один раз
-- на входе в игру переписать поля в уже загруженной таблице; pfQuest сам
-- подхватит изменения при следующем открытии тултипа/карты.
local function patchEntry(target, questID, quest)
    local entry = target[questID]
    if not entry then return end
    if quest[1] and quest[1] ~= "" then entry["T"] = quest[1] end
    if quest[2] and quest[2] ~= "" then entry["D"] = quest[2] end
    if quest[3] and quest[3] ~= "" then entry["O"] = quest[3] end
end

local function patchPfQuest()
    if not pfDB or not pfDB.quests or not RUQL_QUESTS then return end
    if not RUQL_Settings or not RUQL_Settings.enabled then return end

    local base = pfDB.quests["enUS"]
    local loc = pfDB.quests["loc"]

    local questID, quest
    for questID, quest in pairs(RUQL_QUESTS) do
        if type(questID) == "number" then
            if base then patchEntry(base, questID, quest) end
            if loc and loc ~= base then patchEntry(loc, questID, quest) end
        end
    end
end

local FONT_FILE = "Interface\\AddOns\\ProjectEpoch-Ru\\Fonts\\FRIZQT___CYR.ttf"

-- Трекер целей на экране (tracker.lua) — это ОТДЕЛЬНЫЙ путь показа, не через
-- pfDB: заголовок берётся живьём из self.title/self.questid и вставляется в
-- self.text форматированной строкой (с уровнем и цветным %). Патч pfDB его не
-- касается, поэтому подменяем текст уже в готовой строке — так сохраняются
-- вся раскраска и проценты прогресса, которые строит сам pfQuest.
local function translateTrackerButton(self)
    if not self or not RUQL_Settings or not RUQL_Settings.enabled then return end
    local quest = self.questid and RUQL_QUESTS[self.questid]
    if not quest or not quest[1] or quest[1] == "" then return end

    local original = self.title
    local region = self.text
    local current = original and region and region:GetText()
    if not current then return end

    local startPos, endPos = string.find(current, original, 1, true)
    if not startPos then return end

    region:SetText(string.sub(current, 1, startPos - 1) .. quest[1] .. string.sub(current, endPos + 1))

    local _, size, flags = region:GetFont()
    region:SetFont(FONT_FILE, size or 12, flags or "")
end

local function hookPfQuestTracker()
    if tracker and tracker.ButtonEvent then
        hooksecurefunc(tracker, "ButtonEvent", translateTrackerButton)
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
    patchPfQuest()
    hookPfQuestTracker()
end)
