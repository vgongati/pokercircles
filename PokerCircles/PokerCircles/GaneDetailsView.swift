//
//  GaneDetailsView.swift
//  PokerCircles
//
//  Created by Vishnu on 3/31/25.
//
// GameDetailsView.swift

import SwiftUI
//import FirebaseFirestoreSwift

struct GameDetailsView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    let game: Game
    
    @State private var showingSettlement = false
    @State private var showingAddPlayer = false
    @State private var newPlayerEmail = ""
    
    var body: some View {
        List {
            Section(header: Text("Game Info")) {
                HStack {
                    Text("Title")
                    Spacer()
                    Text(game.title)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Date")
                    Spacer()
                    Text(game.date.formatted(date: .abbreviated, time: .shortened))
                        .foregroundColor(.secondary)
                }
                
                if !game.location.isEmpty {
                    HStack {
                        Text("Location")
                        Spacer()
                        Text(game.location)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Text("Chip Ratio")
                    Spacer()
                    Text("1 chip = \(game.chipRatio, specifier: "%.1f")$")
                        .foregroundColor(.secondary)
                }
            }
            
            Section(header: Text("Players")) {
                ForEach(game.players, id: \.self) { playerId in
                    Text(playerId) // In a real app, you'd fetch player names here
                }
                
                if authViewModel.userRole == .banker {
                    Button(action: { showingAddPlayer = true }) {
                        Label("Add Player", systemImage: "plus")
                    }
                }
            }
            
            if authViewModel.userRole == .banker {
                Section {
                    Button(role: .destructive, action: {
                        gameViewModel.endGame(gameId: game.id)
                    }) {
                        Label("End Game", systemImage: "flag.fill")
                    }
                    
                    Button(action: { showingSettlement = true }) {
                        Label("View Settlement", systemImage: "dollarsign.circle.fill")
                    }
                }
            }
        }
        .navigationTitle("Game Details")
        .sheet(isPresented: $showingSettlement) {
            if let settlements = gameViewModel.calculateSettlement(gameId: game.id) as? [Settlement] {
                SettlementView(settlements: settlements)
            }
        }
        .sheet(isPresented: $showingAddPlayer) {
            NavigationView {
                Form {
                    TextField("Player Email", text: $newPlayerEmail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    Button("Add Player") {
                        // In a real app, you'd look up the user by email and add their ID
                        // For now, we'll just add the email as a placeholder
                        gameViewModel.addPlayer(to: game.id, playerId: newPlayerEmail)
                        showingAddPlayer = false
                        newPlayerEmail = ""
                    }
                    .disabled(newPlayerEmail.isEmpty)
                }
                .navigationTitle("Add Player")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showingAddPlayer = false
                        }
                    }
                }
            }
        }
    }
}

