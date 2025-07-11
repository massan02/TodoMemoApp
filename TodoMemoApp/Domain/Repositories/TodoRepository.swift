
import SwiftData
import Foundation

protocol TodoRepositoryProtocol {
    func save(_ item: Item) throws
    func delete(_ item: Item) throws
    func fetchAll() throws -> [Item]
    func update(_ item: Item) throws
}

class TodoRepository: TodoRepositoryProtocol {
    private let modelContext: ModelContext
    
    init (modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func save(_ item: Item) throws {
        modelContext.insert(item)
        try modelContext.save()
    }
    
    func delete(_ item: Item) throws {
        modelContext.delete(item)
        try modelContext.save()
    }
    
    func fetchAll() throws -> [Item] {
        let descriptor = FetchDescriptor<Item>(
            sortBy: [SortDescriptor(\.timestamp,order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func update(_ item: Item) throws {
        try modelContext.save()
    }
}
