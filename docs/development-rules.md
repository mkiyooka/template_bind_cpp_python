# 開発ルール

## 📝 コミット前チェック

### Python

```bash
task check  # ruff + pyright + pytest
```

### C++

```bash
cmake --build build --target check  # format + lint + cppcheck
```

## 🔄 定期実行

- **毎日**: `task check` / `make check`
- **PR前**: 全チェック + テスト実行
- **数回のcommit毎**: `nox` による全環境テスト

## 🚫 必須禁止事項

- ❌ **フォーマット未実行** でのコミット
- ❌ **型エラー** / **lint警告** の放置
- ❌ **テスト失敗** 状態でのPR
- ❌ **nanobindサブモジュール** の直接変更

## ✅ 推奨事項

- ✅ **pre-commit** 活用（自動品質チェック）
- ✅ **VSCodeデバッグ** 機能の活用
- ✅ **cppcheck warning** の積極的修正
- ✅ **型ヒント** 付与（Python関数）
