//
//  TemplateSetGroupDetailView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 01.10.22.
//

import SwiftUI

struct TemplateSetGroupDetailView: View {
    
    // MARK: - Graphical Constants
    
    static let columnWidth: CGFloat = 70
    static let columnSpace: CGFloat = 20
    
    // MARK: - Parameters
    
    let templateSetGroup: TemplateSetGroup
    let indexInWorkout: Int
    
    // MARK: - Body
    
    var body: some View {
        Section {
            VStack(spacing: 0) {
                Divider()
                    .padding(.leading)
                ForEach(templateSetGroup.sets, id:\.objectID) { templateSet in
                    VStack(alignment: .trailing, spacing: 0) {
                        EmptyView()
                            .frame(height: 1)
                        HStack {
                            Text("\(NSLocalizedString("set", comment: "")) \((templateSetGroup.index(of: templateSet) ?? 0) + 1)")
                                .font(.body.monospacedDigit())
                            TemplateSetCell(templateSet: templateSet)
                                .padding(.vertical, 8)
                                .padding(.horizontal)
                        }
                        Divider()
                    }.padding(.leading)
                }
            }.listRowSeparator(.hidden)
        } header: {
            header(for: templateSetGroup)
                .listRowInsets(EdgeInsets())
        }.padding(.leading)
    }
    
    // MARK: - Supporting Views
    
    @ViewBuilder
    private func header(for templateSetGroup: TemplateSetGroup) -> some View {
        VStack(spacing: 3) {
            HStack {
                if let exercise = templateSetGroup.exercise {
                    Text("\(indexInWorkout + 1).")
                    NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                        HStack(spacing: 3) {
                            Text("\(exercise.name ?? "")")
                                .lineLimit(1)
                                .multilineTextAlignment(.leading)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.separator)
                                .font(.caption)
                        }
                    }
                    Spacer()
                }
            }.font(.body.weight(.semibold))
                .foregroundColor(.label)
            if templateSetGroup.setType == .superSet, let secondaryExercise = templateSetGroup.secondaryExercise {
                HStack {
                    Image(systemName: "arrow.turn.down.right")
                        .font(.caption)
                    NavigationLink(destination: ExerciseDetailView(exercise: secondaryExercise)) {
                        HStack(spacing: 3) {
                            Text("\(secondaryExercise.name ?? "")")
                                .lineLimit(1)
                                .multilineTextAlignment(.leading)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.separator)
                                .font(.caption)
                        }
                    }
                    Spacer()
                }.padding(.leading, 30)
            }
            HStack(spacing: SetGroupDetailView.columnSpace) {
                Spacer()
                Text(NSLocalizedString("reps", comment: "").uppercased())
                    .font(.footnote)
                    .foregroundColor(.secondaryLabel)
                    .frame(maxWidth: SetGroupDetailView.columnWidth)
                Text(WeightUnit.used.rawValue.uppercased())
                    .font(.footnote)
                    .foregroundColor(.secondaryLabel)
                    .frame(maxWidth: SetGroupDetailView.columnWidth)
            }.padding(.horizontal)
        }.font(.body.weight(.semibold))
            .foregroundColor(.label)
            .padding(.top)
            .padding(.bottom, 5)
    }
    
}


struct TemplateSetCell: View {
    
    @ObservedObject var templateSet: TemplateSet
    
    var body: some View {
        HStack {
            Spacer()
            if let templateStandardSet = templateSet as? TemplateStandardSet {
                TemplateStandardSetCell(for: templateStandardSet)
            } else if let templateDropSet = templateSet as? TemplateDropSet {
                TemplateDropSetCell(for: templateDropSet)
            } else if let templateSuperSet = templateSet as? TemplateSuperSet {
                TemplateSuperSetCell(for: templateSuperSet)
            }
        }
    }
    
    private func TemplateStandardSetCell(for templateStandardSet: TemplateStandardSet) -> some View {
        TemplateSetEntry(repetitions: Int(templateStandardSet.repetitions), weight: Int(templateStandardSet.weight))
    }
    
    private func TemplateDropSetCell(for templateDropSet: TemplateDropSet) -> some View {
        VStack(alignment: .trailing) {
            ForEach(0..<(templateDropSet.repetitions?.count ?? 0), id:\.self) { index in
                TemplateSetEntry(repetitions: Int(templateDropSet.repetitions?.value(at: index) ?? 0),
                                weight: Int(templateDropSet.weights?.value(at: index) ?? 0))
            }
        }
    }
    
    private func TemplateSuperSetCell(for templateSuperSet: TemplateSuperSet) -> some View {
        VStack(alignment: .trailing) {
            HStack {
                Text(templateSuperSet.exercise?.name ?? "")
                    .foregroundColor(.secondaryLabel)
                    .font(.caption)
                TemplateSetEntry(repetitions: Int(templateSuperSet.repetitionsFirstExercise),
                                weight: Int(templateSuperSet.weightFirstExercise))
            }
            HStack {
                Text(templateSuperSet.secondaryExercise?.name ?? "")
                    .foregroundColor(.secondaryLabel)
                    .font(.caption)
                TemplateSetEntry(repetitions: Int(templateSuperSet.repetitionsSecondExercise),
                                weight: Int(templateSuperSet.weightSecondExercise))
            }
        }
    }
    
    private func TemplateSetEntry(repetitions: Int, weight: Int) -> some View {
        HStack(spacing: SetGroupDetailView.columnSpace) {
            Text(repetitions > 0 ? String(repetitions) : "")
                .frame(maxWidth: SetGroupDetailView.columnWidth)
            Text(weight > 0 ? String(convertWeightForDisplaying(weight)) : "")
                .frame(maxWidth: SetGroupDetailView.columnWidth)
        }.padding(.vertical, 5)
    }
            
    var dividerCircle: some View {
        Circle()
            .foregroundColor(.separator)
            .frame(width: 4, height: 4)
    }
    
}
