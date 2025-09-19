//
//  AISettingsView.swift
//  DailySpender
//
//  Created by Khang Lam on 7/29/25.
//

import SwiftUI

struct AISettingsView: View {
    @State private var apiKey = ""
    @State private var useRealAI = false
    @State private var showingAPIKeyAlert = false
    @State private var showingTestAlert = false
    @State private var testResult = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("AI Configuration")) {
                    Toggle("Use Real AI (GPT)", isOn: $useRealAI)
                        .onChange(of: useRealAI) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "useRealAI")
                        }
                    
                    if useRealAI {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("OpenAI API Key")
                                .font(.headline)
                            
                            SecureField("Enter your OpenAI API key", text: $apiKey)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onChange(of: apiKey) { newValue in
                                    UserDefaults.standard.set(newValue, forKey: "openai_api_key")
                                }
                            
                            Text("Get your API key from: https://platform.openai.com/api-keys")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Section(header: Text("AI Features")) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.blue)
                        Text("Financial Insights")
                        Spacer()
                        Text("Active")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                    
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .foregroundColor(.green)
                        Text("Spending Analysis")
                        Spacer()
                        Text("Active")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                    
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.orange)
                        Text("Overspending Alerts")
                        Spacer()
                        Text("Active")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                    
                    HStack {
                        Image(systemName: "target")
                            .foregroundColor(.purple)
                        Text("Budget Recommendations")
                        Spacer()
                        Text("Active")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }
                
                if useRealAI {
                    Section(header: Text("Testing")) {
                        Button(action: testAIConnection) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "wifi")
                                }
                                Text("Test AI Connection")
                            }
                        }
                        .disabled(apiKey.isEmpty || isLoading)
                        
                        if !testResult.isEmpty {
                            Text(testResult)
                                .font(.caption)
                                .foregroundColor(testResult.contains("Success") ? .green : .red)
                        }
                    }
                }
                
                Section(header: Text("About AI Features")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("🤖 Smart Financial Analysis")
                            .font(.headline)
                        
                        Text("Our AI analyzes your spending patterns, income trends, and financial goals to provide personalized insights and recommendations.")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Text("📊 Advanced Insights")
                            .font(.headline)
                        
                        Text("Get detailed analysis of your spending habits, identify opportunities to save money, and receive actionable advice to improve your financial health.")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Text("🔒 Privacy & Security")
                            .font(.headline)
                        
                        Text("Your financial data is processed securely. When using real AI, data is sent to OpenAI's servers for analysis but is not stored permanently.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                Section(header: Text("Cost Information")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("💰 API Usage Costs")
                            .font(.headline)
                        
                        Text("• Mock AI: Free (built-in analysis)")
                        Text("• Real AI (GPT): ~$0.01-0.05 per analysis")
                        Text("• Typical monthly cost: $1-5 for regular use")
                        
                        Text("💡 Tips to Minimize Costs")
                            .font(.headline)
                            .padding(.top, 8)
                        
                        Text("• Use mock AI for basic insights")
                        Text("• Enable real AI only for detailed analysis")
                        Text("• AI insights are cached to reduce API calls")
                    }
                    .font(.body)
                    .foregroundColor(.secondary)
                }
            }
            .navigationTitle("AI Settings")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadSettings()
            }
            .alert("API Key Required", isPresented: $showingAPIKeyAlert) {
                Button("OK") { }
            } message: {
                Text("Please enter your OpenAI API key to use real AI features.")
            }
            .alert("Test Result", isPresented: $showingTestAlert) {
                Button("OK") { }
            } message: {
                Text(testResult)
            }
        }
    }
    
    private func loadSettings() {
        useRealAI = UserDefaults.standard.bool(forKey: "useRealAI")
        apiKey = UserDefaults.standard.string(forKey: "openai_api_key") ?? ""
    }
    
    private func testAIConnection() {
        guard !apiKey.isEmpty else {
            showingAPIKeyAlert = true
            return
        }
        
        isLoading = true
        testResult = ""
        
        Task {
            do {
                let aiService = OpenAIService(apiKey: apiKey)
                let testProfile = UserFinancialProfile(
                    totalMonthlyIncome: 3000,
                    totalMonthlyExpenses: 2500,
                    topSpendingCategories: [("Food", 500), ("Rent", 1200)],
                    netIncome: 500,
                    spendingTrends: ["January": 2500, "February": 2400],
                    incomeTrends: [:],
                    userGoals: []
                )
                
                let advice = try await aiService.generatePersonalizedAdvice(userData: testProfile)
                
                await MainActor.run {
                    isLoading = false
                    testResult = "✅ Success! AI connection working. Response: \(String(advice.prefix(100)))..."
                    showingTestAlert = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    testResult = "❌ Error: \(error.localizedDescription)"
                    showingTestAlert = true
                }
            }
        }
    }
}

#Preview {
    AISettingsView()
}
