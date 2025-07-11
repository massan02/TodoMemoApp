import SwiftUI

struct TaskInputView: View {
    @Binding var newTask: String
    let onAddTask: () -> Void
    
    var body: some View {
        HStack {
            TextField("新しいタスクを入力", text: $newTask)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    onAddTask()
                }
            
            Button(action: onAddTask) {
                Image(systemName: "plus.circle.fill")
                    .font(.title)
            }
            .disabled(newTask.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
    }
    
}
