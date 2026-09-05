-- Перевод именованных элементов интерфейса.
RUQL_INTERFACE_TEXT = RUQL_INTERFACE_TEXT or {}
RUQL_GLOBAL_STRINGS = RUQL_GLOBAL_STRINGS or {}

-- Project Epoch: текст собран отчётом аддона 2026-09-05.
RUQL_INTERFACE_TEXT["AchievementFrameTab1Text"] = "Достижения"
RUQL_INTERFACE_TEXT["AchievementFrameTab1"] = "Достижения"
RUQL_INTERFACE_TEXT["AchievementFrameTab2Text"] = "Статистика"
RUQL_INTERFACE_TEXT["AchievementFrameTab2"] = "Статистика"
RUQL_INTERFACE_TEXT["QuestLogFrameShowMapButtonText"] = "Показать карту"
RUQL_INTERFACE_TEXT["QuestLogFrameTrackButton"] = "Отслеживать"
RUQL_INTERFACE_TEXT["QuestLogFrameTrackButtonText"] = "Отслеживать"
RUQL_INTERFACE_TEXT["QuestLogFrameAbandonButton"] = "Отказаться"
RUQL_INTERFACE_TEXT["QuestLogFrameAbandonButtonText"] = "Отказаться"
RUQL_INTERFACE_TEXT["QuestLogFrameCancelButton"] = "Закрыть"
RUQL_INTERFACE_TEXT["QuestLogFrameCancelButtonText"] = "Закрыть"
RUQL_INTERFACE_TEXT["QuestLogFramePushQuestButton"] = "Поделиться"
RUQL_INTERFACE_TEXT["QuestLogFramePushQuestButtonText"] = "Поделиться"
RUQL_INTERFACE_TEXT["QuestLogTitleText"] = "Список заданий"
RUQL_INTERFACE_TEXT["ChatFrame1Tab"] = "Общий"
RUQL_INTERFACE_TEXT["ChatFrame1TabText"] = "Общий"
RUQL_INTERFACE_TEXT["ChatFrame2Tab"] = "Боевой журнал"
RUQL_INTERFACE_TEXT["ChatFrame2TabText"] = "Боевой журнал"

-- Примеры:
-- RUQL_INTERFACE_TEXT["QuestFrameAcceptButton"] = "Принять"
-- RUQL_GLOBAL_STRINGS["ACCEPT"] = "Принять"

-- ВАЖНО: не переопределяйте здесь строки тултипа предметов вроде
-- ITEM_BIND_ON_PICKUP / ITEM_UNIQUE / ITEM_SPELL_TRIGGER_ONUSE. Такое
-- переопределение не проходит через applyFont() и рисуется client-side
-- стандартным Friz Quadrata TT без кириллических глифов — русский текст
-- превращается в "???"/тофу-квадраты. Перевод этих строк сделан отдельно,
-- построчной заменой внутри тултипа с применением кириллического шрифта —
-- см. Core/Tooltips_335.lua (translateBoilerplateLines).
