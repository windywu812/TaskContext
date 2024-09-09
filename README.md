# Motivation
There is already existing modifier `.task` to manage task lifecycle inside the SwiftUI view. The modifier will trigger a task before onAppear and will cancel the task whenever the is disappear.
This modifier is handy when we have a simple logic in the SwiftUI view. But when have a complex SwiftUI view, storing the task might be suitable solution for that scenario.

But we need to manually store task in viewmodel and cancel the task when the view is dissapear. Otherwise we will have a leak where the viewmodel is deallocted. 
As the viewmodel is growing, there will be many boilerplate code and the code much more prone to error because if we forget to cancel the task, then we have a memory leak.
```swift
class ContentViewModel: ObservableObject {
    
    private var task: Task<Void, Never>?
    
    func loadContacts() {
        task = Task { [weak self] in
            await self?.longTask()
        }
    }
    
    func onDisappear() {
        task?.cancel()
    }
    
    private func longTask() async {
        try? await Task.sleep(for: .seconds(5))
    }
}
```

# Proposed Solution
Introduce the `TaskContext` that will manage the task lifecycle in viewmodel that responsible for holding any ongoing task on the viewmodel. 
For storing the task inside `TaskContext`, use `withTaskCancellation` function. Now we don't need the boilerplate code that we create to store and cancel the task manually and we have much more declarative code.
```swift
final class ContentViewModel: ObservableObject, TaskContext {
    
    let taskScope = TaskScope()
    
    func loadContacts() {
        withTaskCancellation { [weak self] in
            await self?.longTask()
        }
    }
        
    private func longTask() async {
        try? await Task.sleep(for: .seconds(5))
    }
}
```

Now instead of calling the viewModel.onDisappear, we can the `bindTaskContext` function instead. This function will automatically cancel out all the ongoing tasks when the view is disappear.
```swift
struct ContentView: View {
    
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        VStack {
          ...
        }
        .onAppear { viewModel.loadContacts() }
        .bindTaskContext(on: viewModel)
    }
}
```
