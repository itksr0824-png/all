# スマホ側セットアップ手順

## iOS の場合

### 1. Tailscale をインストール
- App Store で「Tailscale」を検索してインストール
- Mac と同じアカウントでログイン

### 2. SSH アプリをインストール（いずれか1つ）

#### Termius（推奨・無料）
- App Store で「Termius」を検索してインストール
- 新しいホストを追加:
  - Hostname: `tailscale ip -4` で確認したIP、または `Macのホスト名.tail*****.ts.net`
  - Username: Mac のユーザー名
  - Password: Mac のログインパスワード

#### Blink Shell（有料・高機能）
- App Store で「Blink Shell」を検索

### 3. 接続方法
```
ssh ユーザー名@TailscaleのIP
tmux attach -t claude
```

## Android の場合

### 1. Tailscale をインストール
- Google Play で「Tailscale」を検索してインストール
- Mac と同じアカウントでログイン

### 2. SSH アプリをインストール
- Google Play で「Termius」を検索してインストール
- 設定は iOS と同じ

### 3. 接続方法
```
ssh ユーザー名@TailscaleのIP
tmux attach -t claude
```

## SSH鍵認証の設定（パスワード入力を省略）

スマホのSSHアプリで鍵ペアを生成し、公開鍵をMacに登録すると毎回パスワードを入れなくて済みます。

Termius の場合:
1. 設定 → Keychain → Generate Key
2. 生成された公開鍵をコピー
3. Mac で `~/.ssh/authorized_keys` に追加
