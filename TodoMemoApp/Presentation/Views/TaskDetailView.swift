
import SwiftUI
import SwiftData

struct TaskDetailView: View {
    // 表示・編集対象のタスクを受け取る
    @Bindable var item: Item
    
    var body: some View {
        Form {
            Section(header: Text("タスク名")) {
                // タスク名はここでは表示のみ（編集は前の画面で行うため）
                Text(item.task)
            }
            
            Section(header: Text("メモ")) {
                // 複数行のテキストを入力できるTextEditor
                // textには @Bindable item の memoプロパティを直接バインドする
                TextEditor(text: $item.memo)
                    .frame(height: 200) // 適当な高さを指定
            }
        }
        .navigationTitle("詳細")
        .navigationBarTitleDisplayMode(.inline)
    }
}
