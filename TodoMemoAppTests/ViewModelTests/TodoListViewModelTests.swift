import XCTest
@testable import TodoMemoApp

@MainActor
class TodoListViewModelTests: XCTestCase {
    
    var viewModel: TodoListViewModel!
    var mockRepository: MockTodoRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockTodoRepository()
        viewModel = TodoListViewModel(repository: mockRepository, autoLoad: false)
    }
    
    override func tearDown() {
        viewModel = nil
        mockRepository = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    func testInit_WithAutoLoadTrue_LoadsItems() {
        // Given
        let testItem = Item(task: "Test Task")
        mockRepository.setItems([testItem])
        
        // When
        let viewModelWithAutoLoad = TodoListViewModel(repository: mockRepository, autoLoad: true)
        
        // Then
        XCTAssertEqual(viewModelWithAutoLoad.items.count, 1)
        XCTAssertEqual(viewModelWithAutoLoad.items.first?.task, "Test Task")
    }
    
    func testInit_WithAutoLoadFalse_DoesNotLoadItems() {
        // Given
        let testItem = Item(task: "Test Task")
        mockRepository.setItems([testItem])
        
        // When
        let viewModelWithoutAutoLoad = TodoListViewModel(repository: mockRepository, autoLoad: false)
        
        // Then
        XCTAssertEqual(viewModelWithoutAutoLoad.items.count, 0)
    }
    
    // MARK: - Load Items Tests
    func testLoadItems_Success() {
        // Given
        let item1 = Item(task: "Task 1")
        let item2 = Item(task: "Task 2")
        mockRepository.setItems([item1, item2])
        
        // When
        viewModel.loadItems()
        
        // Then
        XCTAssertEqual(viewModel.items.count, 2)
        XCTAssertFalse(viewModel.showError)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testLoadItems_Failure_ShowsError() {
        // Given
        mockRepository.shouldThrowError = true
        
        // When
        viewModel.loadItems()
        
        // Then
        XCTAssertTrue(viewModel.showError)
        XCTAssertEqual(viewModel.errorMessage, "タスクの読み込みに失敗しました")
        XCTAssertEqual(viewModel.items.count, 0)
    }
    
    // MARK: - Add Task Tests
    func testAddTask_ValidTask_Success() {
        // Given
        viewModel.newTask = "New Task"
        
        // When
        viewModel.addTask()
        
        // Then
        XCTAssertEqual(viewModel.newTask, "") // Input field cleared
        XCTAssertEqual(viewModel.items.count, 1)
        XCTAssertEqual(viewModel.items.first?.task, "New Task")
        XCTAssertFalse(viewModel.showError)
    }
    
    func testAddTask_EmptyTask_ShowsError() {
        // Given
        viewModel.newTask = ""
        
        // When
        viewModel.addTask()
        
        // Then
        XCTAssertTrue(viewModel.showError)
        XCTAssertEqual(viewModel.errorMessage, "タスクを入力してください")
        XCTAssertEqual(viewModel.items.count, 0)
    }
    
    func testAddTask_WhitespaceOnlyTask_ShowsError() {
        // Given
        viewModel.newTask = "   \n\t   "
        
        // When
        viewModel.addTask()
        
        // Then
        XCTAssertTrue(viewModel.showError)
        XCTAssertEqual(viewModel.errorMessage, "タスクを入力してください")
        XCTAssertEqual(viewModel.items.count, 0)
    }
    
    func testAddTask_RepositoryError_ShowsError() {
        // Given
        viewModel.newTask = "Valid Task"
        mockRepository.shouldThrowError = true
        
        // When
        viewModel.addTask()
        
        // Then
        XCTAssertTrue(viewModel.showError)
        XCTAssertEqual(viewModel.errorMessage, "タスクの追加に失敗しました")
        XCTAssertEqual(viewModel.newTask, "Valid Task") // Input not cleared on error
    }
    
    // MARK: - Toggle Completion Tests
    func testToggleCompletion_Success() {
        // Given
        let item = Item(task: "Test Task", isCompleted: false)
        mockRepository.setItems([item])
        viewModel.loadItems()
        
        // When
        viewModel.toggleCompletion(for: item)
        
        // Then
        XCTAssertTrue(item.isCompleted)
        XCTAssertFalse(viewModel.showError)
    }
    
    func testToggleCompletion_RepositoryError_ShowsError() {
        // Given
        let item = Item(task: "Test Task", isCompleted: false)
        mockRepository.setItems([item])
        viewModel.loadItems()
        mockRepository.shouldThrowError = true
        
        // When
        viewModel.toggleCompletion(for: item)
        
        // Then
        XCTAssertTrue(item.isCompleted) // State was toggled locally
        XCTAssertTrue(viewModel.showError)
        XCTAssertEqual(viewModel.errorMessage, "タスクの更新に失敗しました")
    }
    
    // MARK: - Delete Items Tests
    func testDeleteItems_Success() {
        // Given
        let item1 = Item(task: "Task 1")
        let item2 = Item(task: "Task 2")
        mockRepository.setItems([item1, item2])
        viewModel.loadItems()
        
        // When
        let indexSet = IndexSet(integer: 0) // Delete first item
        viewModel.deleteItems(at: indexSet)
        
        // Then
        XCTAssertEqual(viewModel.items.count, 1)
        XCTAssertFalse(viewModel.showError)
    }
    
    func testDeleteItems_RepositoryError_ShowsError() {
        // Given
        let item1 = Item(task: "Task 1")
        mockRepository.setItems([item1])
        viewModel.loadItems()
        mockRepository.shouldThrowError = true
        
        // When
        let indexSet = IndexSet(integer: 0)
        viewModel.deleteItems(at: indexSet)
        
        // Then
        XCTAssertTrue(viewModel.showError)
        XCTAssertEqual(viewModel.errorMessage, "タスクの削除に失敗しました")
    }
    
    // MARK: - Computed Properties Tests
    func testSortedItems_ProperSorting() {
        // Given
        let completedOldTask = Item(task: "Completed Old", isCompleted: true, timestamp: Date(timeIntervalSinceNow: -3600))
        let incompleteOldTask = Item(task: "Incomplete Old", isCompleted: false, timestamp: Date(timeIntervalSinceNow: -1800))
        let incompleteNewTask = Item(task: "Incomplete New", isCompleted: false, timestamp: Date())
        
        mockRepository.setItems([completedOldTask, incompleteOldTask, incompleteNewTask])
        viewModel.loadItems()
        
        // When
        let sortedItems = viewModel.sortedItems
        
        // Then
        XCTAssertEqual(sortedItems.count, 3)
        XCTAssertEqual(sortedItems[0].task, "Incomplete New") // 未完了の新しいタスクが最初
        XCTAssertEqual(sortedItems[1].task, "Incomplete Old") // 未完了の古いタスクが次
        XCTAssertEqual(sortedItems[2].task, "Completed Old")  // 完了タスクが最後
    }
    
    func testIncompleteTasksCount() {
        // Given
        let completedTask = Item(task: "Completed", isCompleted: true)
        let incompleteTask1 = Item(task: "Incomplete 1", isCompleted: false)
        let incompleteTask2 = Item(task: "Incomplete 2", isCompleted: false)
        
        mockRepository.setItems([completedTask, incompleteTask1, incompleteTask2])
        viewModel.loadItems()
        
        // When & Then
        XCTAssertEqual(viewModel.incompleteTasksCount, 2)
    }
    
    // MARK: - Edit Sheet Tests
    func testShowEditSheet() {
        // Given
        let item = Item(task: "Test Task")
        
        // When
        viewModel.showEditSheet(for: item)
        
        // Then
        XCTAssertEqual(viewModel.editingItem, item)
        XCTAssertTrue(viewModel.isShowingEditSheet)
    }
    
    // MARK: - Error Handling Tests
    func testErrorHandling_ResetsOnSuccess() {
        // Given
        viewModel.errorMessage = "Previous error"
        viewModel.showError = true
        viewModel.newTask = "Valid Task"
        
        // When
        viewModel.addTask()
        
        // Then
        XCTAssertFalse(viewModel.showError)
        XCTAssertNil(viewModel.errorMessage)
    }
}