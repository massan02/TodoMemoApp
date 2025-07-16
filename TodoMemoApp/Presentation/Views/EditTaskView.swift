
import SwiftUI
import SwiftData

struct EditTaskView: View {
    // 編集対象のタスクを受け取るための変数
    // @Bindable をつけることで、このビューでの変更が即座に元のデータに反映される
    @Bindable var item: Item
    
    // このシートを閉じるための機能
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        // 編集画面に適したナビゲーションとフォーム
        NavigationStack {
            Form {
                Section(header: Text("タスクの編集")) {
                    TextField("タスク名", text: $item.task)
                }
            }
            .navigationTitle("編集")
            .navigationBarTitleDisplayMode(.inline) // タイトルを小さく表示
            .toolbar {
                // 左上に「キャンセル」ボタン
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss() // シートを閉じる
                    }
                }
                // 右上に「保存」ボタン
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        // @Bindableのおかげで、TextFieldの変更は既にitemに反映されている
                        // そのため、ここではシートを閉じるだけで良い
                        dismiss()
                    }
                    // タスク名が空の場合は保存ボタンを押せなくする
                    .disabled(item.task.isEmpty)
                }
            }
        }
    }
}
