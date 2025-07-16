import SwiftUI

struct TodoListView: View {
    let items: [Item]
    let onToggleCompletion: (Item) -> Void
    let onEditTask: (Item) -> Void
    let onDeleteItems: (IndexSet) -> Void
    
    var body: some View {
        List {
            ForEach(items) { item in
                TodoRowView(
                    item: item,
                    onToggleCompletion: onToggleCompletion,
                    onEditTask: onEditTask
                )
            }
            .onDelete(perform: onDeleteItems)   // ★ ForEach に付ける
        }
        .listStyle(.plain)                       // ★ List に付ける
    }
}
