#!/bin/bash
# ============================================
# MacBook Pro セキュリティ強化スクリプト
# 会社経営用 - 1回実行するだけ
# ============================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

step() { echo -e "${GREEN}[✓] $1${NC}"; }
warn() { echo -e "${YELLOW}[!] $1${NC}"; }

echo "======================================"
echo " MacBook Pro セキュリティ強化"
echo "======================================"
echo ""

# ========== 1. FileVault（ディスク暗号化）==========
FV_STATUS=$(fdesetup status 2>/dev/null)
if echo "$FV_STATUS" | grep -q "On"; then
    step "FileVault: 有効済み（ディスク暗号化ON）"
else
    warn "FileVault: 無効 → 有効化してください"
    echo "    システム設定 → プライバシーとセキュリティ → FileVault → ON"
    echo "    ※PCが盗まれてもデータが読まれない"
fi

# ========== 2. ファイアウォール ==========
FW_STATUS=$(sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null)
if echo "$FW_STATUS" | grep -q "enabled"; then
    step "ファイアウォール: 有効済み"
else
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
    step "ファイアウォール: 有効化完了"
fi

# ステルスモード（外部からのping等に応答しない）
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
step "ステルスモード: 有効化"

# ========== 3. 自動ロック ==========
# スクリーンセーバー後すぐにパスワード要求
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0
step "画面ロック: スクリーンセーバー後すぐにパスワード要求"

# ========== 4. 自動アップデート ==========
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool true
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall -bool true
step "自動アップデート: セキュリティアップデートを自動適用"

# ========== 5. リモートログイン制限 ==========
# 自分のユーザーだけSSH許可
CURRENT_USER=$(whoami)
sudo dseditgroup -o edit -a "$CURRENT_USER" -t user com.apple.access_ssh 2>/dev/null
step "SSH: ${CURRENT_USER} のみ許可"

# ========== 6. 共有設定の確認 ==========
# AirDrop受信を連絡先のみに
defaults write com.apple.sharingd DiscoverableMode -string "Contacts Only"
step "AirDrop: 連絡先のみに制限"

# ========== 7. Safariセキュリティ ==========
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false
step "Safari: ダウンロード後の自動実行を無効化"

# ========== 8. Gatekeeperを確認 ==========
GK_STATUS=$(spctl --status 2>/dev/null)
if echo "$GK_STATUS" | grep -q "enabled"; then
    step "Gatekeeper: 有効（未認証アプリをブロック）"
else
    sudo spctl --master-enable
    step "Gatekeeper: 有効化完了"
fi

echo ""
echo "======================================"
echo -e "${GREEN} セキュリティ強化完了${NC}"
echo "======================================"
echo ""
echo "手動で確認すべき項目:"
echo "  □ FileVault（ディスク暗号化）がONか確認"
echo "  □ Apple IDで2ファクタ認証が有効か確認"
echo "  □ Macのログインパスワードが十分強いか確認（12文字以上推奨）"
echo "  □ 「Macを探す」がONか確認"
echo ""
