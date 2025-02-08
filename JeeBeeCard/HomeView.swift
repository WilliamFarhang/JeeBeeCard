

import SwiftUI

struct HomeView: View {
    @State private var defaultLevels: [String] = (1...10).map { "Level \($0)" }
    @State private var userLevels: [String] = UserDefaults.standard.object(forKey: "userLevels") as? [String] ?? []
    @State private var showAddLevelAlert = false
    @State private var showDeleteAlert = false
    @State private var newLevelName = ""
    @State private var levelToDelete: String?

    var body: some View {
        NavigationView {
            VStack {
                List {
                    // 🔹 Default Levels (Fixed)
                    Section(header: Text("Default Levels").font(.headline)) {
                        ForEach(defaultLevels, id: \.self) { level in
                            NavigationLink(destination: FlashcardView(level: level)) {
                                Text(level)
                                    .font(.headline)
                                    .padding()
                            }
                            .listRowBackground(Color.blue.opacity(0.1))
                        }
                    }

                    // 🔸 User Levels (Removable)
                    Section(header: Text("Your Levels").font(.headline)) {
                        ForEach(userLevels, id: \.self) { level in
                            HStack {
                                NavigationLink(destination: FlashcardView(level: level)) {
                                    Text(level)
                                        .font(.headline)
                                        .padding()
                                }
                                Spacer()
                                Button("🗑") {
                                    levelToDelete = level
                                    showDeleteAlert.toggle()
                                }
                                .foregroundColor(.red)
                            }
                            .listRowBackground(Color.green.opacity(0.1))
                        }
                    }
                }
                .listStyle(PlainListStyle())

                Button(action: {
                    showAddLevelAlert.toggle()
                }) {
                    Text("➕ Add New Level")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .padding()
                }
                .alert("Add New Level", isPresented: $showAddLevelAlert) {
                    TextField("Level Name", text: $newLevelName)
                    Button("Cancel", role: .cancel) {}
                    Button("Add") {
                        if !newLevelName.isEmpty {
                            userLevels.append(newLevelName)
                            saveUserLevels()
                            newLevelName = ""
                        }
                    }
                }
                .alert("Delete Level?", isPresented: $showDeleteAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Delete", role: .destructive) {
                        if let level = levelToDelete {
                            userLevels.removeAll { $0 == level }
                            saveUserLevels()
                        }
                    }
                }
            }
            .navigationTitle("JeeBeez Card Levels")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                NavigationLink(destination: ReviewView()) {
                    Text("🔍 Review")
                        .font(.headline)
                        .padding(10)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(10)
                }
            }
        }
    }

    // ✅ Save User Levels
    private func saveUserLevels() {
        UserDefaults.standard.set(userLevels, forKey: "userLevels")
    }
}
