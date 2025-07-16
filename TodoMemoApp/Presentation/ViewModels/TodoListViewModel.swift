//
//  TodoListViewModel.swift
//  TodoMemoApp
//

//

import SwiftUI
import SwiftData

@Observable
class TodoListViewModel {
    private let repository: TodoRepositoryProtocol
    
    var newTask: String = ""
    var editingItem: Item? = nil
    var isShowingEditSheet: Bool = false
    var items: [Item] = []
    
    var errorMessage: String?
    var showError: Bool = false
    
    var sortedItems: [Item] {
        items.sorted { first, second in
            if first.isCompleted != second.isCompleted {
                return !first.isCompleted // 未完了を先に
            }
            return first.timestamp > second.timestamp // 新しい順
        }
    }
    
    var incompleteTasksCount: Int {
        items.filter { !$0.isCompleted }.count
    }
    
    init(repository: TodoRepositoryProtocol) {
        self.repository = repository
        loadItems()
    }
    
    func addTask() {
        guard !newTask.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showErrorMessage("タスクを入力してください")
            return
        }
        
        let item = Item(task: newTask.trimmingCharacters(in: .whitespacesAndNewlines))
        
        do {
            try repository.save(item)
            newTask = "" // 入力フィールドをクリア
            loadItems() // タスクリストを更新
        } catch {
            showErrorMessage("タスクの追加に失敗しました")
        }
    }
    
    func toggleCompletion(for item: Item) {
        item.isCompleted.toggle()
        
        do {
            try repository.update(item)
            loadItems() // タスクリストを更新
        } catch {
            showErrorMessage("タスクの更新に失敗しました")
        }
    }
    
    func deleteItems(at offsets: IndexSet) {
        let itemsToDelete = offsets.map { sortedItems[$0] }
        
        do {
            for item in itemsToDelete {
                try repository.delete(item)
            }
            loadItems() // タスクリストを更新
        } catch {
            showErrorMessage("タスクの削除に失敗しました")
        }
    }
    
    func showEditSheet(for item: Item) {
        editingItem = item
        isShowingEditSheet = true
    }
    
    private func loadItems() {
        do {
            items = try repository.fetchAll()
        } catch {
            showErrorMessage("タスクの読み込みに失敗しました")
        }
    }
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }

}
