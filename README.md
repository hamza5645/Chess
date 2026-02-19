# Chess

A native chess game for iOS/macOS built entirely in SwiftUI. The complete game — board rendering, piece movement, rule enforcement, and a basic AI opponent — is implemented in a single-file architecture.

## Overview

Chess supports both local (pass-and-play) and player-vs-AI game modes. The player controls the white pieces and the AI controls the black pieces. The board is rendered as an interactive 8x8 grid with custom piece images and a switchable color theme.

## Chess Rules Implemented

### Piece Movement

All six standard piece types with correct movement logic:

- **Pawn** — Single-step forward; double-step from starting rank; diagonal captures.
- **Rook** — Slides along ranks or files; blocked by intervening pieces.
- **Knight** — L-shaped movement; jumps over pieces.
- **Bishop** — Slides diagonally; blocked by intervening pieces.
- **Queen** — Combines rook and bishop movement.
- **King** — Moves one square in any direction.

### Other Rules

- **Check** — Detected after every move. Players cannot make moves that leave their own king in check.
- **Checkmate** — Exhaustively tests every legal move. If no move resolves check, the game ends.
- **Pawn Promotion** — When a pawn reaches the opposite end, a selection overlay appears (queen, rook, bishop, or knight).
- **Last Move Highlight** — Origin and destination squares are highlighted in yellow.

### Not Implemented

Castling, en passant, stalemate detection, draw conditions (fifty-move rule, threefold repetition), and move timers are not present.

## AI Opponent

The AI controls the black pieces. Its strategy:

1. Enumerate all legal moves for black.
2. Discard any move that leaves the black king in check.
3. Select a random legal move.

Runs on a background thread and dispatches back to main. No evaluation function or search depth — purely random among legal moves.

## SwiftUI Patterns

- **`ChessGame`** — `ObservableObject` class as the single source of truth. Publishes `board` (8x8 2D array), `currentPlayer`, `selectedPiece`, `isCheck`, `isCheckmate`, `gameOver`, `gameMode`, `lastMove`, and `promotionPosition`.
- **`ContentView`** — Top-level view with board grid, turn indicator, reset button, theme toggle, and game mode picker.
- **`BoardSquare`** — Stateless view for a single square (background, highlights, piece image, valid-move dots).
- **`PawnPromotionView`** — Overlay for piece selection during promotion.
- **Two board themes** — Green (default) and Blue, toggled via a `Toggle` control.

## Requirements

- Xcode 15+
- iOS 17+ / macOS 14+
- No third-party dependencies

## How to Run

```bash
git clone https://github.com/hamza5645/Chess.git
```

Open `Chess.xcodeproj` in Xcode. Select a simulator or device. Press Cmd+R.
