//
//  BankerDashBoardView.swift
//  PokerCircles
//
//  Created by Vishnu on 3/31/25.
//

import SwiftUI

// BankerDashboardView.swift
struct BankerDashboardView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @State private var showCreateGame = false
    
    var body: some View {
        NavigationView {
            List {
                if let activeGame = gameViewModel.activeGame {
                    Section(header: Text("Active Game")) {
                        GameCard(game: activeGame)
                        
                        NavigationLink(destination: GameDetailsView(game: activeGame)) {
                            Text("Manage Game")
                        }
                    }
                }
                
                Section(header: Text("Quick Actions")) {
                    Button(action: { showCreateGame = true }) {
                        Label("Create New Game", systemImage: "plus.circle")
                    }
                    
                    if gameViewModel.activeGame != nil {
                        NavigationLink(destination: BuyInRequestsView()) {
                            Label("Pending Buy-Ins", systemImage: "dollarsign.circle")
                        }
                        
                        NavigationLink(destination: CashOutRequestsView()) {
                            Label("Pending Cash-Outs", systemImage: "dollarsign.square")
                        }
                    }
                }
            }
            .navigationTitle("Banker Dashboard")
            .sheet(isPresented: $showCreateGame) {
                CreateGameView()
            }
            .onAppear {
                gameViewModel.fetchGames()
            }
        }
    }
}

struct CreateGameView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var date = Date()
    @State private var location = ""
    @State private var chipRatio = 1.0
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Game Details")) {
                    TextField("Game Title", text: $title)
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    TextField("Location (Optional)", text: $location)
                }
                
                Section(header: Text("Chip Ratio")) {
                    Stepper(value: $chipRatio, in: 0.1...10.0, step: 0.1) {
                        Text("1 chip = \(chipRatio, specifier: "%.1f")$")
                    }
                }
                
                Button("Create Game") {
                    gameViewModel.createGame(
                        title: title,
                        date: date,
                        location: location.isEmpty ? nil : location,
                        chipRatio: chipRatio
                    )
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(title.isEmpty)
            }
            .navigationTitle("New Game")
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

struct BuyInRequestsView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    
    var body: some View {
        List(gameViewModel.buyInRequests) { request in
            BuyInRequestCard(request: request) { status in
                gameViewModel.updateBuyInRequest(requestId: request.id, status: status)
            }
        }
        .navigationTitle("Buy-In Requests")
        .onAppear {
            if let gameId = gameViewModel.activeGame?.id {
                gameViewModel.fetchBuyInRequests(gameId: gameId)
            }
        }
    }
}

struct BuyInRequestCard: View {
    let request: BuyInRequest
    let onDecision: (RequestStatus) -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Player ID: \(request.playerId)")
                Text("Amount: $\(request.amount, specifier: "%.2f")")
                Text(request.timestamp, style: .time)
            }
            
            Spacer()
            
            if request.status == .pending {
                HStack {
                    Button(action: { onDecision(.approved) }) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    
                    Button(action: { onDecision(.rejected) }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
            } else {
                Text(request.status.rawValue.capitalized)
                    .foregroundColor(request.status == .approved ? .green : .red)
            }
        }
        .padding()
    }
}

struct CashOutRequestsView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    
    var body: some View {
        List(gameViewModel.cashOutRequests) { request in
            CashOutRequestCard(request: request) { status, amount in
                gameViewModel.updateCashOutRequest(
                    requestId: request.id,
                    status: status,
                    adjustedAmount: amount
                )
            }
        }
        .navigationTitle("Cash-Out Requests")
        .onAppear {
            if let gameId = gameViewModel.activeGame?.id {
                gameViewModel.fetchCashOutRequests(gameId: gameId)
            }
        }
    }
}

struct CashOutRequestCard: View {
    let request: CashOutRequest
    let onDecision: (RequestStatus, Double?) -> Void
    
    @State private var adjustedAmount: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Player ID: \(request.playerId)")
                    Text("Requested: $\(request.amount, specifier: "%.2f")")
                    if let adjusted = request.adjustedAmount {
                        Text("Adjusted: $\(adjusted, specifier: "%.2f")")
                    }
                    Text(request.timestamp, style: .time)
                }
                
                Spacer()
                
                if request.status == .pending {
                    VStack {
                        Button(action: { onDecision(.approved, nil) }) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                        
                        TextField("Adjust", text: $adjustedAmount)
                            .keyboardType(.decimalPad)
                            .frame(width: 60)
                        
                        Button(action: {
                            if let amount = Double(adjustedAmount) {
                                onDecision(.approved, amount)
                            } else {
                                onDecision(.approved, nil)
                            }
                        }) {
                            Text("Approve Adjusted")
                        }
                        
                        Button(action: { onDecision(.rejected, nil) }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                } else {
                    Text(request.status.rawValue.capitalized)
                        .foregroundColor(request.status == .approved ? .green : .red)
                }
            }
        }
        .padding()
    }
}

struct SettlementView: View {
    let settlements: [Settlement]
    
    var body: some View {
        List(settlements) { settlement in
            HStack {
                VStack(alignment: .leading) {
                    Text(settlement.playerName)
                    Text("Buy-In: $\(settlement.totalBuyIn, specifier: "%.2f")")
                    Text("Cash-Out: $\(settlement.totalCashOut, specifier: "%.2f")")
                }
                
                Spacer()
                
                Text("\(settlement.netProfitLoss >= 0 ? "+" : "")\(settlement.netProfitLoss, specifier: "%.2f")")
                    .foregroundColor(settlement.netProfitLoss >= 0 ? .green : .red)
            }
        }
        .navigationTitle("Game Settlement")
    }
}
