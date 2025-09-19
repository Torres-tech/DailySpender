//
//  FileManagerHelper.swift
//  DailySpender
//
//  Created by Khang Lam on 7/29/25.
//

import Foundation

class FileManagerHelper {
    static let shared = FileManagerHelper()
    private let expensesFileName = "expenses.json"
    private let incomesFileName = "incomes.json"
    
    private var expensesFileURL: URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths.first?.appendingPathComponent(expensesFileName)
    }
    
    private var incomesFileURL: URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths.first?.appendingPathComponent(incomesFileName)
    }
    
    // MARK: - Expense Management
    func saveExpenses(_ expenses: [Expense]) {
        guard let url = expensesFileURL else { return }
        do {
            let data = try JSONEncoder().encode(expenses)
            try data.write(to: url)
        } catch {
            print("Error saving expenses: \(error)")
        }
    }
    
    func loadExpenses() -> [Expense] {
        guard let url = expensesFileURL else { return [] }
        do {
            let data = try Data(contentsOf: url)
            let expenses = try JSONDecoder().decode([Expense].self, from: data)
            return expenses
        } catch {
            print("Error loading expenses: \(error)")
            return []
        }
    }
    
    // MARK: - Income Management
    func saveIncomes(_ incomes: [Income]) {
        print("💾 saveIncomes called with \(incomes.count) incomes")
        guard let url = incomesFileURL else { 
            print("❌ No URL for incomes file")
            return 
        }
        print("💾 Saving to URL: \(url)")
        do {
            let data = try JSONEncoder().encode(incomes)
            try data.write(to: url)
            print("✅ Incomes saved successfully")
        } catch {
            print("❌ Error saving incomes: \(error)")
        }
    }
    
    func loadIncomes() -> [Income] {
        print("📂 loadIncomes called")
        guard let url = incomesFileURL else { 
            print("❌ No URL for incomes file")
            return [] 
        }
        print("📂 Loading from URL: \(url)")
        do {
            let data = try Data(contentsOf: url)
            let incomes = try JSONDecoder().decode([Income].self, from: data)
            print("✅ Loaded \(incomes.count) incomes")
            return incomes
        } catch {
            print("❌ Error loading incomes: \(error)")
            return []
        }
    }
    
    // MARK: - Legacy Support (for backward compatibility)
    func save(_ expenses: [Expense]) {
        saveExpenses(expenses)
    }
    
    func load() -> [Expense] {
        return loadExpenses()
    }
}
