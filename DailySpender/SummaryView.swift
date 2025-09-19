import SwiftUI

struct SummaryView: View {
    @EnvironmentObject var viewModel: ExpenseViewModel
    @State private var selectedDate = Date()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Date Picker
                    VStack {
                        Text("Select Month")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                            .datePickerStyle(.compact)
                            .labelsHidden()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Monthly Summary Card
                    MonthlySummaryCard(selectedDate: selectedDate)
                    
                    // Charts
                    let chartData = viewModel.getChartData(forMonth: calendar.component(.month, from: selectedDate), year: calendar.component(.year, from: selectedDate))
                    
                    if !chartData.isEmpty {
                        ChartView(data: chartData, title: "Expense Breakdown")
                    }
                    
                    // Trend Chart
                    let trendData = viewModel.getMonthlyTrendData()
                    if !trendData.isEmpty {
                        BarChartView(data: trendData, title: "6-Month Trend")
                    }
                }
                .padding()
            }
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var calendar: Calendar {
        Calendar.current
    }
}

struct MonthlySummaryCard: View {
    let selectedDate: Date
    @EnvironmentObject var viewModel: ExpenseViewModel
    
    var body: some View {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: selectedDate)
        let year = calendar.component(.year, from: selectedDate)
        let summary = viewModel.getMonthlySummary(month: month, year: year)
        
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text("Monthly Summary")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(monthName(month: month) + " \(year)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            // Summary Stats
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Income")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(summary.totalIncome, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: 4) {
                    Text("Total Expenses")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(summary.totalExpenses, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Net Income")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(summary.netIncome, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(summary.netIncome >= 0 ? .green : .red)
                }
            }
            
            // Category Breakdown
            if !summary.categoryBreakdown.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Top Categories")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    ForEach(Array(summary.categoryBreakdown.sorted { $0.value > $1.value }.prefix(3)), id: \.key) { category, amount in
                        HStack {
                            Image(systemName: category.icon)
                                .foregroundColor(Color(category.color))
                                .frame(width: 20)
                            
                            Text(category.rawValue)
                                .font(.caption)
                            
                            Spacer()
                            
                            Text("$\(amount, specifier: "%.2f")")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private func monthName(month: Int) -> String {
        let formatter = DateFormatter()
        return formatter.monthSymbols[month - 1]
    }
}

#Preview {
    SummaryView()
        .environmentObject(ExpenseViewModel())
}
