//
//  ChartView.swift
//  DailySpender
//
//  Created by Khang Lam on 7/29/25.
//

import SwiftUI

struct ChartView: View {
    let data: [(String, Double, String)]
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            if data.isEmpty {
                Text("No data available")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                // Pie Chart
                PieChartView(data: data)
                    .frame(height: 200)
                
                // Legend
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(data, id: \.0) { item in
                        HStack {
                            Circle()
                                .fill(Color(item.2))
                                .frame(width: 12, height: 12)
                            
                            Text(item.0)
                                .font(.caption)
                            
                            Spacer()
                            
                            Text("$\(item.1, specifier: "%.2f")")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct PieChartView: View {
    let data: [(String, Double, String)]
    
    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = min(geometry.size.width, geometry.size.height) / 2 - 20
            
            ZStack {
                ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                    let startAngle = startAngle(for: index)
                    let endAngle = endAngle(for: index)
                    
                    Path { path in
                        path.move(to: center)
                        path.addArc(
                            center: center,
                            radius: radius,
                            startAngle: startAngle,
                            endAngle: endAngle,
                            clockwise: false
                        )
                        path.closeSubpath()
                    }
                    .fill(Color(item.2))
                    .overlay(
                        Path { path in
                            path.move(to: center)
                            path.addArc(
                                center: center,
                                radius: radius,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: false
                            )
                            path.closeSubpath()
                        }
                        .stroke(Color.white, lineWidth: 2)
                    )
                }
            }
        }
    }
    
    private func startAngle(for index: Int) -> Angle {
        let total = data.reduce(0) { $0 + $1.1 }
        var currentAngle: Double = -90 // Start from top
        
        for i in 0..<index {
            currentAngle += (data[i].1 / total) * 360
        }
        
        return Angle(degrees: currentAngle)
    }
    
    private func endAngle(for index: Int) -> Angle {
        let total = data.reduce(0) { $0 + $1.1 }
        var currentAngle: Double = -90 // Start from top
        
        for i in 0...index {
            currentAngle += (data[i].1 / total) * 360
        }
        
        return Angle(degrees: currentAngle)
    }
}

struct BarChartView: View {
    let data: [(String, Double, Double)] // (month, expenses, income)
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            if data.isEmpty {
                Text("No data available")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .bottom, spacing: 12) {
                        ForEach(data, id: \.0) { item in
                            VStack(spacing: 8) {
                                VStack(spacing: 4) {
                                    // Income bar
                                    Rectangle()
                                        .fill(Color.green)
                                        .frame(width: 20, height: max(4, CGFloat(item.2) / maxValue * 100))
                                    
                                    // Expense bar
                                    Rectangle()
                                        .fill(Color.red)
                                        .frame(width: 20, height: max(4, CGFloat(item.1) / maxValue * 100))
                                }
                                
                                Text(item.0)
                                    .font(.caption2)
                                    .rotationEffect(.degrees(-45))
                                    .frame(width: 30)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Legend
                HStack(spacing: 20) {
                    HStack(spacing: 4) {
                        Rectangle()
                            .fill(Color.green)
                            .frame(width: 12, height: 12)
                        Text("Income")
                            .font(.caption)
                    }
                    
                    HStack(spacing: 4) {
                        Rectangle()
                            .fill(Color.red)
                            .frame(width: 12, height: 12)
                        Text("Expenses")
                            .font(.caption)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var maxValue: Double {
        let maxExpense = data.map { $0.1 }.max() ?? 0
        let maxIncome = data.map { $0.2 }.max() ?? 0
        return max(maxExpense, maxIncome)
    }
}

#Preview {
    VStack {
        ChartView(
            data: [
                ("Food", 300.0, "green"),
                ("Gas", 150.0, "orange"),
                ("Entertainment", 200.0, "blue"),
                ("Shopping", 100.0, "purple")
            ],
            title: "Monthly Expenses"
        )
        
        BarChartView(
            data: [
                ("Jan", 1200.0, 1500.0),
                ("Feb", 1100.0, 1600.0),
                ("Mar", 1300.0, 1400.0),
                ("Apr", 1000.0, 1700.0)
            ],
            title: "Monthly Trends"
        )
    }
    .padding()
}
