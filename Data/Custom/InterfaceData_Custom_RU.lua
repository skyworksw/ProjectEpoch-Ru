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

-- Дерево категорий (левая колонка) и та же сводка на первой вкладке.
RUQL_INTERFACE_TEXT["AchievementFrameCategoriesContainerButton1Label"] = "Сводка"
RUQL_INTERFACE_TEXT["AchievementFrameCategoriesContainerButton2Label"] = "Общее"
RUQL_INTERFACE_TEXT["AchievementFrameCategoriesContainerButton3Label"] = "Задания"
RUQL_INTERFACE_TEXT["AchievementFrameCategoriesContainerButton4Label"] = "Исследование"
RUQL_INTERFACE_TEXT["AchievementFrameCategoriesContainerButton5Label"] = "PvP"
RUQL_INTERFACE_TEXT["AchievementFrameCategoriesContainerButton6Label"] = "Подземелья и рейды"
RUQL_INTERFACE_TEXT["AchievementFrameCategoriesContainerButton7Label"] = "Профессии"
RUQL_INTERFACE_TEXT["AchievementFrameCategoriesContainerButton8Label"] = "Репутация"
RUQL_INTERFACE_TEXT["AchievementFrameCategoriesContainerButton9Label"] = "Мировые события"
RUQL_INTERFACE_TEXT["AchievementFrameCategoriesContainerButton10Label"] = "Подвиги"
RUQL_INTERFACE_TEXT["AchievementFrameCategoriesContainerButton11Label"] = "Мировые события"
RUQL_INTERFACE_TEXT["AchievementFrameCategoriesContainerButton12Label"] = "Подвиги"
RUQL_INTERFACE_TEXT["AchievementFrameCategoriesContainerButton13Label"] = "Подвиги"
RUQL_INTERFACE_TEXT["AchievementFrameCategoriesContainerButton14Label"] = "Инженерное дело"
RUQL_INTERFACE_TEXT["AchievementFrameCategoriesContainerButton15Label"] = "Кожевничество"
RUQL_INTERFACE_TEXT["AchievementFrameCategoriesContainerButton16Label"] = "Портняжное дело"
RUQL_INTERFACE_TEXT["AchievementFrameCategoriesContainerButton17Label"] = "Травничество"
RUQL_INTERFACE_TEXT["AchievementFrameCategoriesContainerButton18Label"] = "Горное дело"
RUQL_INTERFACE_TEXT["AchievementFrameCategoriesContainerButton19Label"] = "Снятие шкур"
RUQL_INTERFACE_TEXT["AchievementFrameCategoriesContainerButton20Label"] = "Репутация"

RUQL_INTERFACE_TEXT["AchievementFrameSummaryCategoriesCategory1Label"] = "Общее"
RUQL_INTERFACE_TEXT["AchievementFrameSummaryCategoriesCategory2Label"] = "Задания"
RUQL_INTERFACE_TEXT["AchievementFrameSummaryCategoriesCategory3Label"] = "Исследование"
RUQL_INTERFACE_TEXT["AchievementFrameSummaryCategoriesCategory4Label"] = "PvP"
RUQL_INTERFACE_TEXT["AchievementFrameSummaryCategoriesCategory5Label"] = "Подземелья и рейды"
RUQL_INTERFACE_TEXT["AchievementFrameSummaryCategoriesCategory7Label"] = "Репутация"
RUQL_INTERFACE_TEXT["AchievementFrameSummaryCategoriesCategory8Label"] = "Мировые события"

-- Сводка: карточки последних достижений на первой вкладке.
RUQL_INTERFACE_TEXT["AchievementFrameSummaryAchievement1Label"] = "50 рыб"
RUQL_INTERFACE_TEXT["AchievementFrameSummaryAchievement1Description"] = "Поймайте 50 предметов рыбалкой."
RUQL_INTERFACE_TEXT["AchievementFrameSummaryAchievement2Label"] = "10 уровень"
RUQL_INTERFACE_TEXT["AchievementFrameSummaryAchievement2Description"] = "Достигните 10 уровня."
RUQL_INTERFACE_TEXT["AchievementFrameSummaryAchievement3Label"] = "50 выполненных заданий"
RUQL_INTERFACE_TEXT["AchievementFrameSummaryAchievement3Description"] = "Выполните 50 заданий."
RUQL_INTERFACE_TEXT["AchievementFrameSummaryAchievement4Label"] = "Умелый подмастерье"
RUQL_INTERFACE_TEXT["AchievementFrameSummaryAchievement4Description"] = "Достигните звания подмастерья в одной из профессий."

-- Список ачивок в развёрнутой категории (названия/описания/награды).
RUQL_INTERFACE_TEXT["AchievementFrameAchievementsContainerButton1Label"] = "10 уровень"
RUQL_INTERFACE_TEXT["AchievementFrameAchievementsContainerButton1Description"] = "Достигните 10 уровня."
RUQL_INTERFACE_TEXT["AchievementFrameAchievementsContainerButton2Label"] = "Куча питомцев"
RUQL_INTERFACE_TEXT["AchievementFrameAchievementsContainerButton2Description"] = "Соберите 15 уникальных питомцев-компаньонов."
RUQL_INTERFACE_TEXT["AchievementFrameAchievementsContainerButton2HiddenDescription"] = "Соберите 15 уникальных питомцев-компаньонов."
RUQL_INTERFACE_TEXT["AchievementFrameAchievementsContainerButton2TrackedText"] = "Отслеживать"
RUQL_INTERFACE_TEXT["AchievementFrameAchievementsContainerButton3Label"] = "Кто заказывал в морду?"
RUQL_INTERFACE_TEXT["AchievementFrameAchievementsContainerButton3Description"] = "Поднимите навык владения кулаками до 300."
RUQL_INTERFACE_TEXT["AchievementFrameAchievementsContainerButton3Reward"] = "Награда — титул: Исследователь"
RUQL_INTERFACE_TEXT["AchievementFrameAchievementsContainerButton4Label"] = "Бритьё и стрижка"
RUQL_INTERFACE_TEXT["AchievementFrameAchievementsContainerButton4Description"] = "Посетите парикмахерскую и подстригитесь."
RUQL_INTERFACE_TEXT["AchievementFrameAchievementsContainerButton4Reward"] = "Награда — титул: Инженер"
RUQL_INTERFACE_TEXT["AchievementFrameAchievementsContainerButton5Label"] = "Надёжный вклад"
RUQL_INTERFACE_TEXT["AchievementFrameAchievementsContainerButton5Description"] = "Купите 7 дополнительных ячеек банка."
RUQL_INTERFACE_TEXT["AchievementFrameAchievementsContainerButton6Label"] = "Жадина"
RUQL_INTERFACE_TEXT["AchievementFrameAchievementsContainerButton6Description"] = "Выиграйте бросок «жадность» на предмет superior-качества или выше (уровень предмета 60+) с результатом 100."
RUQL_INTERFACE_TEXT["AchievementFrameAchievementsContainerButton7Label"] = "Нуждающийся"
RUQL_INTERFACE_TEXT["AchievementFrameAchievementsContainerButton7Description"] = "Выиграйте бросок «нужно» на предмет superior-качества или выше (уровень предмета 60+) с результатом 100."

-- Вкладка "Статистика": PvP и общая статистика.
RUQL_INTERFACE_TEXT["AchievementFrameStatsContainerButton1Title"] = "Сводка"
RUQL_INTERFACE_TEXT["AchievementFrameStatsContainerButton2"] = "Победы в Альтеракской долине"
RUQL_INTERFACE_TEXT["AchievementFrameStatsContainerButton3"] = "Победы на острове Гиллиджима"
RUQL_INTERFACE_TEXT["AchievementFrameStatsContainerButton4"] = "Победы на Низине Арати"
RUQL_INTERFACE_TEXT["AchievementFrameStatsContainerButton4Title"] = "Существа"
RUQL_INTERFACE_TEXT["AchievementFrameStatsContainerButton5"] = "Битвы в Ущелье Песни Войны"
RUQL_INTERFACE_TEXT["AchievementFrameStatsContainerButton6"] = "Битвы в Альтеракской долине"
RUQL_INTERFACE_TEXT["AchievementFrameStatsContainerButton7"] = "Битвы на острове Гиллиджима"
RUQL_INTERFACE_TEXT["AchievementFrameStatsContainerButton8"] = "Битвы на Низине Арати"
RUQL_INTERFACE_TEXT["AchievementFrameStatsContainerButton9"] = "Смерти в Ущелье Песни Войны"
RUQL_INTERFACE_TEXT["AchievementFrameStatsContainerButton9Title"] = "Победы над игроками"
RUQL_INTERFACE_TEXT["AchievementFrameStatsContainerButton10"] = "Смерти в Альтеракской долине"
RUQL_INTERFACE_TEXT["AchievementFrameStatsContainerButton11"] = "Смерти от Дрек'Тара"
RUQL_INTERFACE_TEXT["AchievementFrameStatsContainerButton12"] = "Смерти на Низине Арати"
RUQL_INTERFACE_TEXT["AchievementFrameStatsContainerButton13"] = "Всего смертей"
RUQL_INTERFACE_TEXT["AchievementFrameStatsContainerButton14"] = "Отменено заданий"
RUQL_INTERFACE_TEXT["AchievementFrameStatsContainerButton15"] = "В среднем заданий в день"
RUQL_INTERFACE_TEXT["AchievementFrameStatsContainerButton16"] = "Выполнено ежедневных заданий"
RUQL_INTERFACE_TEXT["AchievementFrameStatsContainerButton17"] = "Выполнено заданий"
RUQL_INTERFACE_TEXT["AchievementFrameStatsContainerButton18"] = "Матчи на Руинах Лордерона"
RUQL_INTERFACE_TEXT["AchievementFrameStatsContainerButton19"] = "Победы на Ринге Испытаний"
RUQL_INTERFACE_TEXT["AchievementFrameStatsContainerButton20"] = "Матчи на Ринге Испытаний"

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
