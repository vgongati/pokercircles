//
//  AuthViewModel.swift
//  PokerCircles
//
//  Created by Vishnu on 3/31/25.
//

// AuthViewModel.swift
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var userRole: UserRole = .player
    
    private let db = Firestore.firestore()
    
    init() {
        self.userSession = Auth.auth().currentUser
        fetchUser()
    }
    
    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Sign in failed: \(error.localizedDescription)")
                return
            }
            
            self.userSession = result?.user
            self.fetchUser()
        }
    }
    
    func signUp(email: String, password: String, name: String, role: UserRole) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Sign up failed: \(error.localizedDescription)")
                return
            }
            
            guard let user = result?.user else { return }
            self.userSession = user
            
            let userData = [
                "id": user.uid,
                "email": email,
                "name": name,
                "role": role.rawValue
            ]
            
            self.db.collection("users").document(user.uid).setData(userData) { error in
                if let error = error {
                    print("Failed to save user: \(error.localizedDescription)")
                    return
                }
                
                self.fetchUser()
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print("Sign out failed: \(error.localizedDescription)")
        }
    }
    
    func fetchUser() {
        guard let uid = userSession?.uid else { return }
        
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("Failed to fetch user: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data() else { return }
            self.currentUser = User(
                id: data["id"] as? String ?? "",
                email: data["email"] as? String ?? "",
                name: data["name"] as? String ?? "",
                role: UserRole(rawValue: data["role"] as? String ?? "") ?? .player
            )
            
            self.userRole = self.currentUser?.role ?? .player
        }
    }
}

struct User {
    let id: String
    let email: String
    let name: String
    let role: UserRole
}

enum UserRole: String, CaseIterable {
    case banker = "Banker"
    case player = "Player"
}
