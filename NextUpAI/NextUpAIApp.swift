//
//  NextUpAIApp.swift
//  NextUpAI
//
//  Created by Isabel Cuddihy on 6/15/25.
//

import SwiftUI

@main
struct NextUpAIApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
