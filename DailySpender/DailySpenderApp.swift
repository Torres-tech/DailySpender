//
//  DailySpenderApp.swift
//  DailySpender
//
//  Created by Khang Lam on 7/29/25.
//

import SwiftUI

@main
struct DailySpenderApp: App {
    @StateObject private var viewModel = ExpenseViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
