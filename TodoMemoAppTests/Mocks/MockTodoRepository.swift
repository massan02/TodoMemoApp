import Foundation
@testable import TodoMemoApp

class MockTodoRepository: TodoRepositoryProtocol {
    
    private var items: [Item] = []
    var shouldThrowError = false
    var throwErrorType: ErrorType = .general
    
    enum ErrorType {
        case general
        case networkError
        case storageError
    }
    
    struct TestError: Error {
        let message: String
    }
    
    // MARK: - Test Helper Methods
    func reset() {
        items.removeAll()
        shouldThrowError = false
        throwErrorType = .general
    }
    
    func setItems(_ newItems: [Item]) {
        items = newItems
    }
    
    func getItems() -> [Item] {
        return items
    }
    
    // MARK: - TodoRepositoryProtocol Implementation
    func save(_ item: Item) throws {
        if shouldThrowError {
            throw TestError(message: "Save failed")
        }
        items.append(item)
    }
    
    func delete(_ item: Item) throws {
        if shouldThrowError {
            throw TestError(message: "Delete failed")
        }
        if let index = items.firstIndex(where: { $0.task == item.task && $0.timestamp == item.timestamp }) {
            items.remove(at: index)
        }
    }
    
    func fetchAll() throws -> [Item] {
        if shouldThrowError {
            throw TestError(message: "Fetch failed")
        }
        return items.sorted { $0.timestamp > $1.timestamp }
    }
    
    func update(_ item: Item) throws {
        if shouldThrowError {
            throw TestError(message: "Update failed")
        }
        // MockなのでSwiftDataの実際の更新は模擬
        // 実際のテストでは item の状態変更がそのまま反映される
    }
}