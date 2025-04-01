//
//  LoginView.swift
//  PokerCircles
//
//  Created by Vishnu on 3/31/25.
//

// LoginView.swift

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showingSignUp = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    SecureField("Password", text: $password)
                }
                
                Button(action: {
                    authViewModel.signIn(email: email, password: password)
                }) {
                    Text("Sign In")
                }
                .disabled(email.isEmpty || password.isEmpty)
                
                Button(action: {
                    showingSignUp = true
                }) {
                    Text("Don't have an account? Sign Up")
                }
            }
            .navigationTitle("Poker Banker")
            .sheet(isPresented: $showingSignUp) {
                SignUpView()
            }
        }
    }
}

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var role: UserRole = .player
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    SecureField("Password", text: $password)
                    
                    Picker("Role", selection: $role) {
                        ForEach(UserRole.allCases, id: \.self) { role in
                            Text(role.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Button(action: {
                    authViewModel.signUp(
                        email: email,
                        password: password,
                        name: name,
                        role: role
                    )
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Sign Up")
                }
                .disabled(email.isEmpty || password.isEmpty || name.isEmpty)
            }
            .navigationTitle("Sign Up")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    if let user = authViewModel.currentUser {
                        Text(user.name)
                        Text(user.email)
                        Text(user.role.rawValue)
                    }
                }
                
                Section {
                    Button(action: {
                        authViewModel.signOut()
                    }) {
                        Text("Sign Out")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}
