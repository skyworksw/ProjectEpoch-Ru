-- Перевод и сбор реплик NPC в чате (say/yell/emote/whisper).
RUQL_CHAT = RUQL_CHAT or {}
RUQL_MissingChat = RUQL_MissingChat or {}

local EVENTS = {
    "CHAT_MSG_MONSTER_YELL",
    "CHAT_MSG_MONSTER_SAY",
    "CHAT_MSG_MONSTER_EMOTE",
    "CHAT_MSG_MONSTER_WHISPER",
    "CHAT_MSG_RAID_BOSS_EMOTE",
    "CHAT_MSG_RAID_BOSS_WHISPER",
}

local function now()
    if date then return date("%Y-%m-%d %H:%M:%S") end
    return nil
end

local function isTranslationEnabled()
    return not RUQL_Settings or RUQL_Settings.enabled ~= false
end

local function isCollectEnabled()
    return not RUQL_Settings or RUQL_Settings.collectMissing ~= false
end

local function collectMissing(event, author, message)
    if not isCollectEnabled() then return end
    local entry = RUQL_MissingChat[message] or {}
    entry.author = author
    entry.event = event
    entry.lastSeen = now()
    RUQL_MissingChat[message] = entry
end

local function filter(chatFrame, event, message, author, ...)
    if not message or message == "" then return false end

    local translated = isTranslationEnabled() and RUQL_CHAT[message]
    if translated then
        return false, translated, author, ...
    end

    collectMissing(event, author, message)
    return false
end

local index, event
for index, event in ipairs(EVENTS) do
    ChatFrame_AddMessageEventFilter(event, filter)
end
