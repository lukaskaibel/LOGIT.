//
//  ExerciseDetailView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 06.01.22.
//

import SwiftUI
import CoreData
import Charts

struct ExerciseDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject var exerciseDetail: ExerciseDetail
    
    @State private var selectedAttribute: WorkoutSet.Attribute = .weight
    @State private var selectedCalendarComponent: Calendar.Component = .weekOfYear
    @State private var showDeletionAlert = false
    @State private var showingEditExercise = false
    @State private var selectedIndexInGraph: Int? = nil
    
    var body: some View {
        List {
            Section {
                header
            }.padding(.bottom)
                .listRowSeparator(.hidden, edges: .top)
            Section {
                exerciseInfo
            }
            Section {
                weightGraph
            } header: {
                Text(NSLocalizedString("weight", comment: ""))
                    .sectionHeaderStyle()
            }.listRowSeparator(.hidden)
            Section(content: {
                ForEach(exerciseDetail.sets) { workoutSet in
                    if workoutSet.hasEntry {
                        HStack {
                            Text(dateString(for: workoutSet))
                                .frame(maxHeight: .infinity, alignment: .top)
                                .padding(.vertical, 5)
                            Spacer()
                            WorkoutSetCell(workoutSet: workoutSet)
                        }
                    }
                }
            }, header: {
                VStack {
                    HStack {
                        Text(NSLocalizedString("sets", comment: ""))
                            .foregroundColor(.label)
                            .font(.title2.weight(.bold))
                            .fixedSize()
                        Spacer()
                        Menu {
                            Button(action: {
                                exerciseDetail.setSortingKey = .date
                            }) {
                                Label(NSLocalizedString("date", comment: ""), systemImage: "calendar")
                            }
                            Button(action: {
                                exerciseDetail.setSortingKey = .maxRepetitions
                            }) {
                                Label(NSLocalizedString("repetitions", comment: ""), systemImage: "arrow.counterclockwise")
                            }
                            Button(action: {
                                exerciseDetail.setSortingKey = .maxWeight
                            }) {
                                Label(NSLocalizedString("weight", comment: ""), systemImage: "scalemass")
                            }
                        } label: {
                            Label(NSLocalizedString(exerciseDetail.setSortingKey == .date ? "date" : exerciseDetail.setSortingKey == .maxRepetitions ? "repetitions" : "weight", comment: ""),
                                  systemImage: "arrow.up.arrow.down")
                            .font(.body)
                        }
                    }
                    HStack(spacing: SetGroupDetailView.columnSpace) {
                        Text(NSLocalizedString("date", comment: ""))
                            .font(.footnote)
                            .foregroundColor(.secondaryLabel)
                            .frame(maxWidth: SetGroupDetailView.columnWidth, alignment: .leading)
                        Spacer()
                        Text(NSLocalizedString("reps", comment: "").uppercased())
                            .font(.footnote)
                            .foregroundColor(.secondaryLabel)
                            .frame(maxWidth: SetGroupDetailView.columnWidth)
                        Text(WeightUnit.used.rawValue.uppercased())
                            .font(.footnote)
                            .foregroundColor(.secondaryLabel)
                            .frame(maxWidth: SetGroupDetailView.columnWidth)
                    }
                }.listRowSeparator(.hidden, edges: .top)
            }, footer: {
                Text("\(exerciseDetail.sets.filter { $0.hasEntry }.count) \(NSLocalizedString("set\(exerciseDetail.sets.count == 1 ? "" : "s")", comment: ""))")
                    .foregroundColor(.secondaryLabel)
                    .font(.footnote)
                    .padding(.top, 5)
                    .padding(.bottom, 50)
                    .listRowSeparator(.hidden, edges: .bottom)
            })
        }.listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu(content: {
                    Button(action: { showingEditExercise.toggle() }, label: { Label(NSLocalizedString("edit", comment: ""), systemImage: "pencil") })
                    Button(role: .destructive, action: { showDeletionAlert.toggle() }, label: { Label(NSLocalizedString("delete", comment: ""), systemImage: "trash") } )
                }) {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .confirmationDialog(Text(NSLocalizedString("deleteExerciseConfirmation", comment: "")), isPresented: $showDeletionAlert, titleVisibility: .visible) {
            Button("\(NSLocalizedString("delete", comment: ""))", role: .destructive, action: {
                exerciseDetail.deleteExercise()
                dismiss()
            })
        }
        .sheet(isPresented: $showingEditExercise) {
            EditExerciseView(editExercise: EditExercise(exerciseToEdit: exerciseDetail.exercise))
        }
    }
    
    /*
    private var WeightView: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("personalBest", comment: ""))
                        .foregroundColor(.secondaryLabel)
                    HStack(alignment: .lastTextBaseline) {
                        Text("\(exerciseDetail.personalBest(for: .weight)) \(WeightUnit.used.rawValue)")
                            .font(.title.weight(.medium))
                        Spacer()
                    }
                }
                Spacer()
            }.padding()
            BarGraph(xValues: exerciseDetail.getGraphXValues(for: .weight),
                      yValues: exerciseDetail.getGraphYValues(for: .weight),
                      barColors: [.accentColor, .accentColor, .accentColor, .accentColor, .accentColor])
                .frame(height: 120)
                .padding([.leading, .bottom])
                .padding(.trailing, 10)
            Picker("Select timeframe.", selection: $exerciseDetail.selectedCalendarComponentForWeight) {
                Text(NSLocalizedString("weekly", comment: "")).tag(Calendar.Component.weekOfYear)
                Text(NSLocalizedString("monthly", comment: "")).tag(Calendar.Component.month)
                Text(NSLocalizedString("yearly", comment: "")).tag(Calendar.Component.year)
            }.pickerStyle(.segmented)
                .padding([.horizontal, .bottom])
        }.background(Color.secondaryBackground)
            .cornerRadius(10)
            .listRowSeparator(.hidden)
    }
     */
    
    // MARK: - Supporting Views
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(exerciseDetail.exercise.name ?? "")
                .font(.largeTitle.weight(.bold))
                .lineLimit(2)
            Text(exerciseDetail.exercise.muscleGroup?.description.capitalized ?? "")
                .font(.system(.title2, design: .rounded, weight: .semibold))
                .foregroundColor(exerciseDetail.exercise.muscleGroup?.color ?? .clear)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var exerciseInfo: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(NSLocalizedString("maxReps", comment: ""))
                UnitView(value: String(exerciseDetail.personalBest(for: .repetitions)), unit: NSLocalizedString("rps", comment: ""))
                    .foregroundColor(exerciseDetail.exercise.muscleGroup?.color ?? .label)
            }.frame(maxWidth: .infinity, alignment: .leading)
            VStack(alignment: .leading) {
                Text(NSLocalizedString("maxWeight", comment: ""))
                UnitView(value: String(exerciseDetail.personalBest(for: .weight)), unit: WeightUnit.used.rawValue.capitalized)
                    .foregroundColor(exerciseDetail.exercise.muscleGroup?.color ?? .label)
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var weightGraph: some View {
        VStack {
            Chart {
                ForEach(exerciseDetail.personalBests(for: selectedAttribute, per: selectedCalendarComponent)) { chartEntry in
                    LineMark(x: .value("CalendarComponent", chartEntry.xValue),
                             y: .value(selectedAttribute.rawValue, chartEntry.yValue))
                    AreaMark(x: .value("CalendarComponent", chartEntry.xValue),
                             y: .value(selectedAttribute.rawValue, chartEntry.yValue))
                    .foregroundStyle(.linearGradient(colors: [.accentColor.opacity(0.5), .clear], startPoint: .top, endPoint: .bottom))
                }
            }.frame(height: 180)
            Picker("Calendar Component", selection: $selectedCalendarComponent) {
                Text(NSLocalizedString("weekly", comment: "")).tag(Calendar.Component.weekOfYear)
                Text(NSLocalizedString("monthly", comment: "")).tag(Calendar.Component.month)
                Text(NSLocalizedString("yearly", comment: "")).tag(Calendar.Component.year)
            }.pickerStyle(.segmented)
                .padding(.top)
        }.tileStyle()
    }
    
    var dividerCircle: some View {
        Circle()
            .foregroundColor(.separator)
            .frame(width: 4, height: 4)
    }
    
    private func dateString(for workoutSet: WorkoutSet) -> String {
        if let date = workoutSet.setGroup?.workout?.date {
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            formatter.dateStyle = .short
            return formatter.string(from: date)
        } else {
            return ""
        }
    }
    
}

struct ExerciseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseDetailView(exerciseDetail: ExerciseDetail(exerciseID: NSManagedObjectID()))
    }
}
