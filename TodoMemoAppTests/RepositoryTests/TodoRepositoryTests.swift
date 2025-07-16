import XCTest
import SwiftData
@testable import TodoMemoApp

@MainActor
class TodoRepositoryTests: XCTestCase {
    
    var repository: TodoRepository!
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    
    override func setUp() {
        super.setUp()
        
        // インメモリのModelContainerを作成（テスト用）
        let schema = Schema([Item.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [configuration])
            modelContext = modelContainer.mainContext
            repository = TodoRepository(modelContext: modelContext)
        } catch {
            XCTFail("Failed to create test ModelContainer: \(error)")
        }
    }
    
    override func tearDown() {
        repository = nil
        modelContext = nil
        modelContainer = nil
        super.tearDown()
    }
    
    // MARK: - Save Tests
    func testSaveItem_Success() throws {
        // Given
        let item = Item(task: "Test Task")
        
        // When
        try repository.save(item)
        
        // Then
        let fetchedItems = try repository.fetchAll()
        XCTAssertEqual(fetchedItems.count, 1)
        XCTAssertEqual(fetchedItems.first?.task, "Test Task")
        XCTAssertFalse(fetchedItems.first?.isCompleted ?? true)
    }
    
    func testSaveMultipleItems_Success() throws {
        // Given
        let item1 = Item(task: "Task 1")
        let item2 = Item(task: "Task 2")
        
        // When
        try repository.save(item1)
        try repository.save(item2)
        
        // Then
        let fetchedItems = try repository.fetchAll()
        XCTAssertEqual(fetchedItems.count, 2)
        
        let tasks = fetchedItems.map { $0.task }
        XCTAssertTrue(tasks.contains("Task 1"))
        XCTAssertTrue(tasks.contains("Task 2"))
    }
    
    // MARK: - Fetch Tests
    func testFetchAll_EmptyRepository() throws {
        // When
        let items = try repository.fetchAll()
        
        // Then
        XCTAssertEqual(items.count, 0)
    }
    
    func testFetchAll_SortedByTimestamp() throws {
        // Given
        let oldItem = Item(task: "Old Task", timestamp: Date(timeIntervalSinceNow: -3600)) // 1時間前
        let newItem = Item(task: "New Task", timestamp: Date()) // 現在
        
        // When
        try repository.save(oldItem)
        try repository.save(newItem)
        
        // Then
        let fetchedItems = try repository.fetchAll()
        XCTAssertEqual(fetchedItems.count, 2)
        XCTAssertEqual(fetchedItems.first?.task, "New Task") // 新しいものが最初
        XCTAssertEqual(fetchedItems.last?.task, "Old Task")  // 古いものが最後
    }
    
    // MARK: - Update Tests
    func testUpdateItem_Success() throws {
        // Given
        let item = Item(task: "Original Task")
        try repository.save(item)
        
        // When
        item.isCompleted = true
        item.task = "Updated Task"
        try repository.update(item)
        
        // Then
        let fetchedItems = try repository.fetchAll()
        XCTAssertEqual(fetchedItems.count, 1)
        XCTAssertEqual(fetchedItems.first?.task, "Updated Task")
        XCTAssertTrue(fetchedItems.first?.isCompleted ?? false)
    }
    
    // MARK: - Delete Tests
    func testDeleteItem_Success() throws {
        // Given
        let item1 = Item(task: "Task 1")
        let item2 = Item(task: "Task 2")
        try repository.save(item1)
        try repository.save(item2)
        
        // When
        try repository.delete(item1)
        
        // Then
        let fetchedItems = try repository.fetchAll()
        XCTAssertEqual(fetchedItems.count, 1)
        XCTAssertEqual(fetchedItems.first?.task, "Task 2")
    }
    
    func testDeleteAllItems_Success() throws {
        // Given
        let item1 = Item(task: "Task 1")
        let item2 = Item(task: "Task 2")
        try repository.save(item1)
        try repository.save(item2)
        
        // When
        try repository.delete(item1)
        try repository.delete(item2)
        
        // Then
        let fetchedItems = try repository.fetchAll()
        XCTAssertEqual(fetchedItems.count, 0)
    }
}