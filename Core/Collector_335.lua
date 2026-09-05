RUQL_Collected = RUQL_Collected or {}

local function message(text)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cff58a6ffRUQL Collector:|r " .. tostring(text))
    end
end

local function ensureTables()
    RUQL_Collected.version = 1
    RUQL_Collected.achievements = RUQL_Collected.achievements or {}
    RUQL_Collected.npcs = RUQL_Collected.npcs or {}
    RUQL_Collected.objects = RUQL_Collected.objects or {}
    RUQL_Collected.interface = RUQL_Collected.interface or {}
    RUQL_Collected.globals = RUQL_Collected.globals or {}
end

local function now()
    if date then return date("%Y-%m-%d %H:%M:%S") end
    return nil
end

local function zoneName()
    if GetRealZoneText then return GetRealZoneText() end
    return nil
end

local function creatureIDFromGUID(guid)
    if not guid or string.sub(guid, 1, 2) ~= "0x" then return nil end
    local high = string.sub(guid, 3, 6)
    if high ~= "F130" and high ~= "F140" and high ~= "F150" then return nil end
    return tonumber(string.sub(guid, 7, 12), 16)
end

function RUQL_CollectUnit(unit)
    ensureTables()
    if not UnitExists or not UnitExists(unit) then return end
    if UnitIsPlayer and UnitIsPlayer(unit) then return end
    local guid = UnitGUID and UnitGUID(unit)
    local creatureID = creatureIDFromGUID(guid)
    local name = UnitName and UnitName(unit)
    if not creatureID or creatureID <= 0 or not name then return end

    local item = RUQL_Collected.npcs[creatureID] or {}
    item.name = item.name or name
    item.level = item.level or (UnitLevel and UnitLevel(unit))
    item.classification = item.classification or (UnitClassification and UnitClassification(unit))
    item.zone = item.zone or zoneName()
    item.lastSeen = now()
    RUQL_Collected.npcs[creatureID] = item
end

function RUQL_CollectItem(itemID, originalName)
    ensureTables()
    RUQL_Collected.items = RUQL_Collected.items or {}
    local item = RUQL_Collected.items[itemID] or {}
    item.name = item.name or originalName
    item.lastSeen = now()
    RUQL_Collected.items[itemID] = item
end

function RUQL_CollectSpell(spellID, originalName, originalRank)
    ensureTables()
    RUQL_Collected.spells = RUQL_Collected.spells or {}
    local spell = RUQL_Collected.spells[spellID] or {}
    spell.name = spell.name or originalName
    spell.rank = spell.rank or originalRank
    spell.lastSeen = now()
    RUQL_Collected.spells[spellID] = spell
end

function RUQL_CollectObject(originalName)
    ensureTables()
    if not originalName or originalName == "" then return end
    local zone = zoneName() or "?"
    local key = zone .. "::" .. originalName
    local object = RUQL_Collected.objects[key] or {}
    object.name = object.name or originalName
    object.zone = object.zone or zone
    object.lastSeen = now()
    RUQL_Collected.objects[key] = object
end

local function collectAchievement(achievementID)
    ensureTables()
    achievementID = tonumber(achievementID)
    if not achievementID or achievementID <= 0 or not GetAchievementInfo then return false end
    local id, name, points, completed, month, day, year, description, flags, icon, reward = GetAchievementInfo(achievementID)
    if not id then return false end

    local achievement = RUQL_Collected.achievements[id] or {}
    achievement.name = achievement.name or name
    achievement.description = achievement.description or description
    achievement.reward = achievement.reward or reward
    achievement.points = points
    achievement.lastSeen = now()
    achievement.criteria = achievement.criteria or {}

    if GetAchievementNumCriteria and GetAchievementCriteriaInfo then
        local count = GetAchievementNumCriteria(id) or 0
        local index
        for index = 1, count do
            local criterion, criterionType, criterionDone, quantity, required, character, criterionFlags, assetID = GetAchievementCriteriaInfo(id, index)
            achievement.criteria[index] = {
                name = criterion,
                required = required,
                assetID = assetID,
            }
        end
    end
    RUQL_Collected.achievements[id] = achievement
    return true
end

local function scanAchievements()
    if not GetCategoryList and LoadAddOn then pcall(LoadAddOn, "Blizzard_AchievementUI") end
    if not GetCategoryList or not GetCategoryNumAchievements then
        message("API достижений недоступен")
        return
    end

    local categories = GetCategoryList()
    if type(categories) ~= "table" then categories = { GetCategoryList() } end
    local scanned = 0
    local _, categoryID
    for _, categoryID in ipairs(categories) do
        local count = GetCategoryNumAchievements(categoryID) or 0
        local index
        for index = 1, count do
            local achievementID = GetAchievementInfo(categoryID, index)
            if collectAchievement(achievementID) then scanned = scanned + 1 end
        end
    end
    message("собрано достижений: " .. scanned)
end

local function scanInterface()
    ensureTables()
    local scanned = 0
    local name, object
    for name, object in pairs(_G) do
        local objectType = type(object)
        if type(name) == "string" and string.sub(name, 1, 5) ~= "RUQL_"
            and (objectType == "table" or objectType == "userdata") and object.GetText then
            local ok, text = pcall(object.GetText, object)
            if ok and type(text) == "string" and text ~= "" and string.len(text) <= 1000 then
                if not RUQL_Collected.interface[name] then
                    RUQL_Collected.interface[name] = text
                    scanned = scanned + 1
                end
            end
        end
    end
    message("новых именованных элементов интерфейса: " .. scanned)
end

local function scanGlobals()
    ensureTables()
    local scanned = 0
    local name, value
    for name, value in pairs(_G) do
        if type(name) == "string" and type(value) == "string"
            and string.match(name, "^[A-Z][A-Z0-9_]+$")
            and string.len(value) > 0 and string.len(value) <= 1000 then
            if not RUQL_Collected.globals[name] then
                RUQL_Collected.globals[name] = value
                scanned = scanned + 1
            end
        end
    end
    message("новых глобальных строк: " .. scanned)
end

local function tableCount(value)
    local count = 0
    if value then for _ in pairs(value) do count = count + 1 end end
    return count
end

function RUQL_CollectorCommand(command)
    ensureTables()
    command = string.lower(command or "")
    if command == "scan achievements" then
        scanAchievements()
    elseif command == "scan interface" then
        scanInterface()
    elseif command == "scan globals" then
        scanGlobals()
    elseif command == "collect status" then
        message(
            "достижения=" .. tableCount(RUQL_Collected.achievements)
            .. ", NPC=" .. tableCount(RUQL_Collected.npcs)
            .. ", объекты=" .. tableCount(RUQL_Collected.objects)
            .. ", предметы=" .. tableCount(RUQL_Collected.items)
            .. ", заклинания=" .. tableCount(RUQL_Collected.spells)
            .. ", интерфейс=" .. tableCount(RUQL_Collected.interface)
            .. ", globals=" .. tableCount(RUQL_Collected.globals)
        )
    else
        message("/ruql scan achievements | interface | globals; /ruql collect status")
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
frame:RegisterEvent("GOSSIP_SHOW")
frame:RegisterEvent("QUEST_DETAIL")
frame:RegisterEvent("ACHIEVEMENT_EARNED")
frame:SetScript("OnEvent", function(self, event, argument)
    if event == "ADDON_LOADED" then
        if argument == "ProjectEpoch-Ru" then ensureTables() end
    elseif event == "PLAYER_TARGET_CHANGED" then
        RUQL_CollectUnit("target")
    elseif event == "UPDATE_MOUSEOVER_UNIT" then
        RUQL_CollectUnit("mouseover")
    elseif event == "GOSSIP_SHOW" or event == "QUEST_DETAIL" then
        RUQL_CollectUnit("npc")
    elseif event == "ACHIEVEMENT_EARNED" then
        collectAchievement(argument)
    end
end)
