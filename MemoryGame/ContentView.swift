//
//  ContentView.swift
//  MemoryGame
//
//  Created by 高信哲 on 2025/06/17.
//

import SwiftUI

struct Card: Identifiable {
    let id = UUID()
    let emoji: String
    var isFaceUp = false
    var isMatched = false
}

class GameViewModel: ObservableObject {
    @Published var cards: [Card] = []
    private var indexOfFirstFlipped: Int?

    let emojis = ["🐶", "🐱", "🐰", "🦊", "🐸", "🐻"]

    init() {
        resetGame()
    }

    func resetGame() {
        let chosenEmojis = emojis.shuffled().prefix(6)
        let pairs = chosenEmojis + chosenEmojis
        cards = pairs.shuffled().map { Card(emoji: $0) }
        indexOfFirstFlipped = nil
    }

    func flipCard(_ card: Card) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }),
              !cards[index].isFaceUp,
              !cards[index].isMatched else { return }

        cards[index].isFaceUp = true

        if let firstIndex = indexOfFirstFlipped {
            // Second card flipped
            if cards[firstIndex].emoji == cards[index].emoji {
                // Match!
                cards[firstIndex].isMatched = true
                cards[index].isMatched = true
            } else {
                // Mismatch - flip back after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.cards[firstIndex].isFaceUp = false
                    self.cards[index].isFaceUp = false
                }
            }
            indexOfFirstFlipped = nil
        } else {
            // First card flipped
            indexOfFirstFlipped = index
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()
    let columns = [GridItem(.adaptive(minimum: 70))]

    var body: some View {
        VStack {
            Text("Flip Card Matching 🃏")
                .font(.title)
                .padding()

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(viewModel.cards) { card in
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(card.isFaceUp || card.isMatched ? Color.white : Color.blue)
                            .frame(height: 80)
                            .shadow(radius: 3)

                        if card.isFaceUp || card.isMatched {
                            Text(card.emoji)
                                .font(.largeTitle)
                        }
                    }
                    .onTapGesture {
                        viewModel.flipCard(card)
                    }
                    .animation(.default, value: card.isFaceUp)
                }
            }

            Button("restart") {
                viewModel.resetGame()
            }
            .padding(.top, 20)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
