-- Перевод реплик NPC в чате (say/yell/emote/whisper).
RUQL_CHAT = RUQL_CHAT or {}

local EVENTS = {
    "CHAT_MSG_MONSTER_YELL",
    "CHAT_MSG_MONSTER_SAY",
    "CHAT_MSG_MONSTER_EMOTE",
    "CHAT_MSG_MONSTER_WHISPER",
    "CHAT_MSG_RAID_BOSS_EMOTE",
    "CHAT_MSG_RAID_BOSS_WHISPER",
}

local function isTranslationEnabled()
    return not RUQL_Settings or RUQL_Settings.enabled ~= false
end

local function filter(chatFrame, event, message, author, ...)
    if not message or message == "" then return false end

    local translated = isTranslationEnabled() and RUQL_CHAT[message]
    if translated then
        return false, translated, author, ...
    end

    if RUQL_ReportAdd then RUQL_ReportAdd("chat", message, { author = author, event = event }) end
    return false
end

local index, event
for index, event in ipairs(EVENTS) do
    ChatFrame_AddMessageEventFilter(event, filter)
end
