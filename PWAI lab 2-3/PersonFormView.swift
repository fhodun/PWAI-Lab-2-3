//
//  PersonFormView.swift
//  PWAI lab 2-3
//
//  Created by Filip Hodun on 25/03/2026.
//

import SwiftUI
import SwiftData

struct PersonFormView: View {
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
            .navigationTitle(isEditing ? "Edit Person" : "Add Person")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(isEditing ? "Cancel" : "Close") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePerson()
                        resetForm()
                    }
                    .disabled(isFormInvalid)
                }
            }
        }
        .frame(minWidth: 420, minHeight: 260)
    }

    private var isFormInvalid: Bool {
        firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
        city = ""
        birthDate = Calendar.current.date(byAdding: .year, value: -20, to: Date()) ?? Date()
    }
}

#Preview {
    PersonFormView(person: nil)
}
