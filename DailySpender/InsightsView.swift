//
//  InsightsView.swift
//  DailySpender
//
//  Created by Khang Lam on 7/29/25.
//

import SwiftUI

struct InsightsView: View {
    @EnvironmentObject var viewModel: ExpenseViewModel
    @State private var showingPersonalizedAdvice = false
    @State private var personalizedAdvice = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Loading State
                    if viewModel.isLoadingAI {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("AI is analyzing your finances...")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        .padding(.top, 50)
                    }
                    // Error State
                    else if let error = viewModel.aiError {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 60))
                                .foregroundColor(.orange)
                            
                            Text("AI Analysis Error")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text(error)
                                .font(.body)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Button("Retry") {
                                viewModel.generateInsights()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.top, 50)
                    }
                    // Empty State
                    else if viewModel.insights.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                            
                            Text("No Insights Yet")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Add some expenses and income to get personalized financial insights!")
                                .font(.body)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top, 50)
                    }
                    // Insights Content
                    else {
                        // AI Status Header
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "brain.head.profile")
                                    .foregroundColor(.blue)
                                Text("AI-Powered Insights")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                                if UserDefaults.standard.bool(forKey: "useRealAI") {
                                    Text("GPT")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                } else {
                                    Text("Mock AI")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color.orange)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                            
                            Text("Personalized analysis based on your spending patterns")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // Insights Cards
                        ForEach(viewModel.insights) { insight in
                            InsightCard(insight: insight)
                        }
                        
                        // Personalized Advice Button
                        Button(action: {
                            Task {
                                personalizedAdvice = await viewModel.generatePersonalizedAdvice()
                                showingPersonalizedAdvice = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "message.fill")
                                Text("Get Personalized Advice")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("AI Insights")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                // Refresh insights when user pulls down
                viewModel.generateInsights()
            }
            .sheet(isPresented: $showingPersonalizedAdvice) {
                PersonalizedAdviceView(advice: personalizedAdvice)
            }
        }
    }
}

struct PersonalizedAdviceView: View {
    let advice: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .font(.title)
                            .foregroundColor(.blue)
                        Text("Personalized Financial Advice")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    
                    Text(advice)
                        .font(.body)
                        .lineSpacing(4)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("AI Advice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct InsightCard: View {
    let insight: FinancialInsight
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(insight.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(insightTypeDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Image(systemName: insightIcon)
                        .font(.title2)
                        .foregroundColor(insightColor)
                    
                    Text(priorityText)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(priorityColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            
            // Message
            Text(insight.message)
                .font(.body)
                .foregroundColor(.primary)
            
            // Action Items (Expandable)
            if !insight.actionItems.isEmpty {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack {
                        Text("Action Items (\(insight.actionItems.count))")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                }
                
                if isExpanded {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(insight.actionItems.enumerated()), id: \.offset) { index, item in
                            HStack(alignment: .top, spacing: 8) {
                                Text("\(index + 1).")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                                    .frame(width: 20, alignment: .leading)
                                
                                Text(item)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                            }
                        }
                    }
                    .padding(.top, 8)
                }
            }
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var insightTypeDescription: String {
        switch insight.type {
        case .spending:
            return "Spending Analysis"
        case .saving:
            return "Savings Recommendation"
        case .income:
            return "Income Insights"
        case .budget:
            return "Budget Advice"
        case .warning:
            return "Financial Alert"
        }
    }
    
    private var insightIcon: String {
        switch insight.type {
        case .spending:
            return "chart.pie.fill"
        case .saving:
            return "banknote.fill"
        case .income:
            return "arrow.up.circle.fill"
        case .budget:
            return "target"
        case .warning:
            return "exclamationmark.triangle.fill"
        }
    }
    
    private var insightColor: Color {
        switch insight.type {
        case .spending:
            return .orange
        case .saving:
            return .green
        case .income:
            return .blue
        case .budget:
            return .purple
        case .warning:
            return .red
        }
    }
    
    private var priorityText: String {
        switch insight.priority {
        case .high:
            return "HIGH"
        case .medium:
            return "MED"
        case .low:
            return "LOW"
        }
    }
    
    private var priorityColor: Color {
        switch insight.priority {
        case .high:
            return .red
        case .medium:
            return .orange
        case .low:
            return .green
        }
    }
    
    private var backgroundColor: Color {
        switch insight.priority {
        case .high:
            return Color.red.opacity(0.05)
        case .medium:
            return Color.orange.opacity(0.05)
        case .low:
            return Color.green.opacity(0.05)
        }
    }
}

#Preview {
    InsightsView()
        .environmentObject(ExpenseViewModel())
}
