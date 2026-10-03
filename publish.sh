#!/usr/bin/env bash
# 一键把本站发布到 GitHub Pages。
#
# 用法：
#   bash publish.sh                # 仓库名默认 aura-sites
#   bash publish.sh my-site-name   # 自定义仓库名
#
# 前置条件（只需做一次）：
#   brew install gh && gh auth login
set -euo pipefail

REPO_NAME="${1:-aura-sites}"
cd "$(dirname "$0")"

# --- 环境检查 ---
if ! command -v gh >/dev/null 2>&1; then
  cat <<'EOF'
❌ 未检测到 GitHub CLI（gh）。

请先执行：
  brew install gh
  gh auth login      # 选择 GitHub.com → HTTPS → 浏览器登录

完成后重新运行本脚本。
EOF
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  cat <<'EOF'
❌ GitHub CLI 尚未登录。

请先执行（会打开浏览器授权）：
  gh auth login

完成后重新运行本脚本。
EOF
  exit 1
fi

OWNER="$(gh api user -q .login)"
echo "账号：$OWNER"
echo "仓库：$REPO_NAME"
echo

# --- 确保本地已提交 ---
if [ ! -d .git ]; then
  git init -b main -q
fi
if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
  git add -A
  git -c user.name="AURA Deploy" -c user.email="deploy@local" \
    commit -q -m "AURA concept sites"
fi
git branch -M main

# --- 创建远端并推送 ---
if git remote get-url origin >/dev/null 2>&1; then
  echo "已存在 origin，直接推送…"
  git push -u origin main
elif gh repo view "$OWNER/$REPO_NAME" >/dev/null 2>&1; then
  echo "远端仓库已存在，关联后推送…"
  git remote add origin "git@github.com:$OWNER/$REPO_NAME.git"
  git push -u origin main
else
  echo "创建远端仓库并推送…"
  gh repo create "$REPO_NAME" --public --source=. --remote=origin --push
fi

# --- 开启 Pages ---
echo "开启 GitHub Pages…"
if gh api -X POST "repos/$OWNER/$REPO_NAME/pages" \
     -f "source[branch]=main" -f "source[path]=/" >/dev/null 2>&1; then
  echo "Pages 已开启。"
else
  echo "⚠️  自动开启失败（可能已开启）。如站点未上线，请到"
  echo "   https://github.com/$OWNER/$REPO_NAME/settings/pages"
  echo "   手动选择 Source = Deploy from a branch，Branch = main / (root)，Save。"
fi

echo
echo "✅ 发布完成"
echo "   仓库：https://github.com/$OWNER/$REPO_NAME"
echo "   站点：https://$OWNER.github.io/$REPO_NAME/"
echo
echo "首次部署通常需要 1-2 分钟生效。"
