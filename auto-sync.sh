#!/bin/bash
# ============================================
# GitHub → Mac 自動同期スクリプト
# MacBook Proで実行すると、GitHubの変更を
# 定期的に自動でPCに反映する
# ============================================

# --- 設定 ---
REPO_DIR="$HOME/all"                    # 同期先フォルダ（変更OK）
REPO_URL="https://github.com/itksr0824-png/all.git"
SYNC_INTERVAL=30                         # 同期間隔（秒）30=30秒ごと

# --- 初期セットアップ ---
if [ ! -d "$REPO_DIR/.git" ]; then
    echo "[セットアップ] リポジトリをクローン中..."
    git clone "$REPO_URL" "$REPO_DIR"
fi

cd "$REPO_DIR" || exit 1

# 現在のブランチを取得
get_branch() {
    git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main"
}

echo "======================================"
echo " 自動同期 開始"
echo " フォルダ: $REPO_DIR"
echo " 間隔: ${SYNC_INTERVAL}秒ごと"
echo " 停止: Ctrl+C"
echo "======================================"

# --- メインループ ---
while true; do
    BRANCH=$(get_branch)

    # 全リモートブランチを取得
    git fetch --all 2>/dev/null

    LOCAL=$(git rev-parse HEAD 2>/dev/null)
    REMOTE=$(git rev-parse "origin/$BRANCH" 2>/dev/null || echo "")

    if [ -n "$REMOTE" ] && [ "$LOCAL" != "$REMOTE" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 更新を検出 ($BRANCH) → 同期中..."
        git pull origin "$BRANCH" --ff-only 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✓ 同期完了 ($BRANCH)"
        else
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] リセット同期中..."
            git reset --hard "origin/$BRANCH" 2>/dev/null
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✓ 強制同期完了 ($BRANCH)"
        fi
    fi

    # リモートに新しいブランチがあればチェックアウト可能にする
    git remote update --prune 2>/dev/null

    sleep "$SYNC_INTERVAL"
done
