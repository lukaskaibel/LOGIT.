//
//  ExerciseSelectionView.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 11.12.21.
//

import SwiftUI
import CoreData

struct ExerciseSelectionView: View {
    
    // MARK: - Environment
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var database: Database
    
    // MARK: - State
    
    @State private var searchedText: String = ""
    @State private var selectedMuscleGroup: MuscleGroup?
    @State private var isAddingExercise: Bool = false
    
    // MARK: - Binding
    
    let selectedExercise: Exercise?
    let setExercise: (Exercise) -> Void
    
    // MARK: - Body
    
    var body: some View {
        List {
            MuscleGroupSelector(selectedMuscleGroup: $selectedMuscleGroup)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            ForEach(database.getGroupedExercises(withNameIncluding: searchedText, for: selectedMuscleGroup)) { group in
                exerciseSection(for: group)
            }
        }.listStyle(.plain)
            .navigationTitle(selectedExercise == nil  ? NSLocalizedString("addExercise", comment: "") : NSLocalizedString("selectExercise", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchedText,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: NSLocalizedString("searchExercises", comment: ""))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isAddingExercise = true
                    }, label: {
                        Image(systemName: "plus")
                    })
                }
            }
            .sheet(isPresented: $isAddingExercise) {
                EditExerciseView()
            }
    }
    
    // MARK: - Supporting Views
    
    @ViewBuilder
    private func exerciseSection(for group: [Exercise]) -> some View {
        Section(content: {
            ForEach(group, id:\.objectID) { exercise in
                HStack {
                    Text(exercise.name ?? "No Name")
                        .font(.body.weight(.semibold))
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            setExercise(exercise)
                            dismiss()
                        }
                    Spacer()
                    if selectedExercise == exercise {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.accentColor)
                            .font(.title3.weight(.semibold))
                    }
                    Menu(content: {
                        Button(role: .destructive, action: {
                            database.delete(exercise, saveContext: true)
                        }) {
                            Label("\(NSLocalizedString("delete", comment: "")) \(exercise.name ?? "")", systemImage: "trash")
                        }
                    }) {
                        Image(systemName: "ellipsis")
                            .padding(8)
                            .contentShape(Rectangle())
                    }.foregroundColor(.label)
                }.padding(.vertical, 8)
            }
        }, header: {
            Text((group.first?.name?.first ?? Character(" ")).uppercased())
                .sectionHeaderStyle()
        })
    }
    
}

struct ExerciseSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ExerciseSelectionView(selectedExercise: Exercise(), setExercise: { _ in })
        }
    }
}
