//
//  ProfileView.swift
//  DailySpender
//
//  Created by Khang Lam on 7/29/25.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: ExpenseViewModel
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImage: UIImage?
    @State private var userName = "User"
    @State private var userEmail = "user@example.com"
    @State private var showingImagePicker = false
    @State private var showingEditProfile = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        // Avatar Section
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 120, height: 120)
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                            
                            if let profileImage = profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 4)
                                    )
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.white)
                            }
                            
                            // Edit Button
                            Button(action: {
                                showingImagePicker = true
                            }) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .frame(width: 32, height: 32)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                            }
                            .offset(x: 40, y: 40)
                        }
                        
                        // User Info
                        VStack(spacing: 8) {
                            Text(userName)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text(userEmail)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Button("Edit Profile") {
                                showingEditProfile = true
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Stats Cards
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        StatCard(
                            title: "Total Expenses",
                            value: String(format: "$%.2f", viewModel.expenses.reduce(0) { $0 + $1.cost }),
                            icon: "minus.circle.fill",
                            color: .red
                        )
                        
                        StatCard(
                            title: "Total Income",
                            value: String(format: "$%.2f", viewModel.incomes.reduce(0) { $0 + $1.amount }),
                            icon: "plus.circle.fill",
                            color: .green
                        )
                        
                        StatCard(
                            title: "Net Income",
                            value: String(format: "$%.2f", viewModel.incomes.reduce(0) { $0 + $1.amount } - viewModel.expenses.reduce(0) { $0 + $1.cost }),
                            icon: "chart.line.uptrend.xyaxis",
                            color: .blue
                        )
                        
                        StatCard(
                            title: "Transactions",
                            value: "\(viewModel.expenses.count + viewModel.incomes.count)",
                            icon: "list.bullet",
                            color: .orange
                        )
                    }
                    .padding(.horizontal)
                    
                    // Quick Actions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Quick Actions")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            QuickActionButton(
                                title: "Export Data",
                                subtitle: "Download your financial data",
                                icon: "square.and.arrow.up",
                                color: .blue
                            ) {
                                // Export functionality
                            }
                            
                            QuickActionButton(
                                title: "Backup & Restore",
                                subtitle: "Save or restore your data",
                                icon: "icloud.and.arrow.up",
                                color: .green
                            ) {
                                // Backup functionality
                            }
                            
                            QuickActionButton(
                                title: "Privacy Settings",
                                subtitle: "Manage your data privacy",
                                icon: "lock.shield",
                                color: .purple
                            ) {
                                // Privacy settings
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .photosPicker(isPresented: $showingImagePicker, selection: $selectedPhoto, matching: .images)
            .onChange(of: selectedPhoto) { newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        profileImage = image
                        // Save to UserDefaults
                        if let imageData = image.jpegData(compressionQuality: 0.8) {
                            UserDefaults.standard.set(imageData, forKey: "profileImage")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView(userName: $userName, userEmail: $userEmail)
            }
            .onAppear {
                loadProfileData()
            }
        }
    }
    
    private func loadProfileData() {
        // Load saved profile data
        userName = UserDefaults.standard.string(forKey: "userName") ?? "User"
        userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? "user@example.com"
        
        // Load saved profile image
        if let imageData = UserDefaults.standard.data(forKey: "profileImage"),
           let image = UIImage(data: imageData) {
            profileImage = image
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct QuickActionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EditProfileView: View {
    @Binding var userName: String
    @Binding var userEmail: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $userName)
                    TextField("Email", text: $userEmail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    UserDefaults.standard.set(userName, forKey: "userName")
                    UserDefaults.standard.set(userEmail, forKey: "userEmail")
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(ExpenseViewModel())
}
