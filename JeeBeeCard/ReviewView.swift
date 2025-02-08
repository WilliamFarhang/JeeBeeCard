//
//  ReviewView.swift
//  JeeBeeCard
//
//  Created by william farhang on 2025-02-08.
//

import SwiftUI

struct ReviewView: View {
    @State private var markedWords: [String] = UserDefaults.standard.object(forKey: "markedWords") as? [String] ?? []

    var body: some View {
        VStack {
            Text("Marked Words")
                .font(.largeTitle)
                .bold()
                .padding()

            List {
                ForEach(markedWords, id: \.self) { word in
                    HStack {
                        Text(word)
                        Spacer()
                        Button("⭐ Unmark") {
                            markedWords.removeAll { $0 == word }
                            UserDefaults.standard.set(markedWords, forKey: "markedWords")
                        }
                    }
                }
            }
        }
        .navigationTitle("Review")
        .onAppear {
            markedWords = UserDefaults.standard.object(forKey: "markedWords") as? [String] ?? []
        }
    }
}
