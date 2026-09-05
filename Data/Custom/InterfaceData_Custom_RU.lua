-- Перевод именованных элементов интерфейса.
RUQL_INTERFACE_TEXT = RUQL_INTERFACE_TEXT or {}
RUQL_GLOBAL_STRINGS = RUQL_GLOBAL_STRINGS or {}

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
