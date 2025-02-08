//
//  FlashcardView.swift
//  JeeBeeCard
//
//  Created by william farhang on 2025-02-08.
//

import SwiftUI

struct FlashcardView: View {
    let level: String
    @State private var flashcards: [(word: String, meaningEN: String, meaningFA: String)] = []
    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var rotationDegree: Double = 0
    @State private var showEnglish = true
    @State private var markedWords: [String] = []
    @State private var showAddCardAlert = false
    @State private var showDeleteAlert = false
    @State private var newWord = ""
    @State private var newMeaningEN = ""
    @State private var newMeaningFA = ""

    var body: some View {
        VStack {
            Text(level)
                .font(.largeTitle)
                .bold()
                .padding()
                .foregroundColor(.blue)

            Toggle("Show English", isOn: $showEnglish)
                .padding()
                .toggleStyle(SwitchToggleStyle(tint: .blue))

            if flashcards.isEmpty {
                Text("No Flashcards! Add one.").foregroundColor(.gray)
            } else {

                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 350, height: 250)
                        .shadow(radius: 8)
                        .rotation3DEffect(.degrees(rotationDegree), axis: (x: 0, y: 1, z: 0))

                            Spacer()

                    if flashcards.indices.contains(currentIndex) { // ✅ Fix: Ensure index is in range
                        Text(isFlipped ? (showEnglish ? flashcards[currentIndex].meaningEN : flashcards[currentIndex].meaningFA) : flashcards[currentIndex].word)
                            .font(.title)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center) // 🔥 Fix: Text ro vasat negah dar
                            .minimumScaleFactor(0.5) // 🔥 Fix: Vaghti text bozorg shod, koochik beshe
                            .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                            .scaleEffect(x: isFlipped ? -1 : 1)
                    }
                }
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isFlipped.toggle()
                        rotationDegree += 180
                    }
                }
                .padding()
                
            }

            HStack {
                Button("⬅️ Previous") {
                    if currentIndex > 0 {
                        currentIndex -= 1
                        isFlipped = false
                        rotationDegree = 0
                    }
                }
                .disabled(currentIndex == 0 || flashcards.isEmpty)

                if flashcards.indices.contains(currentIndex) { // ✅ Fix: Check index before accessing
                    Button(markedWords.contains(flashcards[currentIndex].word) ? "⭐ Unmark" : "☆ Mark") {
                        if markedWords.contains(flashcards[currentIndex].word) {
                            markedWords.removeAll { $0 == flashcards[currentIndex].word }
                        } else {
                            markedWords.append(flashcards[currentIndex].word)
                        }
                        saveMarkedWords()
                    }
                } else {
                    Text("No Cards to Mark")
                        .foregroundColor(.gray)
                }

                Button("Next ➡️") {
                    if currentIndex < flashcards.count - 1 {
                        currentIndex += 1
                        isFlipped = false
                        rotationDegree = 0
                    }
                }
                .disabled(currentIndex >= flashcards.count - 1 || flashcards.isEmpty)
            }
            .padding()

            HStack {
                Button("➕ Add New Card") {
                    showAddCardAlert.toggle()
                }
                .padding()
                .background(Color.green.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(10)

                Button("🗑 Delete Card") {
                    showDeleteAlert.toggle()
                }
                .foregroundColor(.red)
                .padding()
                .disabled(flashcards.isEmpty)
            }
        }
        .navigationTitle("JeeBeez Card")
        .toolbarTitleDisplayMode(.inline).bold()
        .toolbar {
            NavigationLink(destination: ReviewView()) {
                Text("🔍 Review")
                    .font(.headline)
                    .padding(10)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(10)
            }
        }
        .alert("Add New Card", isPresented: $showAddCardAlert) {
            VStack {
                TextField("Enter Word (Swedish)", text: $newWord)
                TextField("Enter Meaning (English)", text: $newMeaningEN)
                TextField("Enter Meaning (Farsi)", text: $newMeaningFA)
                Button("Cancel", role: .cancel) {}
                Button("Add") {
                    if !newWord.isEmpty && !newMeaningEN.isEmpty && !newMeaningFA.isEmpty {
                        flashcards.append((newWord, newMeaningEN, newMeaningFA))
                        saveFlashcards()
                        newWord = ""
                        newMeaningEN = ""
                        newMeaningFA = ""
                        currentIndex = flashcards.count - 1
                    }
                }
            }
        }
        .alert("Delete This Card?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteCard()
            }
        }
        .onAppear {
            loadFlashcards()
            loadMarkedWords()
        }
    }

    // ✅ Save & Load Functions
    private func saveFlashcards() {
        let savedData = flashcards.map { [$0.word, $0.meaningEN, $0.meaningFA] }
        UserDefaults.standard.set(savedData, forKey: "flashcards")
    }

    private func loadFlashcards() {
        if let savedFlashcards = UserDefaults.standard.object(forKey: "flashcards") as? [[String]] {
            flashcards = savedFlashcards.map { ($0[0], $0[1], $0[2]) }
        }
    }

    private func saveMarkedWords() {
        UserDefaults.standard.set(markedWords, forKey: "markedWords")
    }

    private func loadMarkedWords() {
        markedWords = UserDefaults.standard.object(forKey: "markedWords") as? [String] ?? []
    }

    private func deleteCard() {
        if flashcards.count > 1 {
            flashcards.remove(at: currentIndex)
            saveFlashcards()
            if currentIndex >= flashcards.count {
                currentIndex = flashcards.count - 1
            }
        } else {
            flashcards = []
            saveFlashcards()
            currentIndex = 0
        }
    }
}
