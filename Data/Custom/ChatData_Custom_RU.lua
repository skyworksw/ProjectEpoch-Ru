-- Реплики NPC в чате (say/yell/emote/whisper): RUQL_CHAT["Оригинальный текст"] = "Перевод"
-- Ключ должен дословно совпадать с английским текстом, включая пунктуацию — это
-- обычный текст, присылаемый сервером в чат, а не запись из клиентских файлов.
-- Одна и та же реплика может встречаться у разных NPC (например, стандартные
-- фразы трактирщиков) — достаточно перевести её один раз.
RUQL_CHAT = RUQL_CHAT or {}

-- Project Epoch: текст собран отчётом аддона 2026-09-05.
RUQL_CHAT["Now arriving at Goldshire! Mind your step as you disembark."] = "Прибытие в Златоземье! Осторожно при выходе."
RUQL_CHAT["Departing from Goldshire! All aboard!"] = "Отправление из Златоземья! Все на борт!"
RUQL_CHAT["Welcome to the Lion's Pride Inn.  Make yourself at home!"] = "Добро пожаловать в трактир «Гордость льва». Чувствуй себя как дома!"

-- Project Epoch: текст собран отчётом аддона 2026-09-06.
RUQL_CHAT["I will meet you at my home. Do not delay. The Defias have grown bold at night."] = "Встретимся у меня дома. Не медли. По ночам Братство Справедливости совсем обнаглело."
RUQL_CHAT["If your glass is full may it be again!"] = "Пусть бокал твой не будет пустым!"

-- Пример:
-- RUQL_CHAT["If your glass is full, may it be again!"] = "Пусть бокал твой не будет пустым!"
