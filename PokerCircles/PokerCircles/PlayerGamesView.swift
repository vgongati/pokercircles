//
//  PlayerGamesView.swift
//  PokerCircles
//
//  Created by Vishnu on 3/31/25.
//

import SwiftUI

// PlayerGamesView.swift
struct PlayerGamesView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showBuyInSheet = false
    @State private var buyInAmount = ""
    @State private var showCashOutSheet = false
    @State private var cashOutAmount = ""
    
    var body: some View {
        NavigationView {
            List {
                if let activeGame = gameViewModel.activeGame {
                    Section(header: Text("Current Game")) {
                        GameCard(game: activeGame)
                        
                        Button(action: { showBuyInSheet = true }) {
                            Label("Request Buy-In", systemImage: "plus.circle.fill")
                        }
                        
                        Button(action: { showCashOutSheet = true }) {
                            Label("Request Cash-Out", systemImage: "minus.circle.fill")
                        }
                    }
                }
                
                Section(header: Text("Available Games")) {
                    ForEach(gameViewModel.games.filter { $0.isActive && $0.bankerId != authViewModel.userSession?.uid }) { game in
                        GameCard(game: game)
                            .onTapGesture {
                                gameViewModel.joinGame(gameId: game.id)
                            }
                    }
                }
            }
            .navigationTitle("My Games")
            .sheet(isPresented: $showBuyInSheet) {
                buyInForm
            }
            .sheet(isPresented: $showCashOutSheet) {
                cashOutForm
            }
            .onAppear {
                gameViewModel.fetchGames()
            }
        }
    }
    
    private var buyInForm: some View {
        NavigationView {
            Form {
                Section(header: Text("Buy-In Amount")) {
                    TextField("Amount", text: $buyInAmount)
                        .keyboardType(.decimalPad)
                }
                
                Button("Submit Request") {
                    if let amount = Double(buyInAmount), let gameId = gameViewModel.activeGame?.id {
                        gameViewModel.requestBuyIn(gameId: gameId, amount: amount)
                        showBuyInSheet = false
                        buyInAmount = ""
                    }
                }
                .disabled(buyInAmount.isEmpty || Double(buyInAmount) == nil)
            }
            .navigationTitle("Request Buy-In")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showBuyInSheet = false
                    }
                }
            }
        }
    }
    
    private var cashOutForm: some View {
        NavigationView {
            Form {
                Section(header: Text("Cash-Out Amount")) {
                    TextField("Amount", text: $cashOutAmount)
                        .keyboardType(.decimalPad)
                }
                
                Button("Submit Request") {
                    if let amount = Double(cashOutAmount), let gameId = gameViewModel.activeGame?.id {
                        gameViewModel.requestCashOut(gameId: gameId, amount: amount)
                        showCashOutSheet = false
                        cashOutAmount = ""
                    }
                }
                .disabled(cashOutAmount.isEmpty || Double(cashOutAmount) == nil)
            }
            .navigationTitle("Request Cash-Out")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showCashOutSheet = false
                    }
                }
            }
        }
    }
}

struct GameCard: View {
    let game: Game
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(game.title)
                .font(.headline)
            Text(game.date, style: .date)
            Text(game.date, style: .time)
            if !game.location.isEmpty {
                Text(game.location)
            }
            Text("Chip ratio: 1 = \(game.chipRatio, specifier: "%.1f")$")
        }
    }
}
