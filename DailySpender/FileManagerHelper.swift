//
//  FileManagerHelper.swift
//  DailySpender
//
//  Created by Khang Lam on 7/29/25.
//

import Foundation

class FileManagerHelper {
    static let shared = FileManagerHelper()
    private let fileName = "expenses.json"
    
    private var fileURL: URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths.first?.appendingPathComponent(fileName)
    }

    
    func save(_ expenses: [Expense]) {
        guard let url = fileURL else { return }
        do {
            let data = try JSONEncoder().encode(expenses)
            try data.write(to: url)
        } catch {
            print("Error saving expenses: \(error)")
        }
    }
    
    func load() -> [Expense] {
        guard let url = fileURL else { return [] }
        do {
            let data = try Data(contentsOf: url)
            let expenses = try JSONDecoder().decode([Expense].self, from: data)
            return expenses
        } catch {
            return []
        }
    }
}
