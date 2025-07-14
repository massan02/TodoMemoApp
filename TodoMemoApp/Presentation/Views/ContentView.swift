// ContentView.swift（リファクタリング後）
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: TodoListViewModel
    
    init(modelContext: ModelContext) {
        let repository = TodoRepository(modelContext: modelContext)
        _viewModel = State(wrappedValue: TodoListViewModel(repository: repository))
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
        
    }
}

#Preview("テストデータ付き") {
    ContentView(modelContext: previewContainer.mainContext)
}

private var previewContainer: ModelContainer = {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    return try! ModelContainer(for: Item.self, configurations: config)
}()
