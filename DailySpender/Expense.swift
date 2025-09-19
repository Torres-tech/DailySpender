//
//  Expense.swift
//  DailySpender
//
//  Created by Khang Lam on 7/29/25.
//

import Foundation

// MARK: - Expense Categories
enum ExpenseCategory: String, CaseIterable, Codable {
    case gas = "Gas"
    case food = "Food"
    case drink = "Drink"
    case market = "Market"
    case entertainment = "Entertainment"
    case transportation = "Transportation"
    case healthcare = "Healthcare"
    case education = "Education"
    case shopping = "Shopping"
    case utilities = "Utilities"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .gas: return "fuelpump.fill"
        case .food: return "fork.knife"
        case .drink: return "cup.and.saucer.fill"
        case .market: return "cart.fill"
        case .entertainment: return "tv.fill"
        case .transportation: return "car.fill"
        case .healthcare: return "cross.fill"
        case .education: return "book.fill"
        case .shopping: return "bag.fill"
        case .utilities: return "bolt.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .gas: return "orange"
        case .food: return "green"
        case .drink: return "blue"
        case .market: return "purple"
        case .entertainment: return "pink"
        case .transportation: return "red"
        case .healthcare: return "red"
        case .education: return "indigo"
        case .shopping: return "yellow"
        case .utilities: return "gray"
        case .other: return "brown"
        }
    }
}

// MARK: - Income Types
enum IncomeType: String, CaseIterable, Codable {
    case salary = "Salary"
    case freelance = "Freelance"
    case investment = "Investment"
    case business = "Business"
    case gift = "Gift"
    case bonus = "Bonus"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .salary: return "dollarsign.circle.fill"
        case .freelance: return "laptopcomputer"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .business: return "building.2.fill"
        case .gift: return "gift.fill"
        case .bonus: return "star.fill"
        case .other: return "plus.circle.fill"
        }
    }
}

// MARK: - Expense Model
struct Expense: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var name: String
    var category: ExpenseCategory
    var cost: Double
    var note: String
    
    init(date: Date, name: String, category: ExpenseCategory, cost: Double, note: String) {
        self.date = date
        self.name = name
        self.category = category
        self.cost = cost
        self.note = note
    }
}

// MARK: - Income Model
struct Income: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var source: String
    var type: IncomeType
    var amount: Double
    var note: String
    
    init(date: Date, source: String, type: IncomeType, amount: Double, note: String) {
        self.date = date
        self.source = source
        self.type = type
        self.amount = amount
        self.note = note
    }
}

// MARK: - Monthly Summary
struct MonthlySummary: Identifiable {
    var id = UUID()
    var month: Int
    var year: Int
    var totalExpenses: Double
    var totalIncome: Double
    var categoryBreakdown: [ExpenseCategory: Double]
    var netIncome: Double {
        totalIncome - totalExpenses
    }
}

// MARK: - AI Financial Insight
struct FinancialInsight: Identifiable {
    var id = UUID()
    var title: String
    var message: String
    var type: InsightType
    var priority: Priority
    var actionItems: [String]
    
    enum InsightType {
        case spending
        case saving
        case income
        case budget
        case warning
    }
    
    enum Priority {
        case high
        case medium
        case low
    }
}
