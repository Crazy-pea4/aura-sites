# AURA 概念站

未来 AI 手机的概念设计稿，包含一个产品页和一个 AI 能力页。

| 路径 | 内容 |
|---|---|
| `/` | 落地页（两张入口卡片） |
| `/aura-phone/` | **AURA One** · 硬件产品页：设计、影像、规格、购买 |
| `/aura-intelligence/` | **AURA Intelligence** · AI 能力页：同传、主动智能、隐私、交互演示 |

## 本地预览

零构建、零依赖，起任意静态服务器即可：

```bash
cd aura-sites
python3 -m http.server 8000
# 打开 http://localhost:8000
```

> 建议用本地服务器打开，而不是直接双击 `index.html`——`file://` 协议下部分浏览器的
> `mix-blend-mode` 渲染会与线上不一致。

## 部署

见 **[DEPLOY.md](./DEPLOY.md)**，内含 GitHub Pages / Nginx / 对象存储的完整步骤、
自检清单与已知坑。

发到 GitHub Pages 最快的方式（仓库内已带脚本）：

```bash
brew install gh && gh auth login   # 只需一次
bash publish.sh                    # 创建仓库 + 推送 + 开启 Pages
```

## 技术要点

- 纯静态：HTML + 内联 CSS + 内联 JS，无框架、无构建、无外部请求
- 图片：WebP，全部相对路径，可部署在任意子路径
- 字体：系统字体栈（不加载 Web Font）
- 动效：`IntersectionObserver` 驱动的滚动入场，采用渐进增强——脚本失效时内容仍可见

## 说明

本站为**概念设计稿**。品牌名、规格、价格、发布信息均为虚构示意；站内图片由 AI 生成。
页脚的免责声明请勿删除。
