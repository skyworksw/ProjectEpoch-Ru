#!/usr/bin/env python3
"""Build a translation queue of Project Epoch's custom quest chains.

Source: the pfQuest-epoch addon's own Lua database (English quest text plus
quest-chain/pre-req/NPC/zone/item references). This covers quests that only
exist on Project Epoch and were never part of AzerothCore's stock WotLK
content, so they have no existing ruRU translation to reuse.

Usage:
    python3 tools/extract_epoch_quest_chains.py --pfquest-epoch /path/to/pfQuest-epoch [--out tools/epoch_queue.json]

Produces a JSON queue of quest chains (grouped via pre/next links), each
quest annotated with English T/O/D plus resolved NPC/zone/item/object names
for translation context, and a `done` flag for IDs already present in
Data/Custom/QuestData_Custom_RU.lua.
"""

import argparse
import json
import os
import re
import sys

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def lua_unescape(s):
    return (
        s.replace("\\n", "\n")
        .replace("\\r", "\r")
        .replace("\\t", "\t")
        .replace("\\\"", "\"")
        .replace("\\'", "'")
        .replace("\\\\", "\\")
    )


def parse_string_map(path):
    """Parse `[123] = "text",` maps (units/zones/objects-epoch.lua)."""
    text = open(path, encoding="utf-8").read()
    out = {}
    for m in re.finditer(r'\[(\d+)\]\s*=\s*"((?:\\.|[^"\\])*)"', text, re.S):
        out[int(m.group(1))] = lua_unescape(m.group(2))
    return out


def parse_quest_text(path):
    """Parse enUS/quests-epoch.lua: [id] = { ["T"]=, ["O"]=, ["D"]= }."""
    text = open(path, encoding="utf-8").read()
    out = {}
    for m in re.finditer(r'\[(\d+)\]\s*=\s*\{(.*?)\n  \},\n', text, re.S):
        qid = int(m.group(1))
        block = m.group(2)
        fields = {}
        for key in ("T", "O", "D"):
            fm = re.search(r'\["%s"\]\s*=\s*"((?:\\.|[^"\\])*)"' % key, block, re.S)
            if fm:
                fields[key] = lua_unescape(fm.group(1))
        out[qid] = fields
    return out


def parse_int_list(block, key):
    m = re.search(r'\["%s"\]\s*=\s*\{([^}]*)\}' % key, block)
    if not m:
        return []
    return [int(x) for x in re.findall(r'\d+', m.group(1))]


def parse_quest_data(path):
    """Parse quests-epoch.lua: chain links, start/end NPCs, objectives, level."""
    text = open(path, encoding="utf-8").read()
    out = {}
    for m in re.finditer(r'\[(\d+)\]\s*=\s*\{(.*?)\n  \},\n', text, re.S):
        qid = int(m.group(1))
        block = m.group(2)
        entry = {"pre": [], "next": None, "start_u": [], "end_u": [], "obj_i": [], "obj_o": [], "obj_u": [], "lvl": None}

        pre_m = re.search(r'\["pre"\]\s*=\s*\{([^}]*)\}', block)
        if pre_m:
            entry["pre"] = [int(x) for x in re.findall(r'\d+', pre_m.group(1))]

        next_m = re.search(r'\["next"\]\s*=\s*(\d+)', block)
        if next_m:
            entry["next"] = int(next_m.group(1))

        start_m = re.search(r'\["start"\]\s*=\s*\{(.*?)\n\s*\},', block, re.S)
        if start_m:
            entry["start_u"] = parse_int_list(start_m.group(1), "U")

        end_m = re.search(r'\["end"\]\s*=\s*\{(.*?)\n\s*\},', block, re.S)
        if end_m:
            entry["end_u"] = parse_int_list(end_m.group(1), "U")

        obj_m = re.search(r'\["obj"\]\s*=\s*\{(.*?)\n\s*\},', block, re.S)
        if obj_m:
            entry["obj_i"] = parse_int_list(obj_m.group(1), "I")
            entry["obj_o"] = parse_int_list(obj_m.group(1), "O")
            entry["obj_u"] = parse_int_list(obj_m.group(1), "U")

        lvl_m = re.search(r'\["lvl"\]\s*=\s*(\d+)', block)
        if lvl_m:
            entry["lvl"] = int(lvl_m.group(1))

        out[qid] = entry
    return out


def parse_done_ids():
    done = set()
    for relpath in ("Data/Custom/QuestData_Custom_RU.lua", "Data/Generated/QuestData_WotLK_RU.lua"):
        path = os.path.join(REPO_ROOT, relpath)
        if not os.path.exists(path):
            continue
        text = open(path, encoding="utf-8").read()
        done.update(int(x) for x in re.findall(r'^RUQL_QUESTS\[(\d+)\]', text, re.M))
    return done


class UnionFind:
    def __init__(self):
        self.parent = {}

    def find(self, x):
        self.parent.setdefault(x, x)
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x

    def union(self, a, b):
        ra, rb = self.find(a), self.find(b)
        if ra != rb:
            self.parent[ra] = rb


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--pfquest-epoch", required=True, help="Path to the pfQuest-epoch addon/repo root")
    ap.add_argument("--out", default=os.path.join(REPO_ROOT, "tools", "epoch_queue.json"))
    ap.add_argument("--stock-max-id", type=int, default=25000,
                     help="Quest IDs below this are treated as stock WotLK content, not Epoch-custom")
    args = ap.parse_args()

    base = args.pfquest_epoch
    units = parse_string_map(os.path.join(base, "db", "enUS", "units-epoch.lua"))
    zones = parse_string_map(os.path.join(base, "db", "enUS", "zones-epoch.lua"))
    objects = parse_string_map(os.path.join(base, "db", "enUS", "objects-epoch.lua"))
    items = parse_string_map(os.path.join(base, "db", "enUS", "items-epoch.lua"))
    texts = parse_quest_text(os.path.join(base, "db", "enUS", "quests-epoch.lua"))
    data = parse_quest_data(os.path.join(base, "db", "quests-epoch.lua"))

    done_ids = parse_done_ids()

    custom_ids = {qid for qid in texts if qid > args.stock_max_id}

    uf = UnionFind()
    for qid in custom_ids:
        uf.find(qid)
        entry = data.get(qid, {})
        for p in entry.get("pre", []):
            if p in custom_ids:
                uf.union(qid, p)
        nxt = entry.get("next")
        if nxt and nxt in custom_ids:
            uf.union(qid, nxt)

    groups = {}
    for qid in custom_ids:
        root = uf.find(qid)
        groups.setdefault(root, []).append(qid)

    chains = []
    for root, ids in groups.items():
        ids_sorted = sorted(ids)
        quests = []
        for qid in ids_sorted:
            entry = data.get(qid, {})
            text = texts.get(qid, {})
            quests.append({
                "id": qid,
                "done": qid in done_ids,
                "lvl": entry.get("lvl"),
                "pre": entry.get("pre", []),
                "next": entry.get("next"),
                "start_npc": [units.get(u, f"NPC#{u}") for u in entry.get("start_u", [])],
                "end_npc": [units.get(u, f"NPC#{u}") for u in entry.get("end_u", [])],
                "obj_items": [items.get(i, f"Item#{i}") for i in entry.get("obj_i", [])],
                "obj_objects": [objects.get(o, f"Object#{o}") for o in entry.get("obj_o", [])],
                "obj_units": [units.get(u, f"NPC#{u}") for u in entry.get("obj_u", [])],
                "T": text.get("T"),
                "O": text.get("O"),
                "D": text.get("D"),
            })
        chains.append({
            "chain_id": min(ids_sorted),
            "size": len(ids_sorted),
            "all_done": all(q["done"] for q in quests),
            "quests": quests,
        })

    chains.sort(key=lambda c: c["chain_id"])

    with open(args.out, "w", encoding="utf-8") as f:
        json.dump(chains, f, ensure_ascii=False, indent=2)

    total_quests = sum(c["size"] for c in chains)
    done_quests = sum(1 for c in chains for q in c["quests"] if q["done"])
    todo_chains = [c for c in chains if not c["all_done"]]

    print(f"Chains: {len(chains)} (todo: {len(todo_chains)})")
    print(f"Quests: {total_quests} (done: {done_quests}, todo: {total_quests - done_quests})")
    print(f"Wrote {args.out}")


if __name__ == "__main__":
    sys.exit(main())
