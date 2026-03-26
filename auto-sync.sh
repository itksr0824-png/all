#!/bin/bash
# ============================================
# GitHub → Mac 自動同期スクリプト
# MacBook Proで実行すると、GitHubの変更を
# 定期的に自動でPCに反映する
# ============================================

# --- 設定 ---
REPO_DIR="$HOME/all"                    # 同期先フォルダ（変更OK）
REPO_URL="https://github.com/itksr0824-png/all.git"
SYNC_INTERVAL=60                         # 同期間隔（秒）60=1分ごと
BRANCH="main"                            # 同期するブランチ

# --- 初期セットアップ ---
if [ ! -d "$REPO_DIR/.git" ]; then
    echo "[セットアップ] リポジトリをクローン中..."
    git clone "$REPO_URL" "$REPO_DIR"
fi

cd "$REPO_DIR" || exit 1

echo "======================================"
echo " 自動同期 開始"
echo " フォルダ: $REPO_DIR"
echo " 間隔: ${SYNC_INTERVAL}秒ごと"
echo " 停止: Ctrl+C"
echo "======================================"

# --- メインループ ---
while true; do
    # リモートの変更を確認
    git fetch origin "$BRANCH" 2>/dev/null

    LOCAL=$(git rev-parse HEAD 2>/dev/null)
    REMOTE=$(git rev-parse "origin/$BRANCH" 2>/dev/null)

    if [ "$LOCAL" != "$REMOTE" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 更新を検出 → 同期中..."
        git pull origin "$BRANCH" --ff-only 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✓ 同期完了"
        else
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✗ 競合あり - 手動確認が必要"
        fi
    fi

    sleep "$SYNC_INTERVAL"
done
