# 開発ルール

## 📝 品質チェック

コミット前に必ずチェックを実行してください。

### 一括チェック

```bash
task check        # 全体（Python + C++）
task check-py     # Python（ruff format/lint + pyright + pytest）  
task check-cpp    # C++（clang-format/tidy + cppcheck + ctest）
```

### 個別チェック

```bash
# フォーマット
task format-py    # Python: ruff format
task format-cpp   # C++: clang-format

# リント
task lint-py      # Python: ruff check
task lint-cpp     # C++: clang-tidy

# 型チェック・静的解析
task typecheck-py # Python: pyright
task cppcheck     # C++: cppcheck

# テスト
task test-py      # Python: pytest
task test-cpp     # C++: ctest
```

## 🏗️ コーディング規約

### Python

- **行の長さ**: 最大88文字
- **フォーマット**: ruff（自動適用）
- **型ヒント**: すべての関数に必須
- **docstring**: パブリックAPIに必須（NumPy形式）
- **インポート**: ruffで自動整理

### C++

- **フォーマット**: clang-format（自動適用）
- **静的解析**: clang-tidy準拠
- **命名規則**: 既存コードのパターンに従う
- **ヘッダーガード**: `#pragma once`推奨

## 🔄 コミット・プルリクエストルール

### コミットメッセージ

Conventional Commits形式を使用：

```text
<type>(<scope>): <description>

[optional body]
```

#### type

- `feat`: 新機能追加
- `fix`: バグ修正  
- `docs`: ドキュメント変更
- `style`: フォーマット変更（動作に影響なし）
- `refactor`: リファクタリング
- `test`: テスト追加・修正
- `chore`: ビルド・依存関係更新

#### scope例

- `bind`: Python-C++バインディング
- `core`: C++コアエンジン
- `cli`: CLI
- `docs`: ドキュメント

#### 例

```text
feat(cli): データ処理サブコマンドを追加
fix(bind): メモリリーク問題を修正
docs: インストールガイドを更新
```

### プルリクエスト

- 変更内容の明確な説明
- 解決する問題と解決方法を記載
- レビュー前に品質チェック実行必須

## 🧪 テスト要件

### Pythonテスト

- **フレームワーク**: pytest
- **カバレッジ**: 新機能は必須
- **実行**: `task test-py`

### C++テスト

- **フレームワーク**: 既存のテストフレームワーク使用
- **単体テスト**: 新機能は必須
- **実行**: `task test-cpp`

## 🔧 開発フロー

1. **ブランチ作成**: `feature/xxx` または `fix/xxx`
2. **開発**: 小さな単位でコミット
3. **品質チェック**: `task check` で全チェック実行
4. **プルリクエスト**: レビューを依頼
5. **マージ**: レビュー完了後

---

環境構築・ツール詳細は [developer-guide.md](developer-guide.md) を参照してください。
