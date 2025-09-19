//
//  HistoryView.swift
//  DailySpender
//
//  Created by Khang Lam on 7/29/25.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var viewModel: ExpenseViewModel
    @State private var selectedSegment = 0
    
    let formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        return df
    }()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Segment Control
                Picker("Type", selection: $selectedSegment) {
                    Text("All").tag(0)
                    Text("Expenses").tag(1)
                    Text("Income").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content
                if selectedSegment == 0 {
                    AllTransactionsView()
                } else if selectedSegment == 1 {
                    ExpensesListView()
                } else {
                    IncomeListView()
                }
            }
            .navigationTitle("Transaction History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clean Duplicates") {
                        viewModel.cleanupDuplicates()
                    }
                    .font(.caption)
                }
            }
        }
    }
}

struct AllTransactionsView: View {
    @EnvironmentObject var viewModel: ExpenseViewModel
    @State private var showingDeleteAlert = false
    @State private var transactionToDelete: TransactionItem?
    
    let formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        return df
    }()
    
    var body: some View {
        let allTransactions = getAllTransactions()
        
        if allTransactions.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "list.bullet")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
                
                Text("No Transactions Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Add some expenses and income to see your transaction history!")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 50)
        } else {
            List(allTransactions) { transaction in
                TransactionRow(transaction: transaction)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button("Delete", role: .destructive) {
                            transactionToDelete = transaction
                            showingDeleteAlert = true
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        Button("Edit") {
                            // TODO: Add edit functionality
                        }
                        .tint(.blue)
                    }
            }
            .alert("Delete Transaction", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let transaction = transactionToDelete {
                        deleteTransaction(transaction)
                    }
                }
            } message: {
                if let transaction = transactionToDelete {
                    Text("Are you sure you want to delete '\(transaction.name)'? This action cannot be undone.")
                }
            }
        }
    }
    
    private func getAllTransactions() -> [TransactionItem] {
        var transactions: [TransactionItem] = []
        var seenIds: Set<UUID> = []
        
        // Add expenses (remove duplicates)
        for expense in viewModel.expenses {
            if !seenIds.contains(expense.id) {
                seenIds.insert(expense.id)
                transactions.append(TransactionItem(
                    id: expense.id,
                    date: expense.date,
                    name: expense.name,
                    amount: expense.cost,
                    type: .expense,
                    category: expense.category.rawValue,
                    note: expense.note
                ))
            }
        }
        
        // Add income (remove duplicates)
        for income in viewModel.incomes {
            if !seenIds.contains(income.id) {
                seenIds.insert(income.id)
                transactions.append(TransactionItem(
                    id: income.id,
                    date: income.date,
                    name: income.source,
                    amount: income.amount,
                    type: .income,
                    category: income.type.rawValue,
                    note: income.note
                ))
            }
        }
        
        return transactions.sorted { $0.date > $1.date }
    }
    
    private func deleteTransaction(_ transaction: TransactionItem) {
        if transaction.type == .expense {
            // Find and delete the expense
            if let expense = viewModel.expenses.first(where: { $0.id == transaction.id }) {
                viewModel.deleteExpense(expense)
            }
        } else {
            // Find and delete the income
            if let income = viewModel.incomes.first(where: { $0.id == transaction.id }) {
                viewModel.deleteIncome(income)
            }
        }
    }
}

struct ExpensesListView: View {
    @EnvironmentObject var viewModel: ExpenseViewModel
    @State private var showingDeleteAlert = false
    @State private var expenseToDelete: Expense?
    
    let formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        return df
    }()
    
    var body: some View {
        if viewModel.expenses.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "minus.circle")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                
                Text("No Expenses Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Add your first expense to start tracking!")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 50)
        } else {
            List(viewModel.expenses.sorted(by: { $0.date > $1.date })) { expense in
                ExpenseRow(expense: expense)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button("Delete", role: .destructive) {
                            expenseToDelete = expense
                            showingDeleteAlert = true
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        Button("Edit") {
                            // TODO: Add edit functionality
                        }
                        .tint(.blue)
                    }
            }
            .alert("Delete Expense", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let expense = expenseToDelete {
                        viewModel.deleteExpense(expense)
                    }
                }
            } message: {
                if let expense = expenseToDelete {
                    Text("Are you sure you want to delete '\(expense.name)'? This action cannot be undone.")
                }
            }
        }
    }
}

struct IncomeListView: View {
    @EnvironmentObject var viewModel: ExpenseViewModel
    @State private var showingDeleteAlert = false
    @State private var incomeToDelete: Income?
    
    let formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        return df
    }()
    
    var body: some View {
        if viewModel.incomes.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("No Income Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Add your first income to start tracking!")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 50)
        } else {
            List(viewModel.incomes.sorted(by: { $0.date > $1.date })) { income in
                IncomeRow(income: income)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button("Delete", role: .destructive) {
                            incomeToDelete = income
                            showingDeleteAlert = true
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        Button("Edit") {
                            // TODO: Add edit functionality
                        }
                        .tint(.blue)
                    }
            }
            .alert("Delete Income", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let income = incomeToDelete {
                        viewModel.deleteIncome(income)
                    }
                }
            } message: {
                if let income = incomeToDelete {
                    Text("Are you sure you want to delete '\(income.source)'? This action cannot be undone.")
                }
            }
        }
    }
}

// MARK: - Transaction Models
struct TransactionItem: Identifiable {
    let id: UUID
    let date: Date
    let name: String
    let amount: Double
    let type: TransactionType
    let category: String
    let note: String
    
    enum TransactionType {
        case expense
        case income
    }
}

// MARK: - Row Views
struct TransactionRow: View {
    let transaction: TransactionItem
    
    let formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        return df
    }()
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: transaction.type == .expense ? "minus.circle.fill" : "plus.circle.fill")
                        .foregroundColor(transaction.type == .expense ? .red : .green)
                    
                    Text(transaction.name)
                        .font(.headline)
                        .fontWeight(.medium)
                }
                
                Text(transaction.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !transaction.note.isEmpty {
                    Text(transaction.note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Text(transaction.date, formatter: formatter)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("\(transaction.type == .expense ? "-" : "+")$\(transaction.amount, specifier: "%.2f")")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(transaction.type == .expense ? .red : .green)
        }
        .padding(.vertical, 4)
    }
}

struct ExpenseRow: View {
    let expense: Expense
    
    let formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        return df
    }()
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: expense.category.icon)
                        .foregroundColor(Color(expense.category.color))
                    
                    Text(expense.name)
                        .font(.headline)
                        .fontWeight(.medium)
                }
                
                Text(expense.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !expense.note.isEmpty {
                    Text(expense.note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Text(expense.date, formatter: formatter)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("-$\(expense.cost, specifier: "%.2f")")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.red)
        }
        .padding(.vertical, 4)
    }
}

struct IncomeRow: View {
    let income: Income
    
    let formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        return df
    }()
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: income.type.icon)
                        .foregroundColor(.green)
                    
                    Text(income.source)
                        .font(.headline)
                        .fontWeight(.medium)
                }
                
                Text(income.type.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !income.note.isEmpty {
                    Text(income.note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Text(income.date, formatter: formatter)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("+$\(income.amount, specifier: "%.2f")")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.green)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HistoryView()
        .environmentObject(ExpenseViewModel())
}
