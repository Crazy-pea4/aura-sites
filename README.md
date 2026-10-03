# AURA 概念站

未来 AI 产品的概念设计稿，共三份，共用一套设计语言。

| 路径 | 内容 |
|---|---|
| `/` | 落地页（三张入口卡片） |
| `/aura-phone/` | **AURA One** · 硬件产品页：设计、影像、规格、购买 |
| `/aura-intelligence/` | **AURA Intelligence** · AI 能力页：同传、主动智能、隐私、交互演示 |
| `/aura-prism/` | **AURA Prism** · 概念机：一台没有屏幕的手机，界面投射进空气 |

## 本地预览

零构建、零依赖，起任意静态服务器即可：

```bash
cd aura-sites
python3 -m http.server 8000
# 打开 http://localhost:8000
```

> 建议用本地服务器打开，而不是直接双击 `index.html`——`file://` 协议下部分浏览器的
> `mix-blend-mode` 渲染会与线上不一致。

## 更新线上

见 **[DEPLOY.md](./DEPLOY.md)**，内含 GitHub Pages / Nginx / 对象存储的完整步骤、
自检清单与已知坑。

发到 GitHub Pages 最快的方式（仓库内已带脚本）：

```bash
brew install gh && gh auth login   # 只需一次
bash publish.sh                    # 创建仓库 + 推送 + 开启 Pages
```

## 导出交付包（需要给别的 agent，或换平台部署时）

本仓库本身就是完整可部署的，通常**不需要**额外的 zip —— 对方直接 clone 即可。
确有需要（离线交付、换托管平台）时现打包：

```bash
cd /Users/yemeng/Code/aura
zip -r -X aura-sites.zip aura-sites -x "aura-sites/.git/*" -x "*.DS_Store"
```

`-x` 用来排除 `.git` 目录，否则包体积会翻倍。

## 技术要点

- 纯静态：HTML + 内联 CSS + 内联 JS，无框架、无构建、无外部请求
- 图片：WebP，全部相对路径，可部署在任意子路径
- 字体：系统字体栈（不加载 Web Font）
- 动效：`IntersectionObserver` 驱动的滚动入场，采用渐进增强——脚本失效时内容仍可见

## 说明

本站为**概念设计稿**。品牌名、规格、价格、发布信息均为虚构示意；站内图片由 AI 生成。
页脚的免责声明请勿删除。
