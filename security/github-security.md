# GitHub セキュリティ設定

## 必須（今すぐやる）

### 1. 2ファクタ認証（2FA）を有効化
- GitHub → Settings → Password and authentication → Two-factor authentication → Enable

### 2. リポジトリをPrivateにする
- リポジトリ → Settings → General → Danger Zone → Change visibility → Private
- 会社の情報が外部に漏れないようにする

### 3. Personal Access Tokenの管理
- 不要なトークンは削除: Settings → Developer settings → Personal access tokens
- トークンには最小限の権限だけ付与
- 有効期限を設定（90日推奨）

## 推奨

### 4. ブランチ保護
- mainブランチへの直接プッシュを制限
- Settings → Branches → Add branch protection rule

### 5. Dependabot有効化
- セキュリティ脆弱性の自動検出
- Settings → Code security → Enable Dependabot alerts

### 6. Secret Scanning
- コードに誤ってAPIキーを含めた場合に通知
- Settings → Code security → Secret scanning → Enable
