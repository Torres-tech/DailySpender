//
//  AddExpenseView.swift
//  DailySpender
//
//  Created by Khang Lam on 7/29/25.
//

import SwiftUI

struct AddExpenseView: View {
    @EnvironmentObject var viewModel: ExpenseViewModel
    
    @State private var date = Date()
    @State private var name = ""
    @State private var category = ""
    @State private var cost = ""
    @State private var note =  ""
    
    var body: some View {
        Form {
            DatePicker("Date", selection: $date, displayedComponents: .date)
            TextField("Name", text: $name)
            TextField("Category", text: $category)
            TextField("Cost", text: $cost)
                .keyboardType(.decimalPad)
            TextField("Note", text: $note)
            
            Button("Save") {
                guard let costValue = Double(cost) else { return }
                let expense = Expense(date: date, name: name, category: category, cost: costValue, note: note)
                viewModel.addExpense(expense)
                clearForm()
            }
        }
        .navigationTitle("Add Expense")
    }
    
    private func clearForm() {
        name = ""
        category = ""
        cost = ""
        note = ""
        date = Date()
    }
}
