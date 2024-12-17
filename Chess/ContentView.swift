//
//  ContentView.swift
//  Chess
//
//  Created by Hamza Osama on 12/17/24.
//

import SwiftUI

enum PieceType {
    case pawn, rook, knight, bishop, queen, king
}

enum PieceColor {
    case white, black
}

struct ChessPiece: Identifiable {
    let id = UUID()
    let type: PieceType
    let color: PieceColor
    
    var imageName: String {
        let colorPrefix = color == .white ? "white" : "black"
        let typeName: String
        switch type {
        case .pawn: typeName = "pawn"
        case .rook: typeName = "rook"
        case .knight: typeName = "knight"
        case .bishop: typeName = "bishop"
        case .queen: typeName = "queen"
        case .king: typeName = "king"
        }
        return "\(colorPrefix).\(typeName)"
    }
}

class ChessGame: ObservableObject {
    @Published var board: [[ChessPiece?]] = Array(repeating: Array(repeating: nil, count: 8), count: 8)
    @Published var currentPlayer: PieceColor = .white
    @Published var selectedPiece: (row: Int, col: Int)? = nil
    
    init() {
        setupBoard()
    }
    
    private func setupBoard() {
        // Set up pawns
        for col in 0..<8 {
            board[1][col] = ChessPiece(type: .pawn, color: .black)
            board[6][col] = ChessPiece(type: .pawn, color: .white)
        }
        
        // Set up other pieces
        let backRowPieces: [PieceType] = [.rook, .knight, .bishop, .queen, .king, .bishop, .knight, .rook]
        
        for col in 0..<8 {
            board[0][col] = ChessPiece(type: backRowPieces[col], color: .black)
            board[7][col] = ChessPiece(type: backRowPieces[col], color: .white)
        }
    }
    
    func movePiece(from: (row: Int, col: Int), to: (row: Int, col: Int)) {
        guard let piece = board[from.row][from.col] else { return }
        
        board[to.row][to.col] = piece
        board[from.row][from.col] = nil
        currentPlayer = currentPlayer == .white ? .black : .white
        selectedPiece = nil
    }
}

struct BoardSquare: View {
    let row: Int
    let col: Int
    let piece: ChessPiece?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Rectangle()
                    .fill((row + col).isMultiple(of: 2) ? Color.white : Color(white: 0.7))
                    .border(isSelected ? Color.blue : Color.clear, width: 3)
                
                if let piece = piece {
                    Image(systemName: "circle.fill")  // Placeholder for chess pieces
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                        .foregroundColor(piece.color == .white ? .white : .black)
                }
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var game = ChessGame()
    
    var body: some View {
        VStack {
            Text("\(game.currentPlayer == .white ? "White" : "Black")'s Turn")
                .font(.title)
                .padding()
            
            VStack(spacing: 0) {
                ForEach(0..<8) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<8) { col in
                            BoardSquare(
                                row: row,
                                col: col,
                                piece: game.board[row][col],
                                isSelected: game.selectedPiece?.row == row && game.selectedPiece?.col == col
                            ) {
                                handleSquareTap(row: row, col: col)
                            }
                            .frame(width: 40, height: 40)
                        }
                    }
                }
            }
            .border(Color.black, width: 2)
        }
        .padding()
    }
    
    private func handleSquareTap(row: Int, col: Int) {
        if let selectedPiece = game.selectedPiece {
            // Move piece
            game.movePiece(from: selectedPiece, to: (row, col))
        } else if let piece = game.board[row][col], piece.color == game.currentPlayer {
            // Select piece
            game.selectedPiece = (row, col)
        }
    }
}

#Preview {
    ContentView()
}
