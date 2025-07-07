# 多機能ToDoリスト・メモアプリ開発指示書

## プロジェクト概要
SwiftUIを使用した高機能なToDoリスト・メモアプリケーションの開発。
目的：SwiftUIでのUI構築とデータ永続化の基礎習得。

## 技術スタック・要件

### 必須技術
- **SwiftUI**: 宣言的UIフレームワークを使用した現代的なUI設計
- **SwiftData**: Apple純正のデータ管理（Core Dataの後継）
- **WidgetKit**: ホーム画面ウィジェット機能
- **Live Activities**: ロック画面でのリアルタイム表示機能

### アーキテクチャ指針
- MVVM パターンの採用
- SwiftData の `@Model` を使用したデータモデル設計
- `@Query` と `@Environment(\.modelContext)` を活用したデータバインディング

## 機能要件

### 基本機能
1. タスクの追加・編集・削除
2. メモ機能（リッチテキスト対応）
3. カテゴリ分類
4. 完了状態の管理
5. 優先度設定

### 拡張機能
1. ホーム画面ウィジェット（今日のタスク表示）
2. ライブアクティビティ（集中モードタイマー）
3. 検索・フィルタリング機能
4. 通知機能
5. データエクスポート・インポート

## コーディング規約

### Swift / SwiftUI
- Swift 6.0 の最新機能を活用
- `async/await` を使用した非同期処理
- `@MainActor` の適切な使用
- Property Wrapper の積極的活用（`@State`, `@Binding`, `@ObservedObject` など）

### データモデル設計
- SwiftData の `@Model` マクロを使用
- リレーションシップの適切な定義
- データ検証の実装

### UI/UX設計
- iOS Human Interface Guidelines準拠
- ダークモード対応
- アクセシビリティ機能の実装
- レスポンシブデザイン（iPhone/iPad対応）

## 開発時の注意点

### パフォーマンス
- LazyVStack/LazyHStack の適切な使用
- 画像の最適化
- メモリリークの防止

### セキュリティ
- ユーザーデータの適切な暗号化
- キーチェーンを使用した機密情報管理

### テスト
- Unit Test の実装
- UI Test の自動化
- Preview 機能の活用

## ファイル構成例
TodoMemoApp/
├── Models/              # SwiftData モデル
├── Views/               # SwiftUI Views
├── ViewModels/          # MVVM ViewModels
├── Extensions Utilities/ # ヘルパー関数
├── Widgets/             # WidgetKit 関連
└── Resources/           # Assets, Localizable

## 優先度指針
1. 基本的なCRUD機能の完全実装
2. SwiftData による永続化の安定性
3. 直感的なユーザーインターフェース
4. ウィジェット・ライブアクティビティの実装
5. パフォーマンスの最適化

## 開発支援要求
- SwiftUI の最新ベストプラクティスの提案
- SwiftData の効率的な使用方法の提示
- iOS固有の機能実装のサポート
- コードの可読性・保守性向上の提案
- Apple の HIG に準拠した UI/UX の助言
- conventional commits のガイドラインに沿ったコミットメッセージの提案
