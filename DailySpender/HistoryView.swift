//
//  HistoryView.swift
//  DailySpender
//
//  Created by Khang Lam on 7/29/25.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var viewModel: ExpenseViewModel
    
    
    let formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        return df
    }()
    
    
    var body: some View {
        List(viewModel.expenses.sorted(by: { $0.date > $1.date})) {expense in
            VStack(alignment: .leading){
                Text(expense.name).font(.headline)
                Text("Category: \(expense.category)")
                Text("Cost: $\(expense.cost, specifier: "%.2f")")
                Text("Note: \(expense.note)")
                Text("Date: \(expense.date, formatter: formatter)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle("Speding History")
    }
}
