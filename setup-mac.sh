#!/bin/bash
set -e

echo "======================================"
echo " Claude Code リモートセットアップ"
echo "======================================"
echo ""

# 色付き出力
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

step() { echo -e "\n${GREEN}[✓] $1${NC}"; }
warn() { echo -e "${YELLOW}[!] $1${NC}"; }
fail() { echo -e "${RED}[✗] $1${NC}"; }

# ========== 1. Homebrew ==========
step "Homebrewを確認中..."
if ! command -v brew &>/dev/null; then
    warn "Homebrewをインストールします..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    step "Homebrew は既にインストール済み"
fi

# ========== 2. tmux ==========
step "tmuxを確認中..."
if ! command -v tmux &>/dev/null; then
    brew install tmux
    step "tmux インストール完了"
else
    step "tmux は既にインストール済み"
fi

# ========== 3. Node.js ==========
step "Node.jsを確認中..."
if ! command -v node &>/dev/null; then
    brew install node
    step "Node.js インストール完了"
else
    step "Node.js は既にインストール済み ($(node -v))"
fi

# ========== 4. Claude Code ==========
step "Claude Codeを確認中..."
if ! command -v claude &>/dev/null; then
    npm install -g @anthropic-ai/claude-code
    step "Claude Code インストール完了"
else
    step "Claude Code は既にインストール済み"
fi

# ========== 5. Tailscale ==========
step "Tailscaleを確認中..."
if ! [ -d "/Applications/Tailscale.app" ] && ! command -v tailscale &>/dev/null; then
    brew install --cask tailscale
    step "Tailscale インストール完了"
    warn "Tailscale.appを起動してログインしてください"
else
    step "Tailscale は既にインストール済み"
fi

# ========== 6. リモートログイン有効化 ==========
step "リモートログイン(SSH)を有効化中..."
SSH_STATUS=$(sudo systemsetup -getremotelogin 2>/dev/null | grep -i "on" || true)
if [ -z "$SSH_STATUS" ]; then
    sudo systemsetup -setremotelogin on
    step "リモートログイン 有効化完了"
else
    step "リモートログイン は既に有効"
fi

# ========== 7. スリープ防止 ==========
step "電源接続時のスリープを防止設定中..."
sudo pmset -c sleep 0
sudo pmset -c disksleep 0
sudo pmset -c displaysleep 15
step "スリープ防止設定完了（ディスプレイは15分で消灯、本体はスリープしない）"

# ========== 8. tmux設定 ==========
step "tmux設定ファイルを作成中..."
cat > ~/.tmux.conf << 'TMUX_CONF'
# セッションが切れても維持
set -g default-terminal "screen-256color"
set -g history-limit 50000
set -g mouse on

# 自動再接続のためのキープアライブ
set -g escape-time 10
set -sg repeat-time 600

# ステータスバー
set -g status-bg colour235
set -g status-fg white
set -g status-left '#[fg=green]#S '
set -g status-right '#[fg=yellow]%Y-%m-%d %H:%M'
TMUX_CONF
step "tmux設定完了"

# ========== 9. 自動起動スクリプト ==========
step "自動起動スクリプトを作成中..."
mkdir -p ~/bin
cat > ~/bin/start-claude.sh << 'START_SCRIPT'
#!/bin/bash
# Claude Code を tmux セッションで起動するスクリプト

SESSION_NAME="claude"

# 既存セッションがあるか確認
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "セッション '$SESSION_NAME' は既に実行中です"
    echo "接続: tmux attach -t $SESSION_NAME"
else
    echo "Claude Code セッションを起動中..."
    tmux new-session -d -s "$SESSION_NAME" 'claude'
    echo "セッション '$SESSION_NAME' を起動しました"
    echo "接続: tmux attach -t $SESSION_NAME"
fi
START_SCRIPT
chmod +x ~/bin/start-claude.sh
step "~/bin/start-claude.sh を作成完了"

# ========== 10. ログイン時自動起動(LaunchAgent) ==========
step "ログイン時自動起動を設定中..."
mkdir -p ~/Library/LaunchAgents
cat > ~/Library/LaunchAgents/com.claude.autostart.plist << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.claude.autostart</string>
    <key>ProgramArguments</key>
    <array>
        <string>${HOME}/bin/start-claude.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardOutPath</key>
    <string>${HOME}/.claude-autostart.log</string>
    <key>StandardErrorPath</key>
    <string>${HOME}/.claude-autostart.log</string>
</dict>
</plist>
PLIST
launchctl load ~/Library/LaunchAgents/com.claude.autostart.plist 2>/dev/null || true
step "ログイン時自動起動設定完了"

# ========== 完了 ==========
echo ""
echo "======================================"
echo -e "${GREEN} セットアップ完了！${NC}"
echo "======================================"
echo ""
echo "次のステップ:"
echo ""
echo "  1. Tailscaleを起動してログイン"
echo "     open /Applications/Tailscale.app"
echo ""
echo "  2. Claude Codeを起動"
echo "     ~/bin/start-claude.sh"
echo ""
echo "  3. スマホ側の設定:"
echo "     - Tailscaleをインストール → 同じアカウントでログイン"
echo "     - SSHアプリ(Termius推奨)をインストール"
echo "     - 接続先: ssh $(whoami)@$(hostname).tail*****.ts.net"
echo "     - 接続後: tmux attach -t claude"
echo ""
echo "  TailscaleのIPアドレス確認:"
echo "     tailscale ip -4"
echo ""
