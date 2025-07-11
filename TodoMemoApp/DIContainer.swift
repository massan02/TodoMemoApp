import SwiftData

class DIContainer {
    static let shared = DIContainer()
    
    private init() {}
    
    private var modelContext: ModelContext?
    
    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    lazy var todoRepository: TodoRepositoryProtocol = {
        guard let modelContext = modelContext else {
            fatalError("ModelContext not configured")
        }
        return TodoRepository(modelContext: modelContext)
    }()
    
    lazy var todoListViewModel: TodoListViewModel = {
        TodoListViewModel(repository: todoRepository)
    }()

}
