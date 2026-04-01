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
    @Environment(\.openWindow) private var openWindow
    @Query private var persons: [Person]

    @State private var editingPerson: Person?

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(persons) { person in
                    NavigationLink {
                        PersonDetailView(
                            person: person,
                            onEdit: {
                                editingPerson = person
                            }
                        )
                    } label: {
                        PersonRowView(person: person)
                    }
                }
                .onDelete(perform: deletePersons)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .toolbar {
                ToolbarItem {
                    Button {
                        openWindow(id: "add-person")
                    } label: {
                        Label("Add Person", systemImage: "plus")
                    }
                }
            }
            .sheet(item: $editingPerson) { person in
                PersonFormView(person: person)
            }
        } detail: {
            Text("Select a person")
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
    let onEdit: () -> Void

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
        .toolbar {
            ToolbarItem {
                Button("Edit") {
                    onEdit()
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Person.self, inMemory: true)
}
