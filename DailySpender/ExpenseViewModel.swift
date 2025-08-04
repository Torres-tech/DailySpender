//
//  ExpenseViewModel.swift
//  DailySpender
//
//  Created by Khang Lam on 7/29/25.
//

import Foundation

class ExpenseViewModel: ObservableObject {
    @Published var expenses: [Expense] = []
    
    init() {
        expenses = FileManagerHelper.shared.load()
    }
    
    func addExpense(_ expense: Expense) {
        expenses.append(expense)
        FileManagerHelper.shared.save(expenses)
    }
    
    func expenses(forMonth month: Int, year: Int) -> [Expense] {
        expenses.filter {
            Calendar.current.component(.month, from: $0.date) == month &&
            Calendar.current.component(.year, from: $0.date) == year
        }
    }
}
