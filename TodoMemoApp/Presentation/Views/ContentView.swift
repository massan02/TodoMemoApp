// ContentView.swift（リファクタリング後）
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: TodoListViewModel
    
    init() {
        // DIContainerを使用してViewModelを初期化
        _viewModel = State(initialValue: DIContainer.shared.todoListViewModel)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // 入力フォーム
                TaskInputView(
                    newTask: $viewModel.newTask,
                    onAddTask: viewModel.addTask
                )
                
                // タスクリスト
                TodoListView(
                    items: viewModel.sortedItems,
                    onToggleCompletion: viewModel.toggleCompletion,
                    onEditTask: viewModel.showEditSheet,
                    onDeleteItems: viewModel.deleteItems
                )
            }
            .navigationTitle("ToDoリスト (\(viewModel.incompleteTasksCount))")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .sheet(isPresented: $viewModel.isShowingEditSheet) {
                if let editingItem = viewModel.editingItem {
                    EditTaskView(item: editingItem)
                }
            }
            .alert("エラー", isPresented: $viewModel.showError) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .onAppear {
            // DIContainerにModelContextを設定
            DIContainer.shared.configure(modelContext: modelContext)
        }
    }
}

#Preview("テストデータ付き") {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
