#!/usr/bin/env python3
"""Regenerate Data/Generated/*.lua from an AzerothCore WotLK world database.

Source tables (ruRU locale rows), all from data/sql/base/db_world in
https://github.com/azerothcore/azerothcore-wotlk (GPL-2.0):
    item_template_locale, quest_template, quest_template_locale,
    quest_offer_reward_locale, quest_request_items_locale

Usage:
    python3 tools/generate_azerothcore_ru.py \
        --host 127.0.0.1 --user root --password '' --database acore_world

Requires a `mysql` client on PATH; talks to the database through it instead
of a Python driver so the script has no extra dependencies.
"""

import argparse
import os
import subprocess
import sys

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GENERATED_DIR = os.path.join(REPO_ROOT, "Data", "Generated")


def run_query(args, query):
    cmd = [
        "mysql",
        "--host", args.host,
        "--port", str(args.port),
        "--user", args.user,
        "--default-character-set=utf8mb4",
        args.database,
        "--batch",
    ]
    env = os.environ.copy()
    if args.password:
        env["MYSQL_PWD"] = args.password
    # Binary mode: some quest text has stray raw \r bytes that Python's
    # universal-newline text mode would otherwise fold into extra line breaks.
    result = subprocess.run(cmd, input=query.encode("utf-8"), capture_output=True, env=env)
    if result.returncode != 0:
        sys.exit(f"mysql query failed: {result.stderr.decode('utf-8', 'replace').strip()}")

    stdout = result.stdout.decode("utf-8")
    lines = stdout.split("\n")
    if lines and lines[-1] == "":
        lines.pop()
    rows = []
    for line in lines[1:]:  # skip header row
        rows.append([unescape(cell) for cell in line.split("\t")])
    return rows


def unescape(cell):
    if cell == "\\N" or cell == "NULL":
        return None
    value = (
        cell.replace("\\t", "\t")
        .replace("\\n", "\n")
        .replace("\\0", "\0")
        .replace("\\\\", "\\")
    )
    # Several DB rows carry stray trailing whitespace/CRLF around the real text.
    return value.strip()


def lua_string(value):
    if value is None or value == "":
        return "nil"
    escaped = (
        value.replace("\\", "\\\\")
        .replace('"', '\\"')
        .replace("\n", "\\n")
        .replace("\r", "\\r")
        .replace("\t", "\\t")
    )
    return f'"{escaped}"'


def hash_title(text):
    value = 5381
    for byte in text.encode("utf-8"):
        value = (value * 33 + byte) % 4294967291
    return value


def generate_items(args):
    rows = run_query(
        args,
        "SELECT ID, Name, Description FROM item_template_locale "
        "WHERE locale='ruRU' ORDER BY ID;",
    )

    lines = [
        "-- Generated file. Do not edit by hand.",
        "-- Source: AzerothCore WotLK world database (GPL-2.0).",
        f"-- Russian items: {len(rows)}.",
        "",
        "RUQL_ITEMS = RUQL_ITEMS or {}",
    ]
    for item_id, name, description in rows:
        lines.append(f"RUQL_ITEMS[{item_id}]={{{lua_string(name)},{lua_string(description)}}}")

    path = os.path.join(GENERATED_DIR, "ItemData_WotLK_RU.lua")
    with open(path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")
    print(f"Wrote {path}: {len(rows)} items")


def generate_quests(args):
    quest_rows = run_query(
        args,
        "SELECT ID, Title, Details, Objectives, ObjectiveText1, ObjectiveText2, "
        "ObjectiveText3, ObjectiveText4 FROM quest_template_locale "
        "WHERE locale='ruRU' ORDER BY ID;",
    )
    completion_rows = run_query(
        args,
        "SELECT ID, CompletionText FROM quest_request_items_locale WHERE locale='ruRU';",
    )
    reward_rows = run_query(
        args,
        "SELECT ID, RewardText FROM quest_offer_reward_locale WHERE locale='ruRU';",
    )
    title_rows = run_query(args, "SELECT ID, LogTitle FROM quest_template;")

    completion_by_id = {row[0]: row[1] for row in completion_rows}
    reward_by_id = {row[0]: row[1] for row in reward_rows}
    log_title_by_id = {row[0]: row[1] for row in title_rows}

    lines = [
        "-- Generated file. Do not edit by hand.",
        "-- Source: AzerothCore WotLK world database (GPL-2.0).",
    ]

    quest_lines = []
    titles_seen = {}
    for row in quest_rows:
        quest_id = row[0]
        title, details, objectives = row[1], row[2], row[3]
        obj1, obj2, obj3, obj4 = row[4], row[5], row[6], row[7]
        completion = completion_by_id.get(quest_id)
        reward = reward_by_id.get(quest_id)

        fields = [title, details, objectives, completion, reward, obj1, obj2, obj3, obj4]
        quest_lines.append(
            f"RUQL_QUESTS[{quest_id}]={{{','.join(lua_string(v) for v in fields)}}}"
        )

        log_title = log_title_by_id.get(quest_id)
        if log_title:
            titles_seen.setdefault(log_title, []).append(quest_id)

    title_index = {}
    for log_title, ids in titles_seen.items():
        if len(ids) == 1:
            title_index[hash_title(log_title)] = ids[0]

    lines.append(f"-- Russian quests: {len(quest_rows)}; unique English titles: {len(title_index)}.")
    lines.append("")
    lines.append("RUQL_QUESTS = RUQL_QUESTS or {}")
    lines.append("RUQL_TITLE_INDEX = RUQL_TITLE_INDEX or {}")
    lines.append("")
    lines.extend(quest_lines)
    lines.append("")
    for hash_value in sorted(title_index):
        lines.append(f"RUQL_TITLE_INDEX[{hash_value}]={title_index[hash_value]}")

    path = os.path.join(GENERATED_DIR, "QuestData_WotLK_RU.lua")
    with open(path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")
    print(f"Wrote {path}: {len(quest_rows)} quests, {len(title_index)} unique titles")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", default=3306, type=int)
    parser.add_argument("--user", default="root")
    parser.add_argument("--password", default="")
    parser.add_argument("--database", default="acore_world")
    args = parser.parse_args()

    os.makedirs(GENERATED_DIR, exist_ok=True)
    generate_items(args)
    generate_quests(args)


if __name__ == "__main__":
    main()
