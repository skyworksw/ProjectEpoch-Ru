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

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", patchPfQuest)
