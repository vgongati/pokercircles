//
//  GameManagementView.swift
//  PokerCircles
//
//  Created by Vishnu on 3/31/25.
//

// GameManagementView.swift
import SwiftUI
//import FirebaseFirestoreSwift

struct GameManagementView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingCreateGame = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Active Games")) {
                    if gameViewModel.games.isEmpty {
                        Text("No active games")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(gameViewModel.games.filter { $0.isActive }) { game in
                            NavigationLink(destination: GameDetailsView(game: game)) {
                                GameCard(game: game)
                            }
                        }
                        .onDelete(perform: deleteGames)
                    }
                }
                
                Section(header: Text("Past Games")) {
                    if gameViewModel.games.filter({ !$0.isActive }).isEmpty {
                        Text("No past games")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(gameViewModel.games.filter { !$0.isActive }) { game in
                            GameCard(game: game)
                        }
                    }
                }
            }
            .navigationTitle("Manage Games")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingCreateGame = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateGame) {
                CreateGameView()
            }
            .onAppear {
                gameViewModel.fetchGames()
            }
        }
    }
    
    private func deleteGames(at offsets: IndexSet) {
        offsets.forEach { index in
            let game = gameViewModel.games[index]
            gameViewModel.deleteGame(gameId: game.id)
        }
    }
}

