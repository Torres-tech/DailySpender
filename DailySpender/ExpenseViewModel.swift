//
//  ExpenseViewModel.swift
//  DailySpender
//
//  Created by Khang Lam on 7/29/25.
//

import Foundation

class ExpenseViewModel: ObservableObject {
    @Published var expenses: [Expense] = []
    @Published var incomes: [Income] = []
    @Published var insights: [FinancialInsight] = []
    @Published var isLoadingAI = false
    @Published var aiError: String?
    
    private var aiService: AIServiceProtocol
    
    init() {
        // Initialize AI service first
        if UserDefaults.standard.bool(forKey: "useRealAI"),
           let apiKey = UserDefaults.standard.string(forKey: "openai_api_key"),
           !apiKey.isEmpty {
            aiService = OpenAIService(apiKey: apiKey)
        } else {
            aiService = MockAIService()
        }
        
        // Load and clean data
        let loadedExpenses = FileManagerHelper.shared.loadExpenses()
        let loadedIncomes = FileManagerHelper.shared.loadIncomes()
        
        // Remove any duplicates that might have been loaded
        expenses = removeDuplicateExpenses(loadedExpenses)
        incomes = removeDuplicateIncomes(loadedIncomes)
        
        generateInsights()
    }
    
    // MARK: - Duplicate Removal Helpers
    private func removeDuplicateExpenses(_ expenses: [Expense]) -> [Expense] {
        var seenIds: Set<UUID> = []
        var uniqueExpenses: [Expense] = []
        
        for expense in expenses {
            if !seenIds.contains(expense.id) {
                seenIds.insert(expense.id)
                uniqueExpenses.append(expense)
            }
        }
        
        return uniqueExpenses
    }
    
    private func removeDuplicateIncomes(_ incomes: [Income]) -> [Income] {
        var seenIds: Set<UUID> = []
        var uniqueIncomes: [Income] = []
        
        for income in incomes {
            if !seenIds.contains(income.id) {
                seenIds.insert(income.id)
                uniqueIncomes.append(income)
            }
        }
        
        return uniqueIncomes
    }
    
    // MARK: - Data Cleanup
    func cleanupDuplicates() {
        print("🧹 Starting duplicate cleanup...")
        let originalExpenseCount = expenses.count
        let originalIncomeCount = incomes.count
        
        expenses = removeDuplicateExpenses(expenses)
        incomes = removeDuplicateIncomes(incomes)
        
        let newExpenseCount = expenses.count
        let newIncomeCount = incomes.count
        
        print("🧹 Cleanup complete:")
        print("   Expenses: \(originalExpenseCount) → \(newExpenseCount) (removed \(originalExpenseCount - newExpenseCount))")
        print("   Incomes: \(originalIncomeCount) → \(newIncomeCount) (removed \(originalIncomeCount - newIncomeCount))")
        
        // Save the cleaned data
        FileManagerHelper.shared.saveExpenses(expenses)
        FileManagerHelper.shared.saveIncomes(incomes)
        
        generateInsights()
    }
    
    // MARK: - Expense Management
    func addExpense(_ expense: Expense) {
        // Check for duplicates before adding
        let isDuplicate = expenses.contains { existingExpense in
            existingExpense.id == expense.id ||
            (existingExpense.name == expense.name &&
             existingExpense.cost == expense.cost &&
             existingExpense.category == expense.category &&
             Calendar.current.isDate(existingExpense.date, inSameDayAs: expense.date))
        }
        
        if !isDuplicate {
            expenses.append(expense)
            FileManagerHelper.shared.saveExpenses(expenses)
            generateInsights()
        }
    }
    
    func deleteExpense(_ expense: Expense) {
        expenses.removeAll { $0.id == expense.id }
        FileManagerHelper.shared.saveExpenses(expenses)
        generateInsights()
    }
    
    func expenses(forMonth month: Int, year: Int) -> [Expense] {
        expenses.filter {
            Calendar.current.component(.month, from: $0.date) == month &&
            Calendar.current.component(.year, from: $0.date) == year
        }
    }
    
    // MARK: - Income Management
    func addIncome(_ income: Income) {
        print("🔍 addIncome called with: \(income.source) - \(income.amount)")
        print("🔍 Current incomes count: \(incomes.count)")
        
        // Check for duplicates before adding
        let isDuplicate = incomes.contains { existingIncome in
            existingIncome.id == income.id ||
            (existingIncome.source == income.source &&
             existingIncome.amount == income.amount &&
             Calendar.current.isDate(existingIncome.date, inSameDayAs: income.date))
        }
        
        print("🔍 Is duplicate: \(isDuplicate)")
        
        if !isDuplicate {
            incomes.append(income)
            print("✅ Income added to array. New count: \(incomes.count)")
            FileManagerHelper.shared.saveIncomes(incomes)
            print("✅ Income saved to file")
            generateInsights()
            print("✅ Insights regenerated")
        } else {
            print("❌ Duplicate income detected, not adding")
        }
    }
    
    func deleteIncome(_ income: Income) {
        incomes.removeAll { $0.id == income.id }
        FileManagerHelper.shared.saveIncomes(incomes)
        generateInsights()
    }
    
    func incomes(forMonth month: Int, year: Int) -> [Income] {
        incomes.filter {
            Calendar.current.component(.month, from: $0.date) == month &&
            Calendar.current.component(.year, from: $0.date) == year
        }
    }
    
    // MARK: - Monthly Summary
    func getMonthlySummary(month: Int, year: Int) -> MonthlySummary {
        let monthlyExpenses = expenses(forMonth: month, year: year)
        let monthlyIncomes = incomes(forMonth: month, year: year)
        
        let totalExpenses = monthlyExpenses.reduce(0) { $0 + $1.cost }
        let totalIncome = monthlyIncomes.reduce(0) { $0 + $1.amount }
        
        var categoryBreakdown: [ExpenseCategory: Double] = [:]
        for expense in monthlyExpenses {
            categoryBreakdown[expense.category, default: 0] += expense.cost
        }
        
        return MonthlySummary(
            month: month,
            year: year,
            totalExpenses: totalExpenses,
            totalIncome: totalIncome,
            categoryBreakdown: categoryBreakdown
        )
    }
    
    // MARK: - AI Insights Generation
    func generateInsights() {
        Task {
            await generateInsightsAsync()
        }
    }
    
    @MainActor
    private func generateInsightsAsync() async {
        isLoadingAI = true
        aiError = nil
        
        do {
            let currentDate = Date()
            let calendar = Calendar.current
            let currentMonth = calendar.component(.month, from: currentDate)
            let currentYear = calendar.component(.year, from: currentDate)
            
            let currentSummary = getMonthlySummary(month: currentMonth, year: currentYear)
            
            // Generate insights using AI service
            let newInsights = try await aiService.generateFinancialInsights(
                expenses: expenses,
                incomes: incomes,
                monthlySummary: currentSummary
            )
            
            insights = newInsights
            
        } catch {
            aiError = error.localizedDescription
            // Fallback to basic insights if AI fails
            generateBasicInsights()
        }
        
        isLoadingAI = false
    }
    
    private func generateBasicInsights() {
        insights.removeAll()
        
        let currentDate = Date()
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentYear = calendar.component(.year, from: currentDate)
        
        let currentSummary = getMonthlySummary(month: currentMonth, year: currentYear)
        
        // Basic spending analysis
        if currentSummary.totalExpenses > 0 {
            let topCategory = currentSummary.categoryBreakdown.max { $0.value < $1.value }
            if let top = topCategory {
                insights.append(FinancialInsight(
                    title: "Top Spending Category",
                    message: "You spent $\(String(format: "%.2f", top.value)) on \(top.key.rawValue) this month, which is \(String(format: "%.1f", (top.value / currentSummary.totalExpenses) * 100))% of your total expenses.",
                    type: .spending,
                    priority: .medium,
                    actionItems: ["Consider setting a budget for \(top.key.rawValue)", "Track daily spending in this category"]
                ))
            }
        }
        
        // Net income analysis
        if currentSummary.netIncome < 0 {
            insights.append(FinancialInsight(
                title: "⚠️ Overspending Alert",
                message: "You spent $\(String(format: "%.2f", abs(currentSummary.netIncome))) more than you earned this month. This is not sustainable long-term.",
                type: .warning,
                priority: .high,
                actionItems: ["Review and reduce unnecessary expenses", "Look for ways to increase income", "Create a strict budget"]
            ))
        } else if currentSummary.netIncome > 0 {
            insights.append(FinancialInsight(
                title: "💰 Great Job!",
                message: "You saved $\(String(format: "%.2f", currentSummary.netIncome)) this month. Consider investing or building an emergency fund.",
                type: .saving,
                priority: .medium,
                actionItems: ["Set up automatic savings", "Consider investment options", "Build emergency fund"]
            ))
        }
    }
    
    // MARK: - AI Service Management
    func updateAIService() {
        // Reinitialize AI service when settings change
        if UserDefaults.standard.bool(forKey: "useRealAI"),
           let apiKey = UserDefaults.standard.string(forKey: "openai_api_key"),
           !apiKey.isEmpty {
            aiService = OpenAIService(apiKey: apiKey)
        } else {
            aiService = MockAIService()
        }
        
        // Regenerate insights with new service
        generateInsights()
    }
    
    func generatePersonalizedAdvice() async -> String {
        let currentDate = Date()
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentYear = calendar.component(.year, from: currentDate)
        
        let currentSummary = getMonthlySummary(month: currentMonth, year: currentYear)
        
        let userProfile = UserFinancialProfile(
            totalMonthlyIncome: currentSummary.totalIncome,
            totalMonthlyExpenses: currentSummary.totalExpenses,
            topSpendingCategories: currentSummary.categoryBreakdown.map { ($0.key.rawValue, $0.value) },
            netIncome: currentSummary.netIncome,
            spendingTrends: [:], // Can be enhanced
            incomeTrends: [:], // Can be enhanced
            userGoals: [] // Can be added from user settings
        )
        
        do {
            return try await aiService.generatePersonalizedAdvice(userData: userProfile)
        } catch {
            return "Unable to generate personalized advice at this time. Please check your AI settings."
        }
    }
    
    // MARK: - Chart Data
    func getChartData(forMonth month: Int, year: Int) -> [(String, Double, String)] {
        let summary = getMonthlySummary(month: month, year: year)
        return summary.categoryBreakdown.map { category, amount in
            (category.rawValue, amount, category.color)
        }.sorted { $0.1 > $1.1 }
    }
    
    func getMonthlyTrendData() -> [(String, Double, Double)] {
        let calendar = Calendar.current
        let currentDate = Date()
        var trendData: [(String, Double, Double)] = []
        
        // Get last 6 months
        for i in 0..<6 {
            let date = calendar.date(byAdding: .month, value: -i, to: currentDate) ?? currentDate
            let month = calendar.component(.month, from: date)
            let year = calendar.component(.year, from: date)
            let summary = getMonthlySummary(month: month, year: year)
            
            let monthName = DateFormatter().monthSymbols[month - 1]
            trendData.append((monthName, summary.totalExpenses, summary.totalIncome))
        }
        
        return trendData.reversed()
    }
}
