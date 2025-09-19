//
//  ContentView.swift
//  DailySpender
//
//  Created by Khang Lam on 7/29/25.
//

import SwiftUI

struct ContentView: View {

    @StateObject private var viewModel = ExpenseViewModel()
    
    var body: some View {
        TabView {
            // History Tab
            NavigationView {
                HistoryView()
            }
            .tabItem {
                Label("History", systemImage: "list.bullet")
            }
            
            // Add Expense Tab
            NavigationView {
                AddExpenseView()
            }
            .tabItem {
                Label("Add Expense", systemImage: "minus.circle.fill")
            }
            
            // Add Income Tab
            NavigationView {
                AddIncomeView()
            }
            .tabItem {
                Label("Add Income", systemImage: "plus.circle.fill")
            }
            
            // Summary Tab
            NavigationView {
                SummaryView()
            }
            .tabItem {
                Label("Summary", systemImage: "chart.pie.fill")
            }
            
            // AI Insights Tab
            NavigationView {
                InsightsView()
            }
            .tabItem {
                Label("AI Insights", systemImage: "brain.head.profile")
            }
            
            // AI Settings Tab
            NavigationView {
                AISettingsView()
            }
            .tabItem {
                Label("AI Settings", systemImage: "gear")
            }
        }
        .environmentObject(viewModel)
        .accentColor(.blue)
    }
}

#Preview {
    ContentView()
}
