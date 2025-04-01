//
//  ContentView.swift
//  PokerCircles
//
//  Created by Vishnu on 3/30/25.
//

// ContentView.swift
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if authViewModel.userSession == nil {
                LoginView()
            } else {
                MainTabView()
            }
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var gameViewModel = GameViewModel()
    
    var body: some View {
        TabView {
            if authViewModel.userRole == .banker {
                BankerDashboardView()
                    .environmentObject(gameViewModel)
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Dashboard")
                    }
                
                GameManagementView()
                    .environmentObject(gameViewModel)
                    .tabItem {
                        Image(systemName: "gamecontroller.fill")
                        Text("Manage Games")
                    }
            }
            
            PlayerGamesView()
                .environmentObject(gameViewModel)
                .tabItem {
                    Image(systemName: "dollarsign.circle.fill")
                    Text("My Games")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
    }
}
