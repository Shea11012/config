---
language: zh
description: ""
excluded_dirs:
  - .obsidian
  - .trash
  - raw
  - assets
  - config
  - Excalidraw
  - mermaid
tag_aliases: {}
tag_overlap_min: 2
max_similar_results: 50
synthesis_threshold: 5
---

# Wiki Schema

## 关于这个知识库

<!-- 写一段自然语言描述仓库用途。 -->

## 配置说明

### tag_aliases — Tag 别名映射
key 是被映射的别名，value 是规范形式。
```yaml
tag_aliases:
  k8s: kubernetes
  golang: go
```

### excluded_dirs — 不参与扫描的目录

### tag_overlap_min — tag 重叠阈值
两个页面共享 ≥ 此值的 tag 时，lint 标记为「相似但未关联」。默认 2。

### max_similar_results — 相似但未关联结果上限
单次 lint 最多返回的对数。默认 50。

### synthesis_threshold — 综合暂存升级阈值
`_synthesis/` 下共享同一父 tag 前缀的文件数达此值时，建议升级为独立领域。默认 5。

---

所有规则（Tag 惯例、Frontmatter 规范、目录结构等）详见 mxy-wiki SKILL.md。本文件仅保留 vault 专属配置。别名词表按需在下方追加。
