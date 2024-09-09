//
//  ContentView.swift
//  TaskContext
//
//  Created by Windy on 09/09/24.
//

import SwiftUI

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

struct ContentView: View {
    
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .onAppear { viewModel.loadContacts() }
        .bindTaskContext(on: viewModel)
    }
}

#Preview {
    ContentView()
}
