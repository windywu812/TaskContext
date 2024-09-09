//
//  TaskContext.swift
//  MainThreadPublished
//
//  Created by Windy on 07/09/24.
//

import Foundation
import SwiftUI

final class TaskScope {
    typealias OngoingTask = Task<Void, Never>
    private var ongoingTask: [AnyHashable: OngoingTask] = [:]
}

protocol TaskContext: AnyObject {
    var taskScope: TaskScope { get }
}

extension View {
    func bindTaskContext(on context: TaskContext) -> some View {
        onDisappear {
            context.taskScope.cancelAll()
        }
    }
}

extension TaskContext {
    
    func withTaskCancellation(
        id: AnyHashable = #function,
        operation: @Sendable @escaping () async -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        let task = Task(operation: operation)
        taskScope.store(id: id, task: task)
    }
   
    func cancel<ID: Hashable>(id: ID) {
        taskScope.cancel(id: id)
    }
}

private extension TaskScope {
    
    func store<ID: Hashable>(id: ID, task: OngoingTask) {
        cancel(id: id)
        ongoingTask[id] = task
    }
    
    func cancel<ID: Hashable>(id: ID) {
        ongoingTask[id]?.cancel()
    }
    
    func cancelAll() {
        ongoingTask.forEach { _, task in task.cancel() }
    }
}
