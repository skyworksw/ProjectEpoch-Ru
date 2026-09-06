-- Названия стандартных зон/континентов/столиц WotLK 3.3.5a.
-- Ключ — английское название, ровно как его возвращает клиент
-- (GetZoneText/GetSubZoneText/GetRealZoneText/GetMinimapZoneText).
-- Подзоны и инстансы, которых здесь ещё нет, попадают в отчёт аддона
-- (категория "Зоны") при первом посещении — оттуда их можно перенести сюда.
RUQL_ZONES = RUQL_ZONES or {}

-- Проверено по официальной ruRU-локализации (заголовки страниц зон на
-- wowhead.com/wotlk/ru/zone=...). Континенты сверены дополнительно по
-- страницам-спискам zones/<continent>.

-- ============================================================
-- Continents
-- ============================================================
RUQL_ZONES["Eastern Kingdoms"] = "Восточные королевства"
RUQL_ZONES["Kalimdor"] = "Калимдор"
RUQL_ZONES["Outland"] = "Запределье"
RUQL_ZONES["Northrend"] = "Нордскол"

-- ============================================================
-- Eastern Kingdoms - zones
-- ============================================================
RUQL_ZONES["Elwynn Forest"] = "Элвиннский лес"
RUQL_ZONES["Westfall"] = "Западный Край"
RUQL_ZONES["Redridge Mountains"] = "Красногорье"
RUQL_ZONES["Duskwood"] = "Сумеречный лес"
RUQL_ZONES["Stranglethorn Vale"] = "Тернистая долина"
RUQL_ZONES["Loch Modan"] = "Лок Модан"
RUQL_ZONES["Dun Morogh"] = "Дун Морог"
RUQL_ZONES["Wetlands"] = "Болотина"
RUQL_ZONES["Arathi Highlands"] = "Нагорье Арати"
RUQL_ZONES["Hillsbrad Foothills"] = "Предгорья Хилсбрада"
RUQL_ZONES["Alterac Mountains"] = "Альтеракские горы"
RUQL_ZONES["Silverpine Forest"] = "Серебряный бор"
RUQL_ZONES["Tirisfal Glades"] = "Тирисфальские леса"
RUQL_ZONES["Western Plaguelands"] = "Западные Чумные земли"
RUQL_ZONES["Eastern Plaguelands"] = "Восточные Чумные земли"
RUQL_ZONES["Deadwind Pass"] = "Перевал Мертвого Ветра"
RUQL_ZONES["Swamp of Sorrows"] = "Болото Печали"
RUQL_ZONES["Blasted Lands"] = "Выжженные земли"
RUQL_ZONES["Burning Steppes"] = "Пылающие степи"
RUQL_ZONES["Searing Gorge"] = "Тлеющее ущелье"
RUQL_ZONES["Badlands"] = "Бесплодные земли"
RUQL_ZONES["Ghostlands"] = "Призрачные земли"
RUQL_ZONES["Eversong Woods"] = "Леса Вечной Песни"
RUQL_ZONES["Isle of Quel'Danas"] = "Остров Кель'Данас"

-- Eastern Kingdoms - capital cities
RUQL_ZONES["Stormwind City"] = "Штормград"
RUQL_ZONES["Ironforge"] = "Стальгорн"
RUQL_ZONES["Undercity"] = "Подгород"
RUQL_ZONES["Silvermoon City"] = "Луносвет"

-- ============================================================
-- Kalimdor - zones
-- ============================================================
RUQL_ZONES["Durotar"] = "Дуротар"
RUQL_ZONES["Mulgore"] = "Мулгор"
RUQL_ZONES["Teldrassil"] = "Тельдрассил"
RUQL_ZONES["Darkshore"] = "Темные берега"
RUQL_ZONES["Ashenvale"] = "Ясеневый лес"
RUQL_ZONES["Stonetalon Mountains"] = "Когтистые горы"
RUQL_ZONES["Desolace"] = "Пустоши"
RUQL_ZONES["Thousand Needles"] = "Тысяча Игл"
RUQL_ZONES["Feralas"] = "Фералас"
RUQL_ZONES["Dustwallow Marsh"] = "Пылевые топи"
RUQL_ZONES["Tanaris"] = "Танарис"
RUQL_ZONES["Azshara"] = "Азшара"
RUQL_ZONES["Felwood"] = "Оскверненный лес"
RUQL_ZONES["Winterspring"] = "Зимние Ключи"
RUQL_ZONES["Moonglade"] = "Лунная поляна"
RUQL_ZONES["Silithus"] = "Силитус"
RUQL_ZONES["Un'Goro Crater"] = "Кратер Ун'Горо"
RUQL_ZONES["The Barrens"] = "Степи"
-- В 3.3.5a "The Barrens" — единая зона; разделение на Северные/Южные
-- Степи появилось только в Cataclysm, отдельные записи не нужны.

-- Kalimdor - capital cities
RUQL_ZONES["Orgrimmar"] = "Оргриммар"
RUQL_ZONES["Thunder Bluff"] = "Громовой Утес"
RUQL_ZONES["Darnassus"] = "Дарнас"

-- ============================================================
-- Outland - zones
-- ============================================================
RUQL_ZONES["Hellfire Peninsula"] = "Полуостров Адского Пламени"
RUQL_ZONES["Zangarmarsh"] = "Зангартопь"
RUQL_ZONES["Terokkar Forest"] = "Лес Тероккар"
RUQL_ZONES["Nagrand"] = "Награнд"
RUQL_ZONES["Blade's Edge Mountains"] = "Острогорье"
RUQL_ZONES["Netherstorm"] = "Пустоверть"
RUQL_ZONES["Shadowmoon Valley"] = "Долина Призрачной Луны"
RUQL_ZONES["Shattrath City"] = "Шаттрат"

-- ============================================================
-- Northrend - zones
-- ============================================================
RUQL_ZONES["Borean Tundra"] = "Борейская тундра"
RUQL_ZONES["Howling Fjord"] = "Ревущий фьорд"
RUQL_ZONES["Dragonblight"] = "Драконий Погост"
RUQL_ZONES["Grizzly Hills"] = "Седые холмы"
RUQL_ZONES["Zul'Drak"] = "Зул'Драк"
RUQL_ZONES["Sholazar Basin"] = "Низина Шолазар"
RUQL_ZONES["The Storm Peaks"] = "Грозовая Гряда"
RUQL_ZONES["Icecrown"] = "Ледяная Корона"
RUQL_ZONES["Crystalsong Forest"] = "Лес Хрустальной Песни"
RUQL_ZONES["Wintergrasp"] = "Озеро Ледяных Оков"
RUQL_ZONES["Dalaran"] = "Даларан"

-- ============================================================
-- Крупные подземелья/рейды (проверено по тем же страницам Wowhead,
-- но по одному источнику на запись — чуть ниже уверенность, чем в
-- списке зон открытого мира выше).
-- ============================================================
RUQL_ZONES["Deadmines"] = "Мертвые копи"
RUQL_ZONES["The Deadmines"] = "Мертвые копи"
RUQL_ZONES["Shadowfang Keep"] = "Крепость Темного Клыка"
RUQL_ZONES["Blackrock Depths"] = "Глубины Черной горы"
RUQL_ZONES["Naxxramas"] = "Наксрамас"
RUQL_ZONES["Icecrown Citadel"] = "Цитадель Ледяной Короны"
RUQL_ZONES["Ulduar"] = "Ульдуар"
