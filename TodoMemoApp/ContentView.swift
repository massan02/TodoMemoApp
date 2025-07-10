//
//  ContentView.swift
//  TodoMemoApp
//
//  Created by 村崎聖仁 on 2025/07/05.
//

import SwiftUI
import SwiftData


struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allItems: [Item]

    private var sortedItems: [Item] {
        allItems.sorted { first, second in
            if first.isCompleted != second.isCompleted {
                return !first.isCompleted // 未完了を先に
            }
            return first.timestamp > second.timestamp // 新しい順
        }
    }
    @State private var newTask: String = ""
    // --- 編集機能のための状態変数 ---
    @State private var editingItem: Item? = nil
    @State private var isShowingEditSheet: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                // --- 入力フォーム ---
                HStack {
                    TextField("新しいタスクを入力", text: $newTask)
                        .textFieldStyle(.roundedBorder)
                    
                    Button(action: addItem) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                    }
                    .disabled(newTask.isEmpty) // 入力が空の時はボタンを無効化
                }
                .padding()
                
                // --- タスクリスト ---
                List {
                    ForEach(sortedItems) { item in
                        // NavigationLinkでラップして詳細画面へ遷移
                        NavigationLink {
                            TaskDetailView(item: item)
                        } label: {
                            HStack(spacing: 15) {
                                // ① 完了状態を示すアイコン
                                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .font(.title2)
                                    .foregroundColor(item.isCompleted ? .green : .primary)
                                    .onTapGesture {
                                        // アイコンタップで完了状態を切り替え
                                        toggleCompletion(for: item)
                                    }
                                
                                // ② タスク名（完了時は取り消し線）
                                Text(item.task)
                                    .strikethrough(item.isCompleted)
                                    .onTapGesture {
                                        // テキストタップで編集シートを表示
                                        editingItem = item
                                        isShowingEditSheet = true
                                    }
                                
                                Spacer()
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .navigationTitle("ToDoリスト (\(incompleteTasksCount))")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            // --- 編集シートの定義 ---
            .sheet(isPresented: $isShowingEditSheet) {
                // isShowingEditSheetがtrueになったら表示される
                if let editingItem {
                    EditTaskView(item: editingItem)
                }
            }
        }
    }
    
    // ① 未完了タスクの数を計算するプロパティ
    private var incompleteTasksCount: Int {
        sortedItems.filter { !$0.isCompleted }.count
    }

    private func addItem() {
        guard !newTask.isEmpty else { return }
        withAnimation {
            let newItem = Item(task: newTask)
            modelContext.insert(newItem)
            
            // 追加後にテキストフィールドを空にする
            newTask = ""
        }
    }

    private func toggleCompletion(for item: Item) {
        withAnimation {
            item.isCompleted.toggle()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(sortedItems[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
