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
    
    var opposite: PieceColor {
        self == .white ? .black : .white
    }
}

struct Position: Equatable {
    let row: Int
    let col: Int
    
    var isValid: Bool {
        row >= 0 && row < 8 && col >= 0 && col < 8
    }
}

struct ChessPiece: Identifiable {
    let id = UUID()
    let type: PieceType
    let color: PieceColor
    var hasMoved = false
    
    var imageName: String {
        let colorPrefix = color == .white ? "White" : "Black"
        let typeName: String
        switch type {
        case .pawn: typeName = "Pawn"
        case .rook: typeName = "Rook"
        case .knight: typeName = "Knight"
        case .bishop: typeName = "Bishop"
        case .queen: typeName = "Queen"
        case .king: typeName = "King"
        }
        return "\(colorPrefix)_\(typeName)"
    }
}

class ChessGame: ObservableObject {
    @Published var board: [[ChessPiece?]] = Array(repeating: Array(repeating: nil, count: 8), count: 8)
    @Published var currentPlayer: PieceColor = .white
    @Published var selectedPiece: Position? = nil
    @Published var isCheck: Bool = false
    @Published var isCheckmate: Bool = false
    @Published var gameOver: Bool = false
    
    init() {
        setupBoard()
    }
    
    func resetGame() {
        board = Array(repeating: Array(repeating: nil, count: 8), count: 8)
        currentPlayer = .white
        selectedPiece = nil
        isCheck = false
        isCheckmate = false
        gameOver = false
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
    
    func movePiece(from: Position, to: Position) {
        guard let piece = board[from.row][from.col],
              isValidMove(from: from, to: to) else { return }
        
        // Make the move
        let originalPiece = board[to.row][to.col]
        board[to.row][to.col] = ChessPiece(type: piece.type, color: piece.color, hasMoved: true)
        board[from.row][from.col] = nil
        
        // Check if this move puts the current player in check
        if isKingInCheck(color: currentPlayer) {
            // Undo the move
            board[from.row][from.col] = piece
            board[to.row][to.col] = originalPiece
            return
        }
        
        // Check if opponent is in check or checkmate
        let oppositeColor = currentPlayer.opposite
        isCheck = isKingInCheck(color: oppositeColor)
        
        if isCheck {
            isCheckmate = isKingInCheckmate(color: oppositeColor)
            if isCheckmate {
                gameOver = true
            }
        }
        
        currentPlayer = oppositeColor
        selectedPiece = nil
    }
    
    func isValidMove(from: Position, to: Position) -> Bool {
        guard from.isValid && to.isValid,
              let piece = board[from.row][from.col],
              piece.color == currentPlayer,
              (board[to.row][to.col]?.color != currentPlayer) else { return false }
        
        let validMoves = getValidMoves(for: from)
        return validMoves.contains(to)
    }
    
    func getValidMoves(for position: Position) -> [Position] {
        guard let piece = board[position.row][position.col] else { return [] }
        
        var moves: [Position] = []
        
        switch piece.type {
        case .pawn:
            moves = getPawnMoves(from: position, color: piece.color)
        case .rook:
            moves = getRookMoves(from: position)
        case .knight:
            moves = getKnightMoves(from: position)
        case .bishop:
            moves = getBishopMoves(from: position)
        case .queen:
            moves = getQueenMoves(from: position)
        case .king:
            moves = getKingMoves(from: position)
        }
        
        return moves
    }
    
    private func getPawnMoves(from pos: Position, color: PieceColor) -> [Position] {
        var moves: [Position] = []
        let direction = color == .white ? -1 : 1
        let startRow = color == .white ? 6 : 1
        
        // Forward move
        let oneStep = Position(row: pos.row + direction, col: pos.col)
        if oneStep.isValid && board[oneStep.row][oneStep.col] == nil {
            moves.append(oneStep)
            
            // Two steps forward from starting position
            if pos.row == startRow {
                let twoStep = Position(row: pos.row + 2 * direction, col: pos.col)
                if board[twoStep.row][twoStep.col] == nil {
                    moves.append(twoStep)
                }
            }
        }
        
        // Capture moves
        for captureCol in [pos.col - 1, pos.col + 1] {
            let capturePos = Position(row: pos.row + direction, col: captureCol)
            if capturePos.isValid,
               let targetPiece = board[capturePos.row][capturePos.col],
               targetPiece.color != color {
                moves.append(capturePos)
            }
        }
        
        return moves
    }
    
    private func getRookMoves(from pos: Position) -> [Position] {
        var moves: [Position] = []
        let directions = [(0, 1), (0, -1), (1, 0), (-1, 0)]
        
        for (dRow, dCol) in directions {
            var currentRow = pos.row + dRow
            var currentCol = pos.col + dCol
            
            while (0..<8).contains(currentRow) && (0..<8).contains(currentCol) {
                let currentPos = Position(row: currentRow, col: currentCol)
                
                if let piece = board[currentRow][currentCol] {
                    if piece.color != board[pos.row][pos.col]?.color {
                        moves.append(currentPos)
                    }
                    break
                }
                
                moves.append(currentPos)
                currentRow += dRow
                currentCol += dCol
            }
        }
        
        return moves
    }
    
    private func getKnightMoves(from pos: Position) -> [Position] {
        let possibleMoves = [
            (-2, -1), (-2, 1), (-1, -2), (-1, 2),
            (1, -2), (1, 2), (2, -1), (2, 1)
        ]
        
        return possibleMoves.compactMap { dRow, dCol in
            let newRow = pos.row + dRow
            let newCol = pos.col + dCol
            let newPos = Position(row: newRow, col: newCol)
            
            if newPos.isValid {
                if let piece = board[newRow][newCol] {
                    return piece.color != board[pos.row][pos.col]?.color ? newPos : nil
                }
                return newPos
            }
            return nil
        }
    }
    
    private func getBishopMoves(from pos: Position) -> [Position] {
        var moves: [Position] = []
        let directions = [(1, 1), (1, -1), (-1, 1), (-1, -1)]
        
        for (dRow, dCol) in directions {
            var currentRow = pos.row + dRow
            var currentCol = pos.col + dCol
            
            while (0..<8).contains(currentRow) && (0..<8).contains(currentCol) {
                let currentPos = Position(row: currentRow, col: currentCol)
                
                if let piece = board[currentRow][currentCol] {
                    if piece.color != board[pos.row][pos.col]?.color {
                        moves.append(currentPos)
                    }
                    break
                }
                
                moves.append(currentPos)
                currentRow += dRow
                currentCol += dCol
            }
        }
        
        return moves
    }
    
    private func getQueenMoves(from pos: Position) -> [Position] {
        return getRookMoves(from: pos) + getBishopMoves(from: pos)
    }
    
    private func getKingMoves(from pos: Position) -> [Position] {
        let possibleMoves = [
            (-1, -1), (-1, 0), (-1, 1),
            (0, -1),           (0, 1),
            (1, -1),  (1, 0),  (1, 1)
        ]
        
        return possibleMoves.compactMap { dRow, dCol in
            let newRow = pos.row + dRow
            let newCol = pos.col + dCol
            let newPos = Position(row: newRow, col: newCol)
            
            if newPos.isValid {
                if let piece = board[newRow][newCol] {
                    return piece.color != board[pos.row][pos.col]?.color ? newPos : nil
                }
                return newPos
            }
            return nil
        }
    }
    
    private func isKingInCheck(color: PieceColor) -> Bool {
        // Find the king's position
        guard let kingPos = findKing(color: color) else { return false }
        
        // Check if any opponent's piece can capture the king
        for row in 0..<8 {
            for col in 0..<8 {
                if let piece = board[row][col],
                   piece.color != color {
                    let moves = getValidMoves(for: Position(row: row, col: col))
                    if moves.contains(kingPos) {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    private func findKing(color: PieceColor) -> Position? {
        for row in 0..<8 {
            for col in 0..<8 {
                if let piece = board[row][col],
                   piece.type == .king && piece.color == color {
                    return Position(row: row, col: col)
                }
            }
        }
        return nil
    }
    
    private func isKingInCheckmate(color: PieceColor) -> Bool {
        // If the king is not in check, it's not checkmate
        if !isKingInCheck(color: color) {
            return false
        }
        
        // Try all possible moves for all pieces of the given color
        for row in 0..<8 {
            for col in 0..<8 {
                if let piece = board[row][col], piece.color == color {
                    let from = Position(row: row, col: col)
                    let moves = getValidMoves(for: from)
                    
                    // Try each move
                    for to in moves {
                        // Make the move temporarily
                        let originalPiece = board[to.row][to.col]
                        board[to.row][to.col] = piece
                        board[row][col] = nil
                        
                        // Check if the king is still in check
                        let stillInCheck = isKingInCheck(color: color)
                        
                        // Undo the move
                        board[row][col] = piece
                        board[to.row][to.col] = originalPiece
                        
                        // If we found a move that gets us out of check, it's not checkmate
                        if !stillInCheck {
                            return false
                        }
                    }
                }
            }
        }
        
        // If we haven't found any valid moves to get out of check, it's checkmate
        return true
    }
}

struct BoardSquare: View {
    let row: Int
    let col: Int
    let piece: ChessPiece?
    let isSelected: Bool
    let isValidMove: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Rectangle()
                    .fill((row + col).isMultiple(of: 2) ? Color("BoardGreen") : Color("BoardWhite"))
                    .border(isSelected ? Color.blue : (isValidMove ? Color.green : Color.clear), width: 3)
                
                if let piece = piece {
                    Image(piece.imageName)
                        .resizable()
                        .scaledToFit()
                        .padding(5)
                }
                
                if isValidMove && piece == nil {
                    Circle()
                        .fill(Color.green.opacity(0.3))
                        .padding(15)
                }
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var game = ChessGame()
    
    var body: some View {
        VStack {
            HStack {
                Text("\(game.currentPlayer == .white ? "White" : "Black")'s Turn")
                    .font(.title)
                
                Spacer()
                
                Button(action: {
                    game.resetGame()
                }) {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            
            if game.isCheck {
                Text("Check!")
                    .font(.headline)
                    .foregroundColor(.red)
            }
            
            if game.isCheckmate {
                Text("\(game.currentPlayer.opposite == .white ? "White" : "Black") wins by checkmate!")
                    .font(.headline)
                    .foregroundColor(.green)
            }
            
            VStack(spacing: 0) {
                ForEach(0..<8) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<8) { col in
                            let position = Position(row: row, col: col)
                            let validMoves = game.selectedPiece.map { game.getValidMoves(for: $0) } ?? []
                            
                            BoardSquare(
                                row: row,
                                col: col,
                                piece: game.board[row][col],
                                isSelected: position == game.selectedPiece,
                                isValidMove: validMoves.contains(position)
                            ) {
                                handleSquareTap(row: row, col: col)
                            }
                            .frame(width: 50, height: 50)
                        }
                    }
                }
            }
            .border(Color.black, width: 2)
        }
        .padding()
    }
    
    private func handleSquareTap(row: Int, col: Int) {
        let tappedPosition = Position(row: row, col: col)
        
        if let selectedPos = game.selectedPiece {
            // If we tap a valid move location, make the move
            if game.isValidMove(from: selectedPos, to: tappedPosition) {
                game.movePiece(from: selectedPos, to: tappedPosition)
            } else {
                // If we tap the same piece, deselect it
                if selectedPos == tappedPosition {
                    game.selectedPiece = nil
                } else if let piece = game.board[row][col], piece.color == game.currentPlayer {
                    // If we tap a different piece of the same color, select it instead
                    game.selectedPiece = tappedPosition
                }
            }
        } else if let piece = game.board[row][col], piece.color == game.currentPlayer {
            // Select the piece if it belongs to the current player
            game.selectedPiece = tappedPosition
        }
    }
}

#Preview {
    ContentView()
}
