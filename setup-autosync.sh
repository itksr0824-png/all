#!/bin/bash
# ============================================
# Mac自動同期セットアップ（1回だけ実行）
# GitHub → Mac を1分ごとに自動同期 +
# Mac起動時に自動スタート
# ============================================

set -e

REPO_URL="https://github.com/itksr0824-png/all.git"
REPO_DIR="$HOME/all"
SCRIPT_PATH="$REPO_DIR/auto-sync.sh"
PLIST_NAME="com.github.autosync"
PLIST_PATH="$HOME/Library/LaunchAgents/${PLIST_NAME}.plist"

echo "======================================"
echo " GitHub自動同期セットアップ"
echo "======================================"

# 1. リポジトリをクローン
if [ ! -d "$REPO_DIR/.git" ]; then
    echo "[1/3] リポジトリをクローン中..."
    git clone "$REPO_URL" "$REPO_DIR"
else
    echo "[1/3] リポジトリは既に存在"
fi

# 2. auto-sync.shに実行権限を付与
chmod +x "$SCRIPT_PATH"
echo "[2/3] 実行権限を付与"

# 3. LaunchAgent を作成（Mac起動時に自動実行）
mkdir -p "$HOME/Library/LaunchAgents"
cat > "$PLIST_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${PLIST_NAME}</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>${SCRIPT_PATH}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>${REPO_DIR}/auto-sync.log</string>
    <key>StandardErrorPath</key>
    <string>${REPO_DIR}/auto-sync.log</string>
</dict>
</plist>
EOF

# 既存のエージェントを停止してから再ロード
launchctl unload "$PLIST_PATH" 2>/dev/null || true
launchctl load "$PLIST_PATH"
echo "[3/3] 自動起動を設定完了"

echo ""
echo "======================================"
echo " セットアップ完了！"
echo "======================================"
echo ""
echo " ✓ ${REPO_DIR} が1分ごとにGitHubと同期されます"
echo " ✓ Mac再起動後も自動で同期が始まります"
echo ""
echo " ログ確認: tail -f ${REPO_DIR}/auto-sync.log"
echo " 停止: launchctl unload ${PLIST_PATH}"
echo ""
