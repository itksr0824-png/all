# Remote Claude Code Setup

MacBook ProでClaude Codeを常時起動し、スマホからリモート操作するためのセットアップガイド。

## 推奨構成

```
[スマホ] ---(Tailscale VPN)--- [自宅 MacBook Pro + Claude Code]
```

## セットアップ手順

### 1. Mac側の準備

```bash
# Homebrewがなければインストール
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# tmuxインストール（セッション維持用）
brew install tmux

# Claude Codeインストール
npm install -g @anthropic-ai/claude-code

# Tailscaleインストール（リモートアクセス用）
brew install --cask tailscale
```

### 2. macOSリモートログイン有効化

```
システム設定 → 一般 → 共有 → リモートログイン → ON
```

### 3. Tailscale設定

1. MacでTailscaleを起動しログイン
2. スマホにもTailscaleをインストールし同じアカウントでログイン
3. Tailscale管理画面でMacのIPアドレスを確認

### 4. tmuxでClaude Codeを起動

```bash
# 新しいtmuxセッションを作成
tmux new -s claude

# Claude Codeを起動
claude

# tmuxから一時的に離脱: Ctrl+B → D
# 再接続: tmux attach -t claude
```

### 5. スマホからSSH接続

```bash
ssh ユーザー名@TailscaleのIP
tmux attach -t claude
```

## スマホ用SSHアプリ

- **iOS**: Termius, Blink Shell
- **Android**: Termius, JuiceSSH

## Tips

- `tmux` を使えばMacのディスプレイを閉じてもセッションは維持される
- Tailscaleは無料プランで十分
- Macのスリープを防ぐ: `システム設定 → ディスプレイ → 詳細設定 → 電源アダプタ接続中のスリープを防止`
- Claude Code Web (claude.ai/code) も併用するとさらに便利
