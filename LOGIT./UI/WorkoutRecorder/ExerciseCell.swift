//
//  ExerciseCell.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 02.03.22.
//

import SwiftUI

struct ExerciseCell: View {
    
    @EnvironmentObject var workoutRecorder: WorkoutRecorder
    
    @ObservedObject var setGroup: WorkoutSetGroup
    @StateObject private var exerciseDetail: ExerciseDetail
    
    init(setGroup: WorkoutSetGroup, showingExerciseSelection: Binding<Bool>) {
        self.setGroup = setGroup
        self._showingExerciseSelection = showingExerciseSelection
        _exerciseDetail = StateObject(wrappedValue: ExerciseDetail(context: Database.shared.container.viewContext,
                                                                   exerciseID: setGroup.exercise!.objectID)) 
    }
    
    @Binding var showingExerciseSelection: Bool
    
    @State private var isShowingExerciseDetail: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            ExerciseHeader
            Divider()
                .padding(.leading)
                .padding(.bottom, 5)
            ForEach(setGroup.sets?.array as? [WorkoutSet] ?? .emptyList, id:\.objectID) { workoutSet in
                WorkoutSetCell(workoutSet: workoutSet)
            }
            Button(action: {
                workoutRecorder.addSet(to: setGroup)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }) {
                Label("Add Set", systemImage: "plus.circle.fill")
                    .foregroundColor(.accentColor)
                    .font(.body.weight(.bold))
            }.padding(15)
                .frame(maxWidth: .infinity)
        }.background(Color.tertiaryBackground)
            .cornerRadius(15)
            .shadow(color: .shadow, radius: 5, x: 0, y: 5)
            .buttonStyle(.plain)
            .sheet(isPresented: $isShowingExerciseDetail) {
                NavigationView {
                    ExerciseDetailView(exerciseDetail: exerciseDetail)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Dismiss") {
                                    isShowingExerciseDetail = false
                                }
                            }
                        }
                }
            }
    }
    
    var ExerciseHeader: some View {
        HStack {
            Button(action: {
                workoutRecorder.setGroupWithSelectedExercise = setGroup
                showingExerciseSelection = true
            }) {
                HStack(spacing: 3) {
                    Text(setGroup.exercise?.name ?? "No Name")
                        .font(.title3.weight(.semibold))
                        .lineLimit(1)
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondaryLabel)
                        .font(.caption.weight(.semibold))
                }
            }
            Spacer()
            Menu(content: {
                Section {
                    Button(action: {
                        isShowingExerciseDetail = true
                    }) {
                        Label("Show \(setGroup.exercise?.name ?? "")", systemImage: "info.circle")
                    }
                }
                Section {
                    Button(role: .destructive, action: {
                        withAnimation {
                            workoutRecorder.delete(setGroup: setGroup)
                        }
                    }) {
                        Label("Remove", systemImage: "xmark.circle")
                    }
                }
            }) {
                Image(systemName: "ellipsis")
                    .foregroundColor(.label)
                    .padding(7)
            }
        }.padding()
    }
    
    private struct WorkoutSetCell: View {
        
        @EnvironmentObject var workoutRecorder: WorkoutRecorder
        
        @ObservedObject var workoutSet: WorkoutSet
        
        var repetitionsString: Binding<String> {
            Binding<String>(
                get: { workoutSet.repetitions == 0 ? "" : String(workoutSet.repetitions) },
                set: {
                    value in workoutSet.repetitions = NumberFormatter().number(from: value)?.int64Value ?? 0
                    workoutRecorder.updateView()
                }
            )
        }
        
        var weightString: Binding<String> {
            Binding<String>(
                get: { workoutSet.weight == 0 ? "" : String(convertWeightForDisplaying(workoutSet.weight)) },
                set: {
                    value in workoutSet.weight = convertWeightForStoring(NumberFormatter().number(from: value)?.int64Value ?? 0)
                    workoutRecorder.updateView()
                }
            )
        }
        
        var body: some View {
            HStack {
                Text(String((workoutRecorder.indexInSetGroup(for: workoutSet) ?? 0) + 1))
                    .foregroundColor(.secondaryLabel)
                    .font(.body.monospacedDigit())
                    .padding()
                TextField("0", text: repetitionsString)
                    .keyboardType(.numberPad)
                    .foregroundColor(.accentColor)
                    .font(.body.weight(.semibold))
                    .multilineTextAlignment(.trailing)
                    .padding(7)
                    .background(workoutSet.repetitions == 0 ? .secondaryBackground : Color.accentColor.opacity(0.1))
                    .cornerRadius(5)
                    .overlay {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(workoutSet.repetitions == 0 ? .secondaryLabel : .accentColor)
                                .font(.caption.weight(.bold))
                                .padding(7)
                            Spacer()
                        }
                    }
                TextField("0", text: weightString)
                    .keyboardType(.numberPad)
                    .foregroundColor(.accentColor)
                    .font(.body.weight(.semibold))
                    .multilineTextAlignment(.trailing)
                    .padding(7)
                    .background(workoutSet.weight == 0 ? .secondaryBackground : Color.accentColor.opacity(0.1))
                    .cornerRadius(5)
                    .overlay {
                        HStack {
                            Image(systemName: "scalemass")
                                .foregroundColor(workoutSet.weight == 0 ? .secondaryLabel : .accentColor)
                                .font(.caption.weight(.bold))
                                .padding(7)
                            Spacer()
                        }
                    }
            }.padding(.trailing)
                .onDelete {
                    workoutRecorder.delete(set: workoutSet)
                }
        }
        
    }
    
}

struct ExerciseCell_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseCell(setGroup: WorkoutSetGroup(), showingExerciseSelection: .constant(false))
            .environmentObject(WorkoutRecorder(database: Database.preview))
    }
}
