//
// UpNextAIApp.swift
//  UpNextAI
//
//  Created by Isabel Cuddihy on 6/15/25.
//

import SwiftUI

@main
struct UpNextAIApp: App {
    // Initialize Core Data stack
    let coreDataStack = CoreDataStack.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
             ///   .environment(\.managedObjectContext, coreDataStack.mainContext)
             //   .environmentObject(coreDataStack)
        }
    }
}

