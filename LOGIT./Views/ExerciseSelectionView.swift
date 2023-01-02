//
//  ExerciseSelectionView.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 11.12.21.
//

import SwiftUI
import CoreData

struct ExerciseSelectionView: View {
    
    enum SheetType: Identifiable {
        case addExercise, exerciseDetail(exercise: Exercise)
        var id: Int { switch self { case .addExercise: return 0; case .exerciseDetail: return 1 } }
    }
    
    // MARK: - Environment
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var database: Database
    
    // MARK: - State
    
    @State private var searchedText: String = ""
    @State private var selectedMuscleGroup: MuscleGroup?
    @State private var sheetType: SheetType?
    
    // MARK: - Binding
    
    let selectedExercise: Exercise?
    let setExercise: (Exercise) -> Void
    
    // MARK: - Body
    
    var body: some View {
        List {
            MuscleGroupSelector(selectedMuscleGroup: $selectedMuscleGroup)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            ForEach(database.getGroupedExercises(withNameIncluding: searchedText, for: selectedMuscleGroup)) { group in
                exerciseSection(for: group)
            }.listRowInsets(EdgeInsets())
            Spacer(minLength: 30)
                .listRowBackground(Color.clear)
        }.listStyle(.insetGrouped)
            .offset(x: 0, y: -30)
            .edgesIgnoringSafeArea(.bottom)
            .navigationTitle(NSLocalizedString("chooseExercise", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchedText,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: NSLocalizedString("searchExercises", comment: ""))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        sheetType = .addExercise
                    }, label: {
                        Image(systemName: "plus")
                    })
                }
            }
            .sheet(item: $sheetType) { type in
                switch type {
                case .addExercise:
                    EditExerciseView(onEditFinished: { setExercise($0); dismiss() }, initialMuscleGroup: selectedMuscleGroup ?? .chest)
                case let .exerciseDetail(exercise):
                    NavigationStack {
                        ExerciseDetailView(exercise: exercise)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button(NSLocalizedString("dismiss", comment: "")) { sheetType = nil }
                                }
                            }
                    }
                }
            }
    }
    
    // MARK: - Supporting Views
    
    @ViewBuilder
    private func exerciseSection(for group: [Exercise]) -> some View {
        Section(content: {
            ForEach(group, id:\.objectID) { exercise in
                HStack {
                    ExerciseCell(exercise: exercise)
                    Spacer()
                    if exercise == selectedExercise {
                        Image(systemName: "checkmark")
                            .fontWeight(.semibold)
                            .foregroundColor(exercise.muscleGroup?.color)
                    }
                    Button {
                        sheetType = .exerciseDetail(exercise: exercise)
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.title3)
                    }.buttonStyle(.plain)
                        .foregroundColor(exercise.muscleGroup?.color)
                }
                .padding(.trailing)
                .contentShape(Rectangle())
                .onTapGesture {
                    setExercise(exercise)
                    dismiss()
                }
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
            ExerciseSelectionView(selectedExercise: nil, setExercise: { _ in })
                .environmentObject(Database.preview)
        }
    }
}
