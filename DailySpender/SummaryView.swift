import SwiftUI

// ✅ This should be named SummaryItem
struct SummaryItem: Identifiable {
    let id = UUID()
    let category: String
    let total: Double
    let percentage: Double
}

struct SummaryView: View {
    @EnvironmentObject var viewModel: ExpenseViewModel
    @State private var selectedDate = Date()
    @State private var summaries: [SummaryItem] = []

    var body: some View {
        VStack {
            DatePicker("Select Month", selection: $selectedDate, displayedComponents: [.date])
                .datePickerStyle(.compact)
                .padding()

            Button("Generate Summary") {
                loadSummary()
            }

            List(summaries) { item in
                VStack(alignment: .leading) {
                    Text(item.category).font(.headline) // ✅ typo fix
                    Text("Spent: $\(item.total, specifier: "%.2f")")
                    Text("Percentage: \(item.percentage, specifier: "%.1f")%")
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationTitle("Monthly Summary")
    }

    func loadSummary() {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: selectedDate)
        let year = calendar.component(.year, from: selectedDate)
        
        let monthlyExpenses = viewModel.expenses(forMonth: month, year: year) // ✅ fixed typo

        let total = monthlyExpenses.reduce(0) { $0 + $1.cost }
        let grouped = Dictionary(grouping: monthlyExpenses, by: { $0.category })
        summaries = grouped.map { category, items in
            let sum = items.reduce(0) { $0 + $1.cost }
            return SummaryItem(category: category, total: sum, percentage: total > 0 ? (sum / total * 100) : 0)
        }.sorted { $0.total > $1.total }
    }
}
