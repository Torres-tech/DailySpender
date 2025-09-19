//
//  AddIncomeView.swift
//  DailySpender
//
//  Created by Khang Lam on 7/29/25.
//

import SwiftUI

struct AddIncomeView: View {
    @EnvironmentObject var viewModel: ExpenseViewModel
    @State private var showingSuccessAlert = false
    
    @State private var date = Date()
    @State private var source = ""
    @State private var selectedType = IncomeType.salary
    @State private var amount = ""
    @State private var note = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("💰 Add Income")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.green)
            
            Form {
                Section(header: Text("Income Details")) {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    TextField("Source (e.g., Company Name)", text: $source)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Picker("Income Type", selection: $selectedType) {
                        ForEach(IncomeType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                    .foregroundColor(.green)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Note (optional)", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section {
                    Button(action: saveIncome) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Income")
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                    }
                    .disabled(amount.isEmpty || source.isEmpty)
                }
            }
        }
        .navigationTitle("Add Income")
        .navigationBarTitleDisplayMode(.large)
        .alert("Income Added!", isPresented: $showingSuccessAlert) {
            Button("OK") {
                clearForm()
            }
        } message: {
            Text("Your income has been successfully added to your records.")
        }
    }
    
    private func saveIncome() {
        guard let amountValue = Double(amount), amountValue > 0 else { 
            print("❌ Invalid amount: \(amount)")
            return 
        }
        
        print("✅ Creating income: \(source) - \(amountValue) - \(selectedType.rawValue)")
        
        let income = Income(
            date: date,
            source: source,
            type: selectedType,
            amount: amountValue,
            note: note
        )
        
        print("✅ Income created successfully, calling viewModel.addIncome")
        viewModel.addIncome(income)
        print("✅ viewModel.addIncome completed")
        showingSuccessAlert = true
        print("✅ Success alert set to true")
    }
    
    private func clearForm() {
        source = ""
        amount = ""
        note = ""
        date = Date()
        selectedType = IncomeType.salary
    }
}

#Preview {
    AddIncomeView()
        .environmentObject(ExpenseViewModel())
}
