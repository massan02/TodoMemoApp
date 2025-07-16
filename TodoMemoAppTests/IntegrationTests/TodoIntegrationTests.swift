import XCTest
import SwiftData
@testable import TodoMemoApp

@MainActor
class TodoIntegrationTests: XCTestCase {
    
    var viewModel: TodoListViewModel!
    var repository: TodoRepository!
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    
    override func setUp() {
        super.setUp()
        
        // インメモリのModelContainerを作成（統合テスト用）
        let schema = Schema([Item.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [configuration])
            modelContext = modelContainer.mainContext
            repository = TodoRepository(modelContext: modelContext)
            viewModel = TodoListViewModel(repository: repository, autoLoad: false)
        } catch {
            XCTFail("Failed to create test ModelContainer: \(error)")
        }
    }
    
    override func tearDown() {
        viewModel = nil
        repository = nil
        modelContext = nil
        modelContainer = nil
        super.tearDown()
    }
    
    // MARK: - Full Workflow Integration Tests
    
    func testCompleteTaskLifecycle() {
        // Given: 空の状態から開始
        viewModel.loadItems()
        XCTAssertEqual(viewModel.items.count, 0)
        
        // When: タスクを追加
        viewModel.newTask = "Integration Test Task"
        viewModel.addTask()
        
        // Then: タスクが追加されている
        XCTAssertEqual(viewModel.items.count, 1)
        XCTAssertEqual(viewModel.items.first?.task, "Integration Test Task")
        XCTAssertFalse(viewModel.items.first?.isCompleted ?? true)
        XCTAssertEqual(viewModel.incompleteTasksCount, 1)
        
        // When: タスクを完了にする
        let addedItem = viewModel.items.first!
        viewModel.toggleCompletion(for: addedItem)
        
        // Then: タスクが完了状態になっている
        XCTAssertTrue(addedItem.isCompleted)
        XCTAssertEqual(viewModel.incompleteTasksCount, 0)
        
        // When: タスクを削除
        let indexSet = IndexSet(integer: 0)
        viewModel.deleteItems(at: indexSet)
        
        // Then: タスクが削除されている
        XCTAssertEqual(viewModel.items.count, 0)
    }
    
    func testMultipleTasksManagement() {
        // Given: 複数のタスクを追加
        let taskNames = ["Task 1", "Task 2", "Task 3"]
        
        for taskName in taskNames {
            viewModel.newTask = taskName
            viewModel.addTask()
        }
        
        // Then: 全てのタスクが追加されている
        XCTAssertEqual(viewModel.items.count, 3)
        XCTAssertEqual(viewModel.incompleteTasksCount, 3)
        
        // When: 一部のタスクを完了にする
        viewModel.toggleCompletion(for: viewModel.items[0])
        viewModel.toggleCompletion(for: viewModel.items[2])
        
        // Then: ソート順が正しい（未完了タスクが先、その中では新しい順）
        let sortedItems = viewModel.sortedItems
        XCTAssertEqual(sortedItems.count, 3)
        
        // 未完了タスクが最初に来る
        let incompleteItems = sortedItems.filter { !$0.isCompleted }
        let completedItems = sortedItems.filter { $0.isCompleted }
        
        XCTAssertEqual(incompleteItems.count, 1)
        XCTAssertEqual(completedItems.count, 2)
        XCTAssertEqual(incompleteItems.first?.task, "Task 2")
        
        // When: 複数のタスクを削除
        let indexesToDelete = IndexSet([0, 2]) // sortedItems内のインデックス
        viewModel.deleteItems(at: indexesToDelete)
        
        // Then: 指定されたタスクが削除されている
        XCTAssertEqual(viewModel.items.count, 1)
    }
    
    func testPersistenceAcrossViewModelInstances() {
        // Given: 最初のViewModelでタスクを追加
        viewModel.newTask = "Persistent Task"
        viewModel.addTask()
        XCTAssertEqual(viewModel.items.count, 1)
        
        // When: 新しいViewModelインスタンスを作成
        let newViewModel = TodoListViewModel(repository: repository, autoLoad: true)
        
        // Then: データが永続化されている
        XCTAssertEqual(newViewModel.items.count, 1)
        XCTAssertEqual(newViewModel.items.first?.task, "Persistent Task")
    }
    
    func testTaskMemoIntegration() {
        // Given: メモ付きタスクを作成
        let item = Item(task: "Task with memo", memo: "This is a test memo")
        try! repository.save(item)
        viewModel.loadItems()
        
        // Then: メモが正しく保存・取得される
        XCTAssertEqual(viewModel.items.count, 1)
        XCTAssertEqual(viewModel.items.first?.memo, "This is a test memo")
        
        // When: メモを更新
        let retrievedItem = viewModel.items.first!
        retrievedItem.memo = "Updated memo"
        try! repository.update(retrievedItem)
        
        // 新しいViewModelで確認
        let newViewModel = TodoListViewModel(repository: repository, autoLoad: true)
        XCTAssertEqual(newViewModel.items.first?.memo, "Updated memo")
    }
    
    func testTimestampOrdering() {
        // Given: 異なる時間のタスクを作成
        let oldItem = Item(task: "Old Task", timestamp: Date(timeIntervalSinceNow: -3600))
        let newItem = Item(task: "New Task", timestamp: Date())
        
        try! repository.save(oldItem)
        try! repository.save(newItem)
        viewModel.loadItems()
        
        // Then: 新しいタスクが最初に表示される
        let sortedItems = viewModel.sortedItems
        XCTAssertEqual(sortedItems.count, 2)
        XCTAssertEqual(sortedItems.first?.task, "New Task")
        XCTAssertEqual(sortedItems.last?.task, "Old Task")
    }
    
    func testErrorRecovery() {
        // Given: 正常なタスクを追加
        viewModel.newTask = "Normal Task"
        viewModel.addTask()
        XCTAssertEqual(viewModel.items.count, 1)
        XCTAssertFalse(viewModel.showError)
        
        // When: 無効なタスクを追加しようとする
        viewModel.newTask = ""
        viewModel.addTask()
        
        // Then: エラーが表示されるが、既存のタスクは保持される
        XCTAssertTrue(viewModel.showError)
        XCTAssertEqual(viewModel.items.count, 1) // 既存タスクは影響なし
        
        // When: 再度正常なタスクを追加
        viewModel.newTask = "Recovery Task"
        viewModel.addTask()
        
        // Then: エラーがリセットされ、新しいタスクが追加される
        XCTAssertFalse(viewModel.showError)
        XCTAssertEqual(viewModel.items.count, 2)
    }
    
    // MARK: - Performance Integration Tests
    
    func testPerformanceWithManyTasks() {
        measure {
            // Given: 多数のタスクを追加
            for i in 1...100 {
                viewModel.newTask = "Task \(i)"
                viewModel.addTask()
            }
            
            // When: ソート処理を実行
            let _ = viewModel.sortedItems
            
            // Then: パフォーマンスが許容範囲内
        }
    }
}