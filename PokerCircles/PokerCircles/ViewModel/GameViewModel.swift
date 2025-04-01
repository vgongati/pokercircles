//
//  GameViewModel.swift
//  PokerCircles
//
//  Created by Vishnu on 3/31/25.
//

// GameViewModel.swift
import FirebaseFirestore
import FirebaseAuth

class GameViewModel: ObservableObject {
    @Published var games: [Game] = []
    @Published var activeGame: Game?
    @Published var buyInRequests: [BuyInRequest] = []
    @Published var cashOutRequests: [CashOutRequest] = []
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    func createGame(title: String, date: Date, location: String?, chipRatio: Double) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let game = Game(
            id: UUID().uuidString,
            title: title,
            date: date,
            location: location ?? "",
            bankerId: userId,
            chipRatio: chipRatio,
            isActive: true,
            players: []
        )
        
        do {
            try db.collection("games").document(game.id).setData(from: game)
            self.activeGame = game
        } catch {
            print("Error creating game: \(error.localizedDescription)")
        }
    }
    
    func fetchGames() {
        db.collection("games")
            .whereField("isActive", isEqualTo: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("No games found")
                    return
                }
                
                self.games = documents.compactMap { document in
                    try? document.data(as: Game.self)
                }
            }
    }
    
    func joinGame(gameId: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("games").document(gameId).updateData([
            "players": FieldValue.arrayUnion([userId])
        ])
    }
    
    func endGame(gameId: String) {
        db.collection("games").document(gameId).updateData([
            "isActive": false
        ])
    }
    
    func requestBuyIn(gameId: String, amount: Double) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let request = BuyInRequest(
            id: UUID().uuidString,
            gameId: gameId,
            playerId: userId,
            amount: amount,
            status: .pending,
            timestamp: Date()
        )
        
        do {
            try db.collection("buyInRequests").document(request.id).setData(from: request)
        } catch {
            print("Error creating buy-in request: \(error.localizedDescription)")
        }
    }
    
    func fetchBuyInRequests(gameId: String) {
        db.collection("buyInRequests")
            .whereField("gameId", isEqualTo: gameId)
            .whereField("status", isEqualTo: "pending")
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                self.buyInRequests = documents.compactMap { document in
                    try? document.data(as: BuyInRequest.self)
                }
            }
    }
    
    func updateBuyInRequest(requestId: String, status: RequestStatus) {
        db.collection("buyInRequests").document(requestId).updateData([
            "status": status.rawValue
        ])
    }
    
    func requestCashOut(gameId: String, amount: Double) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let request = CashOutRequest(
            id: UUID().uuidString,
            gameId: gameId,
            playerId: userId,
            amount: amount,
            status: .pending,
            timestamp: Date()
        )
        
        do {
            try db.collection("cashOutRequests").document(request.id).setData(from: request)
        } catch {
            print("Error creating cash-out request: \(error.localizedDescription)")
        }
    }
    
    func fetchCashOutRequests(gameId: String) {
        db.collection("cashOutRequests")
            .whereField("gameId", isEqualTo: gameId)
            .whereField("status", isEqualTo: "pending")
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                self.cashOutRequests = documents.compactMap { document in
                    try? document.data(as: CashOutRequest.self)
                }
            }
    }
    
    func updateCashOutRequest(requestId: String, status: RequestStatus, adjustedAmount: Double? = nil) {
        var data: [String: Any] = ["status": status.rawValue]
        
        if let adjustedAmount = adjustedAmount {
            data["adjustedAmount"] = adjustedAmount
        }
        
        db.collection("cashOutRequests").document(requestId).updateData(data)
    }
    
    func calculateSettlement(gameId: String) -> [Settlement] {
        // This is a simplified version - you'll want to implement proper settlement calculation
        // based on your actual buy-in and cash-out records
        
        var settlements: [Settlement] = []
        
        // In a real implementation, you would:
        // 1. Fetch all buy-in requests for this game
        // 2. Fetch all cash-out requests for this game
        // 3. Calculate net profit/loss for each player
        // 4. Return the Settlement array
        
        return settlements
    }
}

// Add this extension to GameViewModel for delete functionality
extension GameViewModel {
    func deleteGame(gameId: String) {
        db.collection("games").document(gameId).delete { error in
            if let error = error {
                print("Error deleting game: \(error.localizedDescription)")
            }
        }
    }
}

// Add this extension to GameViewModel for the missing functionality
extension GameViewModel {
    func addPlayer(to gameId: String, playerId: String) {
        db.collection("games").document(gameId).updateData([
            "players": FieldValue.arrayUnion([playerId])
        ])
    }
}

struct Game: Identifiable, Codable {
    var id: String
    var title: String
    var date: Date
    var location: String
    var bankerId: String
    var chipRatio: Double
    var isActive: Bool
    var players: [String]
}

struct BuyInRequest: Identifiable, Codable {
    var id: String
    var gameId: String
    var playerId: String
    var amount: Double
    var status: RequestStatus
    var timestamp: Date
}

struct CashOutRequest: Identifiable, Codable {
    var id: String
    var gameId: String
    var playerId: String
    var amount: Double
    var adjustedAmount: Double?
    var status: RequestStatus
    var timestamp: Date
}

enum RequestStatus: String, Codable {
    case pending = "pending"
    case approved = "approved"
    case rejected = "rejected"
}

struct Settlement: Identifiable {
    var id: String
    var playerId: String
    var playerName: String
    var totalBuyIn: Double
    var totalCashOut: Double
    var netProfitLoss: Double
}
