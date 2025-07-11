// TodoRowView.swift
import SwiftUI

struct TodoRowView: View {
    let item: Item
    let onToggleCompletion: (Item) -> Void
    let onEditTask: (Item) -> Void
    
    var body: some View {
        NavigationLink {
            TaskDetailView(item: item)
        } label: {
            HStack(spacing: 15) {
                // 完了状態アイコン
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(item.isCompleted ? .green : .primary)
                    .onTapGesture {
                        onToggleCompletion(item)
                    }
                
                // タスク情報
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.task)
                        .strikethrough(item.isCompleted)
                        .foregroundColor(item.isCompleted ? .secondary : .primary)
                    
                    if !item.memo.isEmpty {
                        HStack {
                            Image(systemName: "paperclip")
                                .font(.caption)
                            Text("メモあり")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                }
                .onTapGesture {
                    onEditTask(item)
                }
                
                Spacer()
            }
        }
        .listRowBackground(
            RoundedRectangle(cornerRadius: 10)
                .background(.clear)
                .foregroundColor(Color(UIColor.secondarySystemGroupedBackground))
                .padding(.vertical, 4)
        )
        .listRowSeparator(.hidden)
    }
}
