//
//  Expense.swift
//  DailySpender
//
//  Created by Khang Lam on 7/29/25.
//

import Foundation

struct Expense: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var name: String
    var category: String
    var cost: Double
    var note: String
}
