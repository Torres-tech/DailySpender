//
//  ContentView.swift
//  DailySpender
//
//  Created by Khang Lam on 7/29/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationView{
                HistoryView()
            }
            .tabItem {
                Label("History", systemImage: "list.bullet")
            }
            
            NavigationView {
                AddExpenseView()
            }
            .tabItem {
                Label("Add", systemImage: "plus.circle")
                }
            
            NavigationView {
                SummaryView()
                }
            .tabItem {
                Label("Summary", systemImage: "chart.pie")
            }
        }
    }
}
