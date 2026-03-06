//
//  ContentView.swift
//  PWAI lab 2-3
//
//  Created by Filip Hodun on 03/03/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var persons: [Person]
    
    @State private var showAddPersonForm = false
    @State private var newFirstName = ""
    @State private var newLastName = ""
    @State private var newBirthDate = Calendar.current.date(byAdding: .year, value: -20, to: Date()) ?? Date()
    @State private var newCity = ""

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(persons) { person in
                    NavigationLink {
                        PersonDetailView(person: person)
                    } label: {
                        PersonRowView(person: person)
                    }
                }
                .onDelete(perform: deletePersons)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .toolbar {
                ToolbarItem {
                    Button(action: { showAddPersonForm = true }) {
                        Label("Add Person", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddPersonForm) {
                NavigationStack {
                    VStack{
                        Form {
                            TextField("First Name", text: $newFirstName)
                            TextField("Last Name", text: $newLastName)
                            DatePicker("Birth Date", selection: $newBirthDate, displayedComponents: .date)
                            TextField("City", text: $newCity)
                        }
                    }
                    .padding()
                    .navigationTitle("Add Person")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { showAddPersonForm = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                addPerson()
                                showAddPersonForm = false
                            }
                            .disabled(newFirstName.isEmpty || newLastName.isEmpty || newCity.isEmpty)
                        }
                        ToolbarItem() {
                            Button("Save modeless") {
                                addPerson()
                            }
                            .disabled(newFirstName.isEmpty || newLastName.isEmpty || newCity.isEmpty)
                        }
                    }
                }
            }
        } detail: {
            Text("Select a person")
        }
    }
    
    private func resetForm() {
        newFirstName = ""
        newLastName = ""
        newBirthDate = Calendar.current.date(byAdding: .year, value: -20, to: Date()) ?? Date()
        newCity = ""
    }
    
    private func addPerson() {
        withAnimation {
            let newItem = Person(
                first_name: newFirstName,
                last_name: newLastName,
                birth_date: newBirthDate,
                city: newCity,
                timestamp: Date()
            )
            modelContext.insert(newItem)
            resetForm()
        }
    }

    private func deletePersons(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(persons[index])
            }
        }
    }
}

private struct PersonRowView: View {
    let person: Person
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(person.first_name) \(person.last_name)")
                .font(.headline)
            
            HStack(spacing: 8) {
                Text(person.city)
                    .foregroundStyle(.secondary)
                
                Text("•")
                    .foregroundStyle(.secondary)
                
                Text(person.birth_date.formatted(date: .numeric, time: .omitted))
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline)
        }
        .padding(.vertical, 4)
    }
}

private struct PersonDetailView: View {
    let person: Person

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(person.first_name) \(person.last_name)")
                .font(.largeTitle)
                .bold()

            VStack(alignment: .leading, spacing: 6) {
                Label(person.city, systemImage: "building.2")
                Label(person.birth_date.formatted(date: .long, time: .omitted), systemImage: "calendar")
                Label(person.timestamp.formatted(date: .numeric, time: .standard), systemImage: "clock")
                    .foregroundStyle(.secondary)
            }
            .font(.title3)

            Spacer()
        }
        .padding()
        .navigationTitle("Person")
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Person.self, inMemory: true)
}
