#!/usr/bin/env python3
"""Export the still-untranslated Project Epoch quest queue as a human-friendly
text file for manual translation.

Reads tools/epoch_queue.json (produced by extract_epoch_quest_chains.py) and
writes a text file with, for every not-yet-translated quest: its English
source text plus NPC/item/zone context, followed by a ready-to-fill
RUQL_QUESTS[...] Lua stub matching the format used in
Data/Custom/QuestData_Custom_RU.lua. Paste finished entries straight into that
file.

Usage:
    python3 tools/extract_epoch_quest_chains.py --pfquest-epoch /path/to/pfQuest-epoch
    python3 tools/export_untranslated.py [--out tools/untranslated_quests.txt]
"""

import argparse
import json
import os

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--queue", default=os.path.join(REPO_ROOT, "tools", "epoch_queue.json"))
    ap.add_argument("--out", default=os.path.join(REPO_ROOT, "tools", "untranslated_quests.txt"))
    args = ap.parse_args()

    chains = json.load(open(args.queue, encoding="utf-8"))
    todo_chains = [c for c in chains if not c["all_done"]]
    todo_chains.sort(key=lambda c: c["chain_id"])

    total_quests = sum(1 for c in todo_chains for q in c["quests"] if not q["done"])

    out = []
    out.append("Project Epoch — quest translation queue (English source, not yet translated)\n")
    out.append(f"Chains: {len(todo_chains)}   Quests: {total_quests}\n")
    out.append(
        "Reference: Data/Generated/ZoneData_WotLK_RU.lua for zone names; "
        "Data/Custom/QuestData_Custom_RU.lua for NPC/place names already "
        "translated in earlier batches (search by originalTitle or by name).\n"
    )
    out.append(
        "Format per quest: English context, then a RUQL_QUESTS[...] Lua stub "
        "to fill in and paste into Data/Custom/QuestData_Custom_RU.lua.\n"
    )
    out.append("=" * 78 + "\n")

    for c in todo_chains:
        quests = [q for q in c["quests"] if not q["done"]]
        if not quests:
            continue
        out.append(f"\n### Chain starting at {c['chain_id']} ({len(quests)} quest(s)) ###\n")
        for q in quests:
            out.append(f"\n--- Quest {q['id']} (lvl {q['lvl']}) ---\n")
            if q["start_npc"]:
                out.append(f"Start NPC: {', '.join(q['start_npc'])}\n")
            if q["end_npc"]:
                out.append(f"End NPC: {', '.join(q['end_npc'])}\n")
            if q["obj_items"]:
                out.append(f"Objective item(s): {', '.join(q['obj_items'])}\n")
            if q["obj_objects"]:
                out.append(f"Objective object(s): {', '.join(q['obj_objects'])}\n")
            if q["obj_units"]:
                out.append(f"Objective kill target(s): {', '.join(q['obj_units'])}\n")
            if q["pre"]:
                out.append(f"Requires quest(s): {q['pre']}\n")
            if q["next"]:
                out.append(f"Leads to quest: {q['next']}\n")
            out.append(f"Title (EN): {q['T']}\n")
            out.append(f"Objective (EN): {q['O']}\n")
            d = (q["D"] or "").replace("\n", "\\n")
            out.append(f"Description (EN): {d}\n")

            title_esc = (q["T"] or "").replace('"', '\\"')
            out.append("\nRUQL_QUESTS[%d] = {\n" % q["id"])
            out.append('    "",  -- название\n')
            out.append('    "",  -- описание (D)\n')
            out.append('    "",  -- цель задания (O)\n')
            out.append("    nil, nil,  -- текст прогресса / завершения у NPC (обычно неизвестен)\n")
            out.append("    nil, nil, nil, nil,  -- задача 1-4 (имя предмета/цели или инфинитив-действие)\n")
            out.append('    originalTitle = "%s"\n' % title_esc)
            out.append("}\n")
        out.append("\n" + "-" * 78 + "\n")

    with open(args.out, "w", encoding="utf-8") as f:
        f.write("".join(out))

    print(f"Chains: {len(todo_chains)}")
    print(f"Quests: {total_quests}")
    print(f"Wrote {args.out}")


if __name__ == "__main__":
    main()
