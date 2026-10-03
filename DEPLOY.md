# AURA 概念站 · 部署说明

> 面向接手的自动化部署 Agent。读完本文即可完成上线，不需要向人类追问技术细节。
> 若确有阻塞项，见文末「需要人类确认的事项」。

---

## 1. 一句话概括

**两个纯静态站点，零构建、零依赖、零后端。** 没有任何 npm / 打包 / 服务端渲染环节，
把所有文件原样放到任意静态托管上即可运行。唯一需要保证的是：**保持目录结构不变**。

---

## 2. 交付物清单

```
aura-sites/
├── index.html                  # 落地页：两张卡片，分别指向两个子站（入口，约 5KB）
├── aura-phone/
│   ├── index.html              # 产品站：硬件规格 / 设计 / 影像 / 购买
│   ├── assets/*.webp           # 4 张产品渲染图
│   └── poster/*.jpg            # 2 张宣传海报（中/英），供下载，页面未引用
└── aura-intelligence/
    ├── index.html              # 能力站：AI 功能 / 同传 / 隐私 / 交互演示
    └── assets/*.webp           # 5 张 AI 概念图
```

| 入口 | 标题 | 主题 |
|---|---|---|
| `/` | AURA — 概念设计 | 落地导航页 |
| `/aura-phone/` | AURA One — 它先于你所想。 | 硬件产品 |
| `/aura-intelligence/` | AURA Intelligence — 懂你，不必说全。 | AI 能力 |

**总体积：约 1.9 MB**（图片已全部转为 WebP，原始 PNG 约 26 MB，不要换回去）。

---

## 3. 技术事实（必须知道，否则容易改坏）

1. **每个页面都是单文件**：HTML + 内联 `<style>` + 内联 `<script>`，没有外部 CSS/JS 文件，没有框架。
2. **零外部请求**：不加载任何 CDN、字体、统计脚本。断网也能完整渲染。
3. **字体使用系统字体栈**：`-apple-system / SF Pro / Helvetica Neue / PingFang SC / Hiragino Sans GB / Microsoft YaHei`。
   故意不引入 Web Font —— 不同系统上字重与中文字形会有差异，这是**预期行为，不是 bug**。
4. **图片全部为相对路径**：`assets/xxx.webp`。因此站点可以部署在**任意子路径**下，无需改配置。
5. **图片依赖两个 CSS 特性才能"无缝融入黑底"**：
   - `mix-blend-mode: screen`
   - `mask-image` + `mask-composite: intersect`
   若被剥离，图片会露出方形边界（功能不坏，但观感变差）。**不要用会重写 CSS 的工具做二次处理。**
6. **首屏入场动画依赖内联脚本**：脚本会给 `<html>` 加 `anim` 类。内容默认是可见的，
   脚本正常时才隐藏并做入场动画 —— 即使脚本被移除，页面依然是可读的（渐进增强）。

---

## 4. 部署方式

### 方式 A：GitHub Pages（本项目首选）

```bash
cd aura-sites
git init -b main
git add .
git commit -m "AURA concept sites"
git remote add origin git@github.com:<USER>/<REPO>.git
git push -u origin main
```

然后开启 Pages：**仓库 Settings → Pages → Source 选 `Deploy from a branch` → Branch 选 `main` / `/ (root)` → Save**。
约 1 分钟后访问 `https://<USER>.github.io/<REPO>/`。

已内置 `.nojekyll`，Jekyll 不会介入处理，无需额外配置。
落地页里的相对链接（`aura-phone/`、`aura-intelligence/`）在 Pages 的仓库子路径下可直接工作。

**推荐：仓库内已带 `publish.sh`，一条命令完成创建 + 推送 + 开 Pages：**

```bash
# 前置（只需一次）
brew install gh && gh auth login

# 发布
cd aura-sites && bash publish.sh            # 默认仓库名 aura-sites
bash publish.sh my-custom-name              # 或自定义仓库名
```

等价的手动命令（不想用脚本时）：

```bash
gh repo create <REPO> --public --source=. --push
gh api -X POST "repos/{owner}/{repo}/pages" -f "source[branch]=main" -f "source[path]=/"
```

### 方式 B：任意静态托管（Vercel / Netlify / Cloudflare Pages）

无构建命令，直接指定：

- **Build command**：留空
- **Output / Publish directory**：`aura-sites`（或仓库根目录）
- **Framework preset**：None / Other

### 方式 C：自建 Nginx

```nginx
server {
    listen 80;
    server_name example.com;
    root /var/www/aura-sites;
    index index.html;

    location / {
        try_files $uri $uri/ $uri/index.html =404;   # 子目录要能落到 index.html
    }

    types {
        text/html   html;
        image/webp  webp;
        image/jpeg  jpg;
    }
    default_type application/octet-stream;
    gzip on;
    gzip_types text/html text/css application/javascript image/svg+xml;
}
```

### 方式 D：对象存储 + CDN（OSS / COS / S3）

直接同步整个目录，并把 **首页文档设为 `index.html`**：

```bash
# 以腾讯云 COS 为例
coscli sync ./aura-sites/ cos://<bucket>/ --delete
```

注意：对象存储默认把 `/aura-phone/` 当目录对象处理，需开启「静态网站」功能并把索引文档设为 `index.html`，
否则访问 `/aura-phone/` 会 404 或直接下载文件。

---

## 5. 部署后自检（必须逐项验证）

1. **三个入口返回 200 且不是目录列表**：`/`、`/aura-phone/`、`/aura-intelligence/`
2. **9 张图片全部 200**：
   - `aura-phone/assets/` 下 4 个：`img-hero`、`img-chip`、`img-camera`、`img-silhouette`
   - `aura-intelligence/assets/` 下 5 个：`ai-core`、`ai-voice`、`ai-ambient`、`ai-privacy`、`ai-create`
   - 全部为 `.webp` 后缀
3. **`.webp` 的 MIME 类型正确**（`image/webp`）。类型错误会导致图片不显示。
4. **首屏文字可见**（不是一片黑）。这是最常见的事故点：若托管平台"优化"掉了内联脚本或 CSS，会表现为白屏/黑屏。
5. **无控制台报错**，无 404 请求。
6. **移动端**（375px 宽）无横向滚动条。

> 快速批量检查图片状态码：
> ```bash
> for f in $(cd aura-sites && find . -name "*.webp"); do
>   printf "%s -> %s\n" "$f" "$(curl -o /dev/null -s -w '%{http_code} %{content_type}' "https://<域名>/${f#./}")"
> done
> ```

---

## 6. 已知坑与对策

| 现象 | 原因 | 对策 |
|---|---|---|
| 首屏一片黑、文字不出现 | 平台剥离了内联 `<script>`，`html.anim` 未移除但入场动画未接管 | 关闭 HTML 压缩/优化；或直接删除 `<script>` 那一段兜底逻辑之外的动画类机制 |
| 图片出现方形边界、与黑底不融合 | `mix-blend-mode` / `mask-composite` 被 CSS 压缩器丢弃 | 关闭高级 CSS 优化（如 cssnano 的 `normalizeWhitespace` 以外的改写） |
| 访问 `/aura-phone` 404 | 缺少结尾斜杠且服务器未做目录索引 | 服务器配置 `try_files`，或统一用带斜杠的 URL |
| 图片不显示但状态 200 | MIME 类型不对（返回 `application/octet-stream`） | 在服务器/托管平台补充 `image/webp` 映射 |
| 中文字体在高版本 Windows 上变样 | 系统无 PingFang/冬青黑体，回退到 Microsoft YaHei | 预期行为，不要为此引入 Web Font |
| 页面滚动时数字停留在 0 或异常值 | 数字滚动动画被中断（极端环境） | HTML 里已写好静态兜底值，脚本异常时显示正确数字，无需处理 |

---

## 7. 内容需要改时，改哪里

均为**直接编辑对应 `index.html`**，无构建步骤：

| 想改的内容 | 位置 |
|---|---|
| 品牌名 / 产品名 | 全局搜索 `AURA One`、`AURA`、`AURA Intelligence` |
| 主标语 | `aura-phone/` 搜 `它先于你所想`；`aura-intelligence/` 搜 `懂你，不必说全` |
| 配色（紫/青/琥珀渐变、背景、灰阶） | 每个 HTML 顶部的 `:root { --cyan / --violet / --amber / --bg / --fg ... }` |
| 价格与预约时间 | 搜 `7,999`、`10 月 17 日` |
| 规格参数表 | 搜 `spec-list`（`aura-phone`） |
| AI 能力文案与演示脚本 | `aura-intelligence` 搜 `SCENES`（交互演示器的三个场景数据）、`LANGS`（同传演示的四种语言） |
| 落地页两张卡片的标题与描述 | 根目录 `index.html` 的 `.grid` 区块 |
| 海报 | `aura-phone/poster/` 下的 JPG，替换同名文件即可 |

改完文案后**不需要**任何构建，直接提交即可。

---

## 8. 明确不要做的事

1. **不要重命名 `assets/` 里的任何文件** —— 文件名写死在 HTML 里。
2. **不要引入构建流程**（webpack / vite / Tailwind），本站的设计前提就是零构建。
3. **不要把三个页面合并成一个**，也不要把图片转成 base64 内联（会让单文件膨胀到数 MB）。
4. **不要删掉页脚的免责声明** —— 站内图片由 AI 生成，文案与价格均为虚构示意，该声明是刻意保留的合规说明。
5. **不要把 WebP 换回 PNG**（体积会从 1.9MB 涨到 26MB）。
6. **不要在公开部署时保留真实公司/商标**：`AURA` 为虚构品牌名，如与既有商标冲突需先更名（搜索替换即可）。

---

## 9. 可选优化（非必须）

- **加缓存头**：静态资源 `Cache-Control: public, max-age=31536000, immutable`（文件名带版本号时更安全）。
- **加 404 页面**：复制根 `index.html` 改文案即可，纯静态即可应对。
- **给落地页加 OG 图**：用 `aura-phone/poster/aura-one-poster-cn.jpg` 作为 `og:image`，社交分享时更好看。
- **两站互链**：目前产品站与能力站之间没有互相跳转，仅通过落地页连接。若需要，在各自导航栏加一条链接指向另一个站点即可。

---

## 10. 验收标准（Definition of Done）

- [ ] 三个入口均可访问，标题分别显示为「AURA — 概念设计」「AURA One — 它先于你所想。」「AURA Intelligence — 懂你，不必说全。」
- [ ] 9 张 WebP 图片全部正常显示，且与黑色背景自然融合、看不到图片边界
- [ ] 移动端（375px）无横向滚动，按钮与文字不重叠
- [ ] `aura-intelligence` 页面的「实时同传」语言切换可点击切换文本
- [ ] `aura-intelligence` 页面的「任务演示器」滚动到该区域时步骤能逐条出现
- [ ] 控制台无报错，网络面板无 404

---

## 11. 需要人类确认的事项

以下信息 Agent 无法自行决定，部署前需向人类确认：

1. **目标平台与仓库名**（如 GitHub Pages 的 `<user>/<repo>`）。
2. **是否公开发布**：站内含虚构价格（¥7,999）与虚构发布日（10 月 17 日），若面向公众，建议先替换为占位文案或加上更醒目的"概念演示"标识。
3. **是否已有域名**，是否需要配置 CNAME。
4. **`AURA` 品牌名是否需要更换**（避免与既有商标冲突）。

---

*文档生成于 2026-10-03，对应当前交付物版本。*
