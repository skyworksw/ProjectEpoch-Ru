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

-- Project Epoch: текст собран отчётом аддона 2026-09-06.
-- Остальные элементы из этого же отчёта (PlayerName, PetName,
-- MinimapZoneText, TargetFrameTextureFrameName, MultiBarRightButton8Name)
-- сюда намеренно НЕ добавлены: applyInterfaceTranslation() применяет эту
-- таблицу один раз при входе и перезаписывает регион БЕЗУСЛОВНО — а это всё
-- динамические значения (имя игрока/питомца, название текущей зоны, имя
-- цели, текст макроса игрока), которые меняются от игрока к игроку и от
-- момента к моменту. Захардкодить их — значит показать чужие данные
-- ("Skywork", "Goldshire" и т.д.) всем остальным игрокам аддона.
RUQL_INTERFACE_TEXT["ContainerFrame1Name"] = "Рюкзак"

-- Панель достижений (AchievementFrame) — дерево категорий, сводка и статистика.
-- Собрано сканом интерфейса 2026-09-05. Названия/описания самих ачивок —
-- перевод по смыслу, не сверялся с официальной ruRU-локализацией Blizzard.
RUQL_INTERFACE_TEXT["AchievementFrameFilterDropDownText"] = "Все"
RUQL_INTERFACE_TEXT["AchievementFrameHeaderTitle"] = "Очки достижений"
RUQL_INTERFACE_TEXT["AchievementFrameSummaryCategoriesHeaderTitle"] = "Обзор прогресса"
RUQL_INTERFACE_TEXT["AchievementFrameSummaryCategoriesStatusBarTitle"] = "Получено достижений"
RUQL_INTERFACE_TEXT["AchievementFrameSummaryAchievementsHeaderTitle"] = "Последние достижения"

-- 2026-09-06: убраны ключи AchievementFrameCategoriesContainerButtonN*,
-- AchievementFrameSummaryAchievementN* и AchievementFrameAchievementsContainerButtonN*.
-- Все три набора били по НОМЕРУ строки в переиспользуемом (recycled)
-- скролл-списке, а не по стабильному ID категории/ачивки. Номер строки
-- меняется при скролле, разворачивании категории (проф. подкатегории) и
-- у каждого игрока свой набор "последних ачивок" — поэтому одна и та же
-- запись то не применялась (как на скрине с "Journeyman in First Aid"),
-- то штамповала ЧУЖОЙ текст поверх другой ачивки/категории. Это видно и по
-- самим старым данным: кнопки 9/11 обе были "Мировые события", а 10/12/13 —
-- все три "Подвиги" — то есть уже тогда номера "плавали" между сессиями.
-- Правильный fix — переводить по achievementID/categoryID (см. RUQL_ACHIEVEMENTS
-- в Achievements_335.lua, там это уже сделано для тултипов), а не по индексу
-- в списке. Сама панель ачивок (не тултип) по ID пока не переводится.
RUQL_INTERFACE_TEXT["AchievementFrameSummaryCategoriesCategory1Label"] = "Общее"
RUQL_INTERFACE_TEXT["AchievementFrameSummaryCategoriesCategory2Label"] = "Задания"
RUQL_INTERFACE_TEXT["AchievementFrameSummaryCategoriesCategory3Label"] = "Исследование"
RUQL_INTERFACE_TEXT["AchievementFrameSummaryCategoriesCategory4Label"] = "PvP"
RUQL_INTERFACE_TEXT["AchievementFrameSummaryCategoriesCategory5Label"] = "Подземелья и рейды"
RUQL_INTERFACE_TEXT["AchievementFrameSummaryCategoriesCategory6Label"] = "Профессии"
RUQL_INTERFACE_TEXT["AchievementFrameSummaryCategoriesCategory7Label"] = "Репутация"
RUQL_INTERFACE_TEXT["AchievementFrameSummaryCategoriesCategory8Label"] = "Мировые события"
-- ^ Эти 8 — единственные из всей панели, где номер стабилен: это НЕ
-- переиспользуемый скролл-список, а фиксированная сетка "Обзор прогресса"
-- ровно из 8 карточек на вкладке Summary (не скроллится, не разворачивается).
-- Отсюда и заметная сначала находка: карточка "Profession" осталась на
-- английском, потому что #6 в этом фиксированном наборе просто забыли добавить.

-- Вкладка "Статистика" (AchievementFrameStatsContainerButtonN) убрана по той
-- же причине, что и категории/ачивки выше — это тоже переиспользуемый
-- скролл-список, а не фиксированный набор. Видно прямо в старых данных:
-- кнопка 4 одновременно значилась и листом "Победы на Низине Арати", и
-- заголовком раздела "Существа"; кнопка 9 — и "Смерти в Ущелье Песни Войны",
-- и заголовком "Победы над игроками". Значит номер кнопки плавает между
-- сессиями/скроллом так же, как и везде выше.

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
