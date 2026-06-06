# 网页提取工具对比

## 测试案例：dtm.pub 缓存一致性文档

URL: `https://dtm.pub/app/cache.html`

### web_extract

- 输出：~5KB，LLM 摘要版
- 丢失内容：4种方案的完整描述、从库延时处理、5种场景详细分析、正确性证明、强一致性前提辨析
- 优点：速度快，不需要额外安装
- 适用：简单页面、API 端点、不需要完整结构的场景

### defuddle

- 输出：~23KB，完整原文 markdown
- 保留内容：全部章节、代码块、表格、列表结构
- 缺点：
  - `defuddle parse <url>` 直接 fetch 可能失败（SSL、反爬等）
  - 降级方案：`curl -skL <url> -o /tmp/page.html && defuddle parse /tmp/page.html --md`
  - `-k` 跳过 SSL 验证，适用于自签名证书的站点
- 适用：静态技术文档、博客文章、需要完整内容的场景

### browser_navigate

- 适用：动态页面、SPA、需要点击/滚动/JS 渲染的页面
- 缺点：速度最慢，消耗 token 最多
- 不适用于：纯静态文档（杀鸡用牛刀）

## 选择决策树

```
素材来源是 URL？
  ├─ 静态文档/博客 → defuddle（优先）
  │   └─ defuddle fetch 失败 → curl -k 下载 + defuddle 解析本地文件
  │       └─ curl 也失败 → web_extract
  ├─ API 端点/简单页面 → web_extract
  └─ 动态页面/需要交互 → browser_navigate
```

## defuddle 安装

```bash
npm install -g defuddle
```
