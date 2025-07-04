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
    @Query private var items: [Item]

    @State private var newTask: String = ""

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
                    ForEach(items) { item in
                        Text(item.task)
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .navigationTitle("ToDoリスト")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
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

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
