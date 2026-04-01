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

    @State private var showAddSingleForm = false
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
            .navigationSplitViewColumnWidth(min: 180, ideal: 240)
            .toolbar {
                ToolbarItemGroup {
                    Button("Add") {
                        openWindow(id: "modeless-add-person")
                    }

                    Button("Add Single") {
                        showAddSingleForm = true
                    }
                }
            }
            .sheet(isPresented: $showAddSingleForm) {
                PersonFormView(mode: .singleAdd)
            }
            .sheet(item: $editingPerson) { person in
                PersonFormView(mode: .edit(person))
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

enum PersonFormMode {
    case singleAdd
    case modelessAdd
    case edit(Person)
}

struct PersonFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let mode: PersonFormMode

    @State private var firstName: String
    @State private var lastName: String
    @State private var birthDate: Date
    @State private var city: String

    init(mode: PersonFormMode) {
        self.mode = mode

        let editingPerson: Person?
        if case .edit(let person) = mode {
            editingPerson = person
        } else {
            editingPerson = nil
        }

        _firstName = State(initialValue: editingPerson?.first_name ?? "")
        _lastName = State(initialValue: editingPerson?.last_name ?? "")
        _birthDate = State(
            initialValue: editingPerson?.birth_date
            ?? Calendar.current.date(byAdding: .year, value: -20, to: Date())
            ?? Date()
        )
        _city = State(initialValue: editingPerson?.city ?? "")
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private var isModeless: Bool {
        if case .modelessAdd = mode { return true }
        return false
    }

    var body: some View {
        Group {
            if isModeless {
                modelessBody
            } else {
                modalBody
            }
        }
    }

    private var modalBody: some View {
        NavigationStack {
            Form {
                fields
            }
            .padding()
            .navigationTitle(isEditing ? "Edit Person" : "Add Single Person")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveAndClose()
                    }
                    .disabled(isFormInvalid)
                }
            }
        }
    }

    private var modelessBody: some View {
        VStack(alignment: .leading, spacing: 12) {
            fields

            HStack {
                Button("Close") {
                    dismiss()
                }

                Spacer()

                Button("Add") {
                    saveAndKeepOpen()
                }
                .disabled(isFormInvalid)
            }
        }
        .padding(16)
        .frame(minWidth: 360, minHeight: 220)
    }

    @ViewBuilder
    private var fields: some View {
        TextField("First Name", text: $firstName)
        TextField("Last Name", text: $lastName)
        DatePicker("Year of Birth", selection: $birthDate, displayedComponents: .date)
        TextField("City", text: $city)
    }

    private var isFormInvalid: Bool {
        firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func saveAndClose() {
        savePerson()
        dismiss()
    }

    private func saveAndKeepOpen() {
        savePerson()
        resetForm()
    }

    private func savePerson() {
        if case .edit(let person) = mode {
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
