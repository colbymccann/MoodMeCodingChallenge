//
//  MoodMeDemoApp.swift
//  MoodMeDemo
//
//  Created by Colby McCann on 12/13/24.
//

import SwiftUI

@main
struct MoodMeDemoApp: App {
    @StateObject var dataController = DataController()
    @StateObject var viewModel = ARFaceViewViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
                .environmentObject(viewModel)
        }
    }
}
