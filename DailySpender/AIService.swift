//
//  AIService.swift
//  DailySpender
//
//  Created by Khang Lam on 7/29/25.
//

import Foundation

// MARK: - AI Service Protocol
protocol AIServiceProtocol {
    func generateFinancialInsights(
        expenses: [Expense],
        incomes: [Income],
        monthlySummary: MonthlySummary
    ) async throws -> [FinancialInsight]
    
    func generatePersonalizedAdvice(
        userData: UserFinancialProfile
    ) async throws -> String
}

// MARK: - User Financial Profile
struct UserFinancialProfile {
    let totalMonthlyIncome: Double
    let totalMonthlyExpenses: Double
    let topSpendingCategories: [(String, Double)]
    let netIncome: Double
    let spendingTrends: [String: Double] // category -> amount
    let incomeTrends: [String: Double] // month -> amount
    let userGoals: [String] // optional user-defined goals
}

// MARK: - OpenAI AI Service
class OpenAIService: AIServiceProtocol {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    // MARK: - Generate Financial Insights
    func generateFinancialInsights(
        expenses: [Expense],
        incomes: [Income],
        monthlySummary: MonthlySummary
    ) async throws -> [FinancialInsight] {
        
        let userProfile = createUserProfile(
            expenses: expenses,
            incomes: incomes,
            monthlySummary: monthlySummary
        )
        
        let prompt = createInsightsPrompt(userProfile: userProfile)
        
        let response = try await makeAPICall(prompt: prompt)
        return parseInsightsResponse(response)
    }
    
    // MARK: - Generate Personalized Advice
    func generatePersonalizedAdvice(userData: UserFinancialProfile) async throws -> String {
        let prompt = createAdvicePrompt(userProfile: userData)
        let response = try await makeAPICall(prompt: prompt)
        return response
    }
    
    // MARK: - Private Methods
    
    private func createUserProfile(
        expenses: [Expense],
        incomes: [Income],
        monthlySummary: MonthlySummary
    ) -> UserFinancialProfile {
        
        // Calculate top spending categories
        let categoryTotals = Dictionary(grouping: expenses, by: { $0.category.rawValue })
            .mapValues { expenses in expenses.reduce(0) { $0 + $1.cost } }
        
        let topCategories = categoryTotals
            .sorted { $0.value > $1.value }
            .prefix(5)
            .map { ($0.key, $0.value) }
        
        // Calculate spending trends (last 3 months)
        let calendar = Calendar.current
        let currentDate = Date()
        var spendingTrends: [String: Double] = [:]
        
        for i in 0..<3 {
            let date = calendar.date(byAdding: .month, value: -i, to: currentDate) ?? currentDate
            let month = calendar.component(.month, from: date)
            let year = calendar.component(.year, from: date)
            
            let monthlyExpenses = expenses.filter {
                calendar.component(.month, from: $0.date) == month &&
                calendar.component(.year, from: $0.date) == year
            }
            
            let monthTotal = monthlyExpenses.reduce(0) { $0 + $1.cost }
            let monthName = DateFormatter().monthSymbols[month - 1]
            spendingTrends[monthName] = monthTotal
        }
        
        return UserFinancialProfile(
            totalMonthlyIncome: monthlySummary.totalIncome,
            totalMonthlyExpenses: monthlySummary.totalExpenses,
            topSpendingCategories: Array(topCategories),
            netIncome: monthlySummary.netIncome,
            spendingTrends: spendingTrends,
            incomeTrends: [:], // Can be enhanced later
            userGoals: [] // Can be added from user settings
        )
    }
    
    private func createInsightsPrompt(userProfile: UserFinancialProfile) -> String {
        return """
        You are a professional financial advisor AI. Analyze the following user's financial data and provide 3-5 personalized, actionable financial insights.
        
        User Financial Data:
        - Monthly Income: $\(String(format: "%.2f", userProfile.totalMonthlyIncome))
        - Monthly Expenses: $\(String(format: "%.2f", userProfile.totalMonthlyExpenses))
        - Net Income: $\(String(format: "%.2f", userProfile.netIncome))
        - Top Spending Categories: \(userProfile.topSpendingCategories.map { "\($0.0): $\(String(format: "%.2f", $0.1))" }.joined(separator: ", "))
        - Spending Trends: \(userProfile.spendingTrends.map { "\($0.key): $\(String(format: "%.2f", $0.value))" }.joined(separator: ", "))
        
        Please provide insights in the following JSON format:
        {
            "insights": [
                {
                    "title": "Insight Title",
                    "message": "Detailed explanation of the insight",
                    "type": "spending|saving|income|budget|warning",
                    "priority": "high|medium|low",
                    "actionItems": ["Action 1", "Action 2", "Action 3"]
                }
            ]
        }
        
        Guidelines:
        1. Be specific and actionable
        2. Consider the user's spending patterns
        3. Provide practical advice
        4. Use appropriate priority levels
        5. Include 2-4 action items per insight
        6. Be encouraging but honest about financial health
        """
    }
    
    private func createAdvicePrompt(userProfile: UserFinancialProfile) -> String {
        return """
        You are a personal financial coach. Based on this user's financial situation, provide a personalized 2-3 paragraph advice.
        
        Financial Situation:
        - Monthly Income: $\(String(format: "%.2f", userProfile.totalMonthlyIncome))
        - Monthly Expenses: $\(String(format: "%.2f", userProfile.totalMonthlyExpenses))
        - Net Income: $\(String(format: "%.2f", userProfile.netIncome))
        - Top Spending: \(userProfile.topSpendingCategories.prefix(3).map { $0.0 }.joined(separator: ", "))
        
        Provide encouraging, practical advice that helps them improve their financial health. Be specific and actionable.
        """
    }
    
    private func makeAPICall(prompt: String) async throws -> String {
        guard let url = URL(string: baseURL) else {
            throw AIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "max_tokens": 1000,
            "temperature": 0.7
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIError.apiError("API request failed")
        }
        
        let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let choices = jsonResponse?["choices"] as? [[String: Any]]
        let message = choices?.first?["message"] as? [String: Any]
        let content = message?["content"] as? String
        
        guard let content = content else {
            throw AIError.invalidResponse
        }
        
        return content
    }
    
    private func parseInsightsResponse(_ response: String) -> [FinancialInsight] {
        var insights: [FinancialInsight] = []
        
        do {
            // Try to parse JSON response
            if let data = response.data(using: .utf8),
               let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let insightsArray = json["insights"] as? [[String: Any]] {
                
                for insightData in insightsArray {
                    if let title = insightData["title"] as? String,
                       let message = insightData["message"] as? String,
                       let typeString = insightData["type"] as? String,
                       let priorityString = insightData["priority"] as? String,
                       let actionItems = insightData["actionItems"] as? [String] {
                        
                        let type = parseInsightType(typeString)
                        let priority = parsePriority(priorityString)
                        
                        let insight = FinancialInsight(
                            title: title,
                            message: message,
                            type: type,
                            priority: priority,
                            actionItems: actionItems
                        )
                        
                        insights.append(insight)
                    }
                }
            }
        } catch {
            // Fallback: create a generic insight if JSON parsing fails
            insights.append(FinancialInsight(
                title: "AI Analysis Complete",
                message: response,
                type: .budget,
                priority: .medium,
                actionItems: ["Review the analysis above", "Consider implementing suggested changes"]
            ))
        }
        
        return insights
    }
    
    private func parseInsightType(_ typeString: String) -> FinancialInsight.InsightType {
        switch typeString.lowercased() {
        case "spending": return .spending
        case "saving": return .saving
        case "income": return .income
        case "budget": return .budget
        case "warning": return .warning
        default: return .budget
        }
    }
    
    private func parsePriority(_ priorityString: String) -> FinancialInsight.Priority {
        switch priorityString.lowercased() {
        case "high": return .high
        case "medium": return .medium
        case "low": return .low
        default: return .medium
        }
    }
}

// MARK: - AI Errors
enum AIError: Error, LocalizedError {
    case invalidURL
    case apiError(String)
    case invalidResponse
    case noAPIKey
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .apiError(let message):
            return "API Error: \(message)"
        case .invalidResponse:
            return "Invalid response from AI service"
        case .noAPIKey:
            return "OpenAI API key not configured"
        }
    }
}

// MARK: - Mock AI Service (for testing without API key)
class MockAIService: AIServiceProtocol {
    func generateFinancialInsights(
        expenses: [Expense],
        incomes: [Income],
        monthlySummary: MonthlySummary
    ) async throws -> [FinancialInsight] {
        
        // Simulate API delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        var insights: [FinancialInsight] = []
        
        // Generate mock insights based on data
        if monthlySummary.netIncome < 0 {
            insights.append(FinancialInsight(
                title: "⚠️ Overspending Alert",
                message: "You're spending $\(String(format: "%.2f", abs(monthlySummary.netIncome))) more than you earn. This is unsustainable long-term.",
                type: .warning,
                priority: .high,
                actionItems: [
                    "Review and eliminate unnecessary expenses",
                    "Look for ways to increase income",
                    "Create a strict monthly budget"
                ]
            ))
        }
        
        if let topCategory = monthlySummary.categoryBreakdown.max(by: { $0.value < $1.value }) {
            let percentage = (topCategory.value / monthlySummary.totalExpenses) * 100
            insights.append(FinancialInsight(
                title: "Top Spending Category",
                message: "You spend \(String(format: "%.1f", percentage))% of your budget on \(topCategory.key.rawValue). Consider if this aligns with your priorities.",
                type: .spending,
                priority: .medium,
                actionItems: [
                    "Set a monthly limit for \(topCategory.key.rawValue)",
                    "Track daily spending in this category",
                    "Look for ways to reduce costs"
                ]
            ))
        }
        
        if monthlySummary.totalIncome > 0 {
            let savingsRate = (monthlySummary.netIncome / monthlySummary.totalIncome) * 100
            if savingsRate < 20 {
                insights.append(FinancialInsight(
                    title: "Savings Opportunity",
                    message: "You're saving \(String(format: "%.1f", savingsRate))% of your income. Financial experts recommend saving at least 20%.",
                    type: .saving,
                    priority: .medium,
                    actionItems: [
                        "Set up automatic savings transfers",
                        "Review expenses to find savings opportunities",
                        "Consider the 50/30/20 budget rule"
                    ]
                ))
            }
        }
        
        return insights
    }
    
    func generatePersonalizedAdvice(userData: UserFinancialProfile) async throws -> String {
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        if userData.netIncome < 0 {
            return """
            I notice you're spending more than you earn this month. This is a critical situation that needs immediate attention. 
            
            Here's what I recommend: First, create a detailed budget that accounts for every dollar. Cut non-essential expenses immediately. Look for ways to increase your income through side gigs or freelance work. Consider using the envelope method to control spending in problem categories.
            
            Remember, small changes compound over time. Even saving $50-100 per month can make a significant difference in your financial health.
            """
        } else {
            return """
            Great job on maintaining a positive cash flow! You're on the right track to building wealth.
            
            To optimize your financial situation further, consider automating your savings and investments. Set up automatic transfers to a high-yield savings account and consider investing in low-cost index funds. Track your spending patterns to identify areas where you can optimize without sacrificing your lifestyle.
            
            Keep up the excellent work, and remember that consistency is key to long-term financial success!
            """
        }
    }
}
