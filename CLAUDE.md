# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Building and Running
- **Build**: Open `TodoMemoApp.xcodeproj` in Xcode and build the project (⌘+B)
- **Run**: Use Xcode to run the app on simulator or device (⌘+R)
- **Target**: iOS 18.0+ with Swift 5.0+

### Testing
- **Run Tests**: Use Xcode's Test Navigator or `⌘+U` to run all tests
- **Test Plan**: `TodoMemoApp.xctestplan` defines test configuration
- **Test Structure**: Organized into unit tests (ViewModels, Repository) and integration tests
- **Mock Objects**: `MockTodoRepository` available for isolated testing

### Development
- No package manager dependencies - using only native iOS frameworks
- SwiftUI Previews available for most views
- Use Xcode's built-in debugging tools for troubleshooting

## Architecture

### MVVM + Repository Pattern
This is a SwiftUI-based ToDo/Memo app following MVVM architecture with a repository pattern:

```
Application/
├── DIContainer.swift          # Dependency injection container
└── TodoMemoAppApp.swift       # App entry point with SwiftData setup

Domain/
├── Models/Item.swift          # @Model SwiftData entity
└── Repositories/TodoRepository.swift  # Data access layer

Presentation/
├── ViewModels/TodoListViewModel.swift  # @Observable state management
└── Views/                     # SwiftUI views
```

### Key Components
- **Item**: SwiftData model with `@Model` macro for task, completion status, timestamp, and memo
- **TodoRepository**: Protocol-based repository abstracting SwiftData operations
- **TodoListViewModel**: `@Observable` class managing UI state and business logic
- **DIContainer**: Singleton for dependency injection, configured with ModelContext

### Data Flow
1. **App Launch**: `TodoMemoAppApp` creates ModelContainer and passes context to ContentView
2. **View Setup**: ContentView creates repository and view model through dependency injection
3. **User Actions**: Views call view model methods → view model calls repository → repository performs SwiftData operations
4. **State Updates**: Repository changes trigger view model updates → UI refreshes automatically

### SwiftData Integration
- Uses `@Model` macro on Item class for automatic persistence
- ModelContext passed through environment and injected into repository
- FetchDescriptor with sorting (timestamp descending) for data retrieval
- Direct model binding with `@Bindable` for edit views

### Key Patterns
- **Dependency Injection**: DIContainer manages object creation and dependencies
- **Protocol-based Repository**: `TodoRepositoryProtocol` enables testability
- **Observable ViewModels**: `@Observable` macro for automatic UI updates
- **Separation of Concerns**: Views handle UI, ViewModels handle state/logic, Repository handles data

## Development Guidelines

### Adding New Features
1. Create model changes in `Domain/Models/` if needed
2. Add repository methods to `TodoRepositoryProtocol` and implement in `TodoRepository`
3. Update `TodoListViewModel` with new state and business logic
4. Create or modify views in `Presentation/Views/`
5. Use DIContainer for dependency injection

### SwiftData Best Practices
- Use `@Bindable` for direct model-to-UI binding in detail/edit views
- Always save context after model changes through repository
- Use FetchDescriptor for complex queries
- Handle errors appropriately (repository throws, view model catches)

### UI Conventions
- NavigationStack for main navigation
- Sheet presentation for modals (edit tasks)
- Alert for error messages
- SwiftUI List with ForEach for task display
- Card-based design for task rows

## Testing Strategy

### Test Organization
- **Unit Tests**: Test individual components in isolation
  - `TodoListViewModelTests`: ViewModel logic with mock repository
  - `TodoRepositoryTests`: Repository operations with in-memory SwiftData
- **Integration Tests**: Test component interactions
  - `TodoIntegrationTests`: End-to-end data flow testing
- **Mock Objects**: `MockTodoRepository` implements `TodoRepositoryProtocol` for testing

### Test Data Management
- Repository tests use in-memory ModelConfiguration for isolation
- Integration tests verify actual SwiftData persistence
- Mock repository provides predictable data for ViewModel testing

## Important Files
- `TodoMemoAppApp.swift`: App entry point and SwiftData container setup
- `DIContainer.swift`: Dependency injection configuration
- `Item.swift`: Core data model with `@Model` macro
- `TodoRepository.swift`: Data access layer implementing `TodoRepositoryProtocol`
- `TodoListViewModel.swift`: Main business logic and state management
- `ContentView.swift`: Root view composition and dependency injection setup