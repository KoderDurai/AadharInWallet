//
//  AadharInWalletApp.swift
//  AadharInWallet
//
//  Created by Karthikeyan Duraivel on 20/05/2024.
//

import SwiftUI

@main
struct AadharInWalletApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
