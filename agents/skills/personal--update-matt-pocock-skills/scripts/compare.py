#!/usr/bin/env python3
"""Compare vault clones of Matt Pocock skills against the upstream repo.

Usage: compare.py <upstream-repo-dir> <vault-clones-dir> [--show <skill> ...]

<vault-clones-dir> holds one `better-skills clone` folder per skill, named by slug.
Prints, per skill: identical, or the files that differ after normalization.
--show prints the unified diff (UP = upstream, VAULT = vault) for those skills.
Normalization hides vault-only noise: folded YAML descriptions, quoted
frontmatter values, [[skill:]]/[[resource:]] mentions vs markdown links or
skill names, "Agent metadata" lines, and blank lines.
"""
import difflib, glob, os, re, sys

def usage(msg):
    sys.stderr.write(f"error: {msg}\n{__doc__}")
    sys.exit(2)

args = sys.argv[1:]
if len(args) < 2: usage("need <upstream-repo-dir> and <vault-clones-dir>")
upstream_root, vault_root = args[0], args[1]
show = set(args[args.index("--show") + 1:]) if "--show" in args else set()
if not os.path.isdir(os.path.join(upstream_root, "skills")): usage(f"{upstream_root}/skills not found; clone https://github.com/mattpocock/skills first")
if not os.path.isdir(vault_root): usage(f"{vault_root} is not a directory")

upstream = {os.path.basename(os.path.dirname(p)): os.path.dirname(p)
            for p in glob.glob(os.path.join(upstream_root, "skills", "*", "*", "SKILL.md"))}
names = "|".join(sorted(map(re.escape, upstream), key=len, reverse=True))
name_ref = re.compile(rf'[`"]?/?\b({names})\b[`"]?') if names else None

def norm(path):
    try: t = open(path, encoding="utf-8").read()
    except UnicodeDecodeError: return open(path, "rb").read().hex().splitlines()
    m = re.match(r"---\n(.*?)\n---\n", t, re.S)
    if m:
        fm = re.sub(r":\s*>-?\n((?:  +.*\n?)+)",
                    lambda x: ": " + " ".join(l.strip() for l in x.group(1).splitlines()) + "\n", m.group(1) + "\n")
        fm = re.sub(r': "(.*)"$', r": \1", fm, flags=re.M).replace('\\"', '"')
        t = "---\n" + fm.strip() + "\n---\n" + t[m.end():]
    t = re.sub(r"\[\[(skill|resource):[^\]]+\]\]", "LINK", t)
    t = re.sub(r"\[[^\]]*\]\([^)#]*\.(md|sh|ts|js|cjs|html|py)\)", "LINK", t)
    if name_ref: t = name_ref.sub("LINK", t)
    t = re.sub(r'"LINK"', "LINK", t)
    return [l.rstrip() for l in t.splitlines()
            if l.strip() and not re.match(r"^(Agent metadata|Invocation metadata|Attribution):", l)]

def files(d):
    out = set()
    for root, dirs, fs in os.walk(d):
        dirs[:] = [x for x in dirs if not x.startswith(".")]
        out |= {os.path.relpath(os.path.join(root, f), d) for f in fs if not f.startswith(".")}
    return out

for slug in sorted(os.listdir(vault_root)):
    vdir = os.path.join(vault_root, slug)
    if not os.path.isdir(vdir): continue
    if slug not in upstream:
        print(f"== {slug}: not in upstream"); continue
    udir = upstream[slug]
    lines = []
    for f in sorted(files(udir) | files(vdir)):
        a, b = os.path.join(udir, f), os.path.join(vdir, f)
        if not os.path.exists(b): lines.append(f"  only-upstream: {f}"); continue
        if not os.path.exists(a): lines.append(f"  only-vault: {f}"); continue
        d = list(difflib.unified_diff(norm(a), norm(b), f"UP/{f}", f"VAULT/{f}", lineterm="", n=1))
        if d:
            n = sum(1 for l in d if l[:1] in "+-" and l[:3] not in ("+++", "---"))
            lines.append(f"  differs: {f} ({n} lines)")
            if slug in show: lines += ["    " + l for l in d]
    print(f"== {slug} ({os.path.relpath(udir, upstream_root)})")
    print("\n".join(lines) if lines else "  identical")
