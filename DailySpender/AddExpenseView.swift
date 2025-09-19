//
//  AddExpenseView.swift
//  DailySpender
//
//  Created by Khang Lam on 7/29/25.
//

import SwiftUI

struct AddExpenseView: View {
    @EnvironmentObject var viewModel: ExpenseViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var date = Date()
    @State private var name = ""
    @State private var selectedCategory = ExpenseCategory.food
    @State private var cost = ""
    @State private var note = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Expense Details")) {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    TextField("Expense Name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(ExpenseCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(Color(category.color))
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    TextField("Amount", text: $cost)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Note (optional)", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section {
                    Button(action: saveExpense) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Expense")
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    .disabled(amount.isEmpty || name.isEmpty)
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private var amount: String {
        cost
    }
    
    private func saveExpense() {
        guard let costValue = Double(cost), costValue > 0 else { return }
        
        let expense = Expense(
            date: date,
            name: name,
            category: selectedCategory,
            cost: costValue,
            note: note
        )
        
        viewModel.addExpense(expense)
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    AddExpenseView()
        .environmentObject(ExpenseViewModel())
}
