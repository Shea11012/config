#!/usr/bin/env python3
"""通用 lint 阶段 B — 全局机械扫描。

用法：
    python3 scripts/lint-stage-b.py <vault_path>

所有配置从 .wiki-schema.md 的 frontmatter 读取。

检查分类：
  全局（需要所有页面构建索引）：orphan, broken_links, similar_unlinked, tags, synthesis_upgrade
  局部（可按文件过滤）：frontmatter_issues, extracted_quote_issues
  脚本始终全量扫描（几秒完成），结果过滤由调用方负责。
"""

import sys
import os
import re
import json
from datetime import date
from pathlib import Path
from collections import defaultdict, Counter

DEFAULT_EXCLUDED_DIRS = {".obsidian", ".trash", "raw", "assets", "config", "Excalidraw", "mermaid"}
REQUIRED_FIELDS = ["title", "created", "updated", "status", "type", "tags"]
VALID_STATUSES = {"draft", "stable", "needs-review", "outdated", "superseded"}
VALID_CONFIDENCES = {"EXTRACTED", "INFERRED", "AMBIGUOUS", "UNVERIFIED"}
DEFAULT_SYNTHESIS_THRESHOLD = 5
DEFAULT_TAG_OVERLAP_MIN = 2       # tag 重叠数 ≥ 此值才算「tag 相似」
DEFAULT_MAX_SIMILAR_RESULTS = 50  # 最多返回多少对


def read_schema_config(vault_path: Path) -> dict:
    """从 .wiki-schema.md 读取配置。"""
    schema_path = vault_path / ".wiki-schema.md"
    if not schema_path.exists():
        print(f"ERROR: .wiki-schema.md 不存在: {schema_path}", file=sys.stderr)
        sys.exit(1)

    text = schema_path.read_text(encoding="utf-8")
    fm = _parse_frontmatter(text)

    config = {
        "tag_aliases": {},
        "excluded_dirs": DEFAULT_EXCLUDED_DIRS,
        "synthesis_threshold": DEFAULT_SYNTHESIS_THRESHOLD,
        "tag_overlap_min": DEFAULT_TAG_OVERLAP_MIN,
        "max_similar_results": DEFAULT_MAX_SIMILAR_RESULTS,
    }

    if not fm:
        return config

    aliases = fm.get("tag_aliases", {})
    if isinstance(aliases, dict):
        config["tag_aliases"] = {str(k).strip(): str(v).strip() for k, v in aliases.items()}

    excl = fm.get("excluded_dirs", None)
    if isinstance(excl, list):
        config["excluded_dirs"] = {str(d).strip() for d in excl if d}

    for key in ("synthesis_threshold", "tag_overlap_min", "max_similar_results"):
        val = fm.get(key, None)
        if val is not None:
            config[key] = int(val)

    return config


def _parse_frontmatter(text: str) -> dict | None:
    if not text.startswith("---"):
        return None
    end = text.find("---", 3)
    if end == -1:
        return None
    raw = text[3:end].strip()
    if not raw:
        return {}
    try:
        import yaml
        data = yaml.safe_load(raw)
        return data if isinstance(data, dict) else None
    except ImportError:
        print("ERROR: PyYAML 未安装。请运行: pip install pyyaml", file=sys.stderr)
        sys.exit(1)
    except Exception:
        return None


def extract_wikilinks(text: str) -> list[str]:
    pattern = re.compile(r"\[\[([^\]|#]+)(?:[|#][^\]]+)?\]\]")
    return [m.group(1).strip() for m in pattern.finditer(text)]


def extract_wikilinks_from_fm(data: dict) -> list[str]:
    links = []
    for field in ("related", "contradictions"):
        values = data.get(field, [])
        if isinstance(values, list):
            links.extend(str(v).strip() for v in values if v)
    return links


def find_similar_tags(tags: list[str], aliases: dict[str, str]) -> list[dict]:
    issues = []
    lower_map: dict[str, list[str]] = defaultdict(list)
    for t in tags:
        lower_map[t.lower()].append(t)
    for lower, originals in lower_map.items():
        if len(originals) > 1:
            issues.append({"type": "case_variant", "tags": originals, "canonical": lower})
    for tag in tags:
        mapped = aliases.get(tag.lower())
        if mapped:
            issues.append({"type": "known_alias", "tag": tag, "suggest": mapped})
    return issues


def discover_pages(vault_path: Path, excluded_dirs: set[str]) -> list[dict]:
    pages = []
    for root, dirs, files in os.walk(vault_path):
        dirs[:] = [d for d in dirs if d not in excluded_dirs and not d.startswith(".")]
        for fname in files:
            if not fname.endswith(".md") or fname == ".wiki-schema.md":
                continue
            fpath = Path(root) / fname
            rel_path = fpath.relative_to(vault_path)
            text = fpath.read_text(encoding="utf-8", errors="replace")
            fm = _parse_frontmatter(text) or {}
            # 正文 = 截掉 frontmatter 后的部分
            body = text
            if text.startswith("---"):
                end = text.find("---", 3)
                if end != -1:
                    body = text[end + 3:].strip()
            pages.append({
                "path": str(rel_path),
                "frontmatter": fm,
                "body": body,
                "wikilinks_in_body": extract_wikilinks(text),
                "wikilinks_in_fm": extract_wikilinks_from_fm(fm),
            })
    return pages


# --- 检查 1：孤页 ---

def check_orphans(pages):
    referenced = set()
    for p in pages:
        for link in p["wikilinks_in_body"]:
            referenced.add(link)
        for link in p["wikilinks_in_fm"]:
            referenced.add(link)
    orphans = []
    for p in pages:
        stem = Path(p["path"]).stem
        if stem not in referenced and not p["path"].startswith("raw/"):
            orphans.append({"path": p["path"], "title": p["frontmatter"].get("title", stem)})
    return orphans


# --- 检查 2：断链 ---

def check_broken_links(pages):
    existing = {Path(p["path"]).stem for p in pages}
    broken, seen = [], set()
    for p in pages:
        for link in p["wikilinks_in_body"] + p["wikilinks_in_fm"]:
            if link not in existing:
                key = (p["path"], link)
                if key not in seen:
                    seen.add(key)
                    broken.append({"source": p["path"], "target": link})
    return broken


# --- 检查 3：相似但未关联的页面 ---

def check_similar_unlinked(pages, overlap_min, max_results):
    """找到 tag 重叠但没有 [[wikilinks]] 互链的页面对。

    嵌套 tag（go/gc）参与三层匹配：
    - go/gc ∩ go/gc           → 直接匹配 1.0
    - go/gc ∩ go/memory       → 父 tag go 匹配 0.5
    - go/gc ∩ 计算机基础/gc    → 子 tag gc 匹配 0.75
    """

    def tag_sets(tag_list):
        """从 tag 列表提取 (直接tag, 父tag, 子tag) 三集合。"""
        direct = set()
        parents = set()
        children = set()
        for t in tag_list:
            t = str(t).strip().lower()
            if not t:
                continue
            direct.add(t)
            if "/" in t:
                p, c = t.split("/", 1)
                parents.add(p)
                children.add(c)
        return direct, parents, children

    page_tags_direct: dict[str, set[str]] = {}
    page_tags_parents: dict[str, set[str]] = {}
    page_tags_children: dict[str, set[str]] = {}
    page_links: dict[str, set[str]] = {}

    for p in pages:
        stem = Path(p["path"]).stem
        tags = p["frontmatter"].get("tags", [])
        if isinstance(tags, list):
            d, par, ch = tag_sets(tags)
        else:
            d, par, ch = set(), set(), set()
        page_tags_direct[stem] = d
        page_tags_parents[stem] = par
        page_tags_children[stem] = ch
        page_links[stem] = set(p["wikilinks_in_body"] + p["wikilinks_in_fm"])

    stems = list(page_tags_direct.keys())
    results = []
    for i in range(len(stems)):
        for j in range(i + 1, len(stems)):
            a, b = stems[i], stems[j]

            if a in page_links[b] or b in page_links[a]:
                continue

            d_a, p_a, c_a = page_tags_direct[a], page_tags_parents[a], page_tags_children[a]
            d_b, p_b, c_b = page_tags_direct[b], page_tags_parents[b], page_tags_children[b]

            score = len(d_a & d_b) + len(c_a & c_b) * 0.75 + len(p_a & p_b) * 0.5
            if score < overlap_min:
                continue

            all_direct = sorted(d_a & d_b)
            child_overlap = sorted(c_a & c_b)
            parent_overlap = sorted((p_a & p_b) - {t.split("/")[0] for t in all_direct})

            results.append({
                "page_a": a,
                "page_b": b,
                "overlap_score": score,
                "overlap_tags": all_direct,
                "overlap_children": child_overlap,
                "overlap_parents": parent_overlap,
            })

    results.sort(key=lambda r: r["overlap_score"], reverse=True)
    return results[:max_results]


# --- 检查 4：Tag 审计 ---

def check_tags(pages, aliases):
    all_tags, tag_to_pages = Counter(), defaultdict(list)
    for p in pages:
        tags = p["frontmatter"].get("tags", [])
        if not isinstance(tags, list):
            continue
        for t in tags:
            t_str = str(t).strip()
            if t_str:
                all_tags[t_str] += 1
                tag_to_pages[t_str].append(p["path"])
    result = {"total_unique": len(all_tags), "total_occurrences": sum(all_tags.values()),
              "single_occurrence": [], "non_lowercase": [], "with_spaces": [], "similar": []}
    for tag, count in all_tags.items():
        if count == 1:
            result["single_occurrence"].append({"tag": tag, "pages": tag_to_pages[tag]})
        if tag != tag.lower():
            result["non_lowercase"].append({"tag": tag})
        if " " in tag:
            result["with_spaces"].append({"tag": tag, "pages": tag_to_pages[tag]})
    result["similar"] = find_similar_tags(list(all_tags.keys()), aliases)
    return result


# --- 检查 5：Frontmatter 完整性 ---

def check_frontmatter(pages):
    issues = []
    for p in pages:
        fm, path, body, probs = p["frontmatter"], p["path"], p.get("body", ""), []
        for field in REQUIRED_FIELDS:
            if field not in fm or fm[field] is None:
                probs.append(f"缺少字段: {field}")
            elif field == "tags" and (not isinstance(fm["tags"], list) or len(fm["tags"]) == 0):
                probs.append("tags 为空或格式错误")
        status = fm.get("status", "")
        if status and status not in VALID_STATUSES:
            probs.append(f"非法 status 值: {status}")
        # confidence 合法性检查
        conf = fm.get("confidence", "")
        if conf and conf not in VALID_CONFIDENCES:
            probs.append(f"非法 confidence 值: {conf}")
        # 对知识型页面，confidence 应为必填
        page_type = fm.get("type", "")
        if page_type in ("concept", "source-summary", "comparison", "question") and not conf:
            probs.append("type 为知识型页面但缺少 confidence 字段")
        # contested=true 必须提供 contradictions 列表
        if fm.get("contested") is True:
            contradictions = fm.get("contradictions", [])
            if not isinstance(contradictions, list) or len(contradictions) == 0:
                probs.append("contested=true 但 contradictions 为空或缺失")
        # EXTRACTED 必须附原文摘录
        if fm.get("confidence") == "EXTRACTED" and "摘录" not in body:
            probs.append("confidence=EXTRACTED 但正文缺少原文摘录块")
        for df in ("created", "updated"):
            val = fm.get(df, "")
            if isinstance(val, str) and val:
                try:
                    date.fromisoformat(val[:10])
                except (ValueError, TypeError):
                    probs.append(f"{df} 日期格式非法: {val}")
        if probs:
            issues.append({"path": path, "title": fm.get("title", Path(path).stem), "issues": probs})
    return issues


# --- 检查 6：EXTRACTED 摘录真实性 ---

def _normalize_ws(text: str) -> str:
    """规范化空白字符用于子串匹配。"""
    return re.sub(r'\s+', ' ', text).strip()


def _normalize_unicode(text: str) -> str:
    """规范化 Unicode 字符用于子串匹配。

    将常见弯引号等替换为 ASCII 等价物，避免编码差异导致误报。
    """
    replacements = {
        '\u201c': '"', '\u201d': '"',  # curly double quotes
        '\u2018': "'", '\u2019': "'",  # curly single quotes
        '\u2013': '-', '\u2014': '-',  # en/em dash
        '\u00a0': ' ',                  # non-breaking space
        '\u2026': '...',               # ellipsis
    }
    for old, new in replacements.items():
        text = text.replace(old, new)
    return text


def _extract_quotes(body: str) -> list[tuple[str, str]]:
    """从 body 中提取所有 > 摘录：(内容) 块。返回 [(原始文本, 摘录内容), ...].

    支持多行摘录：> 摘录：第一行
                > 续行
    直到遇到非 > 开头的行或空行为止。
    """
    quotes = []
    lines = body.split("\n")
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        m = re.match(r'>\s*摘录[：:]\s*(.+)', line)
        if m:
            content_lines = [m.group(1).strip()]
            raw_lines = [lines[i].strip()]
            j = i + 1
            while j < len(lines):
                cont = lines[j].strip()
                if cont.startswith(">"):
                    # 去掉 > 前缀，保留内容
                    inner = re.sub(r'^>\s?', '', cont).strip()
                    content_lines.append(inner)
                    raw_lines.append(cont)
                    j += 1
                elif cont == "":
                    j += 1  # 跳过空行
                    break
                else:
                    break
            raw = "\n".join(raw_lines)
            content = " ".join(content_lines)  # 多行合并为单行（空格连接）
            quotes.append((raw, content))
            i = j
        else:
            i += 1
    return quotes


def verify_extracted_quotes(pages, vault_path: Path, max_check: int = 100):
    """验证 EXTRACTED 页面的摘录内容是否真的来自源文。

    只检查 source 字段指向 raw/ 文件的页面。
    """
    issues = []
    checked = 0

    for p in pages:
        fm = p["frontmatter"]
        if fm.get("confidence") != "EXTRACTED":
            continue
        source = fm.get("source", "")
        if not source or not source.startswith("raw/"):
            continue
        if checked >= max_check:
            break

        source_path = vault_path / source
        if not source_path.exists():
            issues.append({
                "page": p["path"],
                "source": source,
                "error": "源文件不存在",
            })
            checked += 1
            continue

        src_text = source_path.read_text(encoding="utf-8", errors="replace")
        src_normalized = _normalize_ws(_normalize_unicode(src_text))
        quotes = _extract_quotes(p.get("body", ""))

        if not quotes:
            continue  # 已由 check_frontmatter 报告缺失

        for raw_line, content in quotes:
            content_normalized = _normalize_ws(_normalize_unicode(content))
            # 摘录内容作为子串在源文中查找
            if content_normalized in src_normalized:
                continue  # 精确匹配
            # 检查前 50 字符是否匹配（摘录可能截断）
            if len(content_normalized) >= 20:
                prefix = content_normalized[:min(50, len(content_normalized))]
                if prefix in src_normalized:
                    continue
            issues.append({
                "page": p["path"],
                "source": source,
                "quote": content[:120],  # 截断显示
                "error": "摘录内容在源文中未找到匹配",
            })

        checked += 1

    return issues

# --- 检查 7：_synthesis/ 升级 ---

def check_synthesis_upgrade(pages, threshold):
    """检查 _synthesis/ 下文件，按父 tag 前缀聚类。

    嵌套 tag（go/gc, go/memory）→ 归于父前缀 group "go"。
    非嵌套 tag（wasm）→ 自身作为 group。
    """
    sp = [p for p in pages if "_synthesis/" in p["path"]]
    if not sp:
        return []

    tag_groups: dict[str, list[str]] = defaultdict(list)
    for p in sp:
        tags = p["frontmatter"].get("tags", [])
        if not isinstance(tags, list):
            continue
        seen_parents = set()
        for t in tags:
            t_str = str(t).strip()
            if not t_str:
                continue
            parent = t_str.split("/")[0]
            if parent not in seen_parents:
                seen_parents.add(parent)
                tag_groups[parent].append(p["path"])

    return [{"parent_tag": t, "count": len(ps), "suggested_domain": f"wiki/{t}/", "pages": ps}
            for t, ps in sorted(tag_groups.items()) if len(ps) >= threshold]


def main():
    if len(sys.argv) < 2:
        print("用法: python3 scripts/lint-stage-b.py <vault_path>", file=sys.stderr)
        sys.exit(1)

    vault_path = Path(sys.argv[1]).resolve()
    if not vault_path.is_dir():
        print(f"ERROR: 路径不是目录: {vault_path}", file=sys.stderr)
        sys.exit(1)

    config = read_schema_config(vault_path)
    pages = discover_pages(vault_path, config["excluded_dirs"])

    similar = check_similar_unlinked(
        pages,
        config["tag_overlap_min"],
        config["max_similar_results"],
    )

    report = {
        "vault": str(vault_path),
        "checked_at": date.today().isoformat(),
        "total_pages": len(pages),
        "orphans": check_orphans(pages),
        "broken_links": check_broken_links(pages),
        "similar_unlinked": similar,
        "tags": check_tags(pages, config["tag_aliases"]),
        "frontmatter_issues": check_frontmatter(pages),
        "synthesis_upgrade": check_synthesis_upgrade(pages, config["synthesis_threshold"]),
        "extracted_quote_issues": verify_extracted_quotes(pages, vault_path),
    }
    report["summary"] = {
        "orphans": len(report["orphans"]),
        "broken_links": len(report["broken_links"]),
        "similar_unlinked": len(report["similar_unlinked"]),
        "tag_single_occurrence": len(report["tags"]["single_occurrence"]),
        "tag_non_lowercase": len(report["tags"]["non_lowercase"]),
        "tag_similar": len(report["tags"]["similar"]),
        "frontmatter_issues": len(report["frontmatter_issues"]),
        "synthesis_upgrade": len(report["synthesis_upgrade"]),
        "extracted_quote_issues": len(report["extracted_quote_issues"]),
    }

    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
