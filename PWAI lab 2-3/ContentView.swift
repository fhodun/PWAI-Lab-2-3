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
                    Button(action: { showAddPersonForm = true }) {
                        Label("Add Person", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddPersonForm) {
                PersonFormView(person: nil)
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

private struct PersonFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let person: Person?
    
    @State private var firstName: String
    @State private var lastName: String
    @State private var birthDate: Date
    @State private var city: String
    
    init(person: Person?) {
        self.person = person
        
        _firstName = State(initialValue: person?.first_name ?? "")
        _lastName = State(initialValue: person?.last_name ?? "")
        _birthDate = State(
            initialValue: person?.birth_date
            ?? Calendar.current.date(byAdding: .year, value: -20, to: Date())
            ?? Date()
        )
        _city = State(initialValue: person?.city ?? "")
    }
    
    private var isEditing: Bool {
        person != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("First Name", text: $firstName)
                TextField("Last Name", text: $lastName)
                DatePicker("Birth Date", selection: $birthDate, displayedComponents: .date)
                TextField("City", text: $city)
            }
            .padding()
            .navigationTitle(isEditing ? "Edit Person" : "Add Person")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePersonAndClose()
                    }
                    .disabled(isFormInvalid)
                }
                
                if !isEditing {
                    ToolbarItem {
                        Button("Save modeless") {
                            savePersonAndKeepOpen()
                        }
                        .disabled(isFormInvalid)
                    }
                }
            }
        }
    }
    
    private var isFormInvalid: Bool {
        firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func savePersonAndClose() {
        savePerson()
        dismiss()
    }
    
    private func savePersonAndKeepOpen() {
        savePerson()
        resetForm()
    }
    
    private func savePerson() {
        if let person {
            person.first_name = firstName
            person.last_name = lastName
            person.birth_date = birthDate
            person.city = city
        } else {
            let newPerson = Person(
                first_name: firstName,
                last_name: lastName,
                birth_date: birthDate,
                city: city,
                timestamp: Date()
            )
            modelContext.insert(newPerson)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save person: \(error)")
        }
    }
    
    private func resetForm() {
        firstName = ""
        lastName = ""
        birthDate = Calendar.current.date(byAdding: .year, value: -20, to: Date()) ?? Date()
        city = ""
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Person.self, inMemory: true)
}
