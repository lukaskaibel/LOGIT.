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
    
    // MARK: - State
    
    @State private var navigateToDetail = false
    @State private var exerciseForDetail: Exercise? = nil
    
    // MARK: - Parameters
    
    let templateSetGroup: TemplateSetGroup
    let supplementaryText: String
    
    // MARK: - Body
    
    var body: some View {
        Section {
            HStack(spacing: 0) {
                Text(templateSetGroup.setType == .superSet ? NSLocalizedString("superset", comment: "").uppercased() :
                        templateSetGroup.setType == .dropSet ? NSLocalizedString("dropset", comment: "").uppercased() :
                        NSLocalizedString("set", comment: "").uppercased())
                    .frame(maxWidth: SET_GROUP_FIRST_COLUMN_WIDTH)
                Text(NSLocalizedString("reps", comment: "").uppercased())
                    .frame(maxWidth: .infinity)
                Text(WeightUnit.used.rawValue.uppercased())
                    .frame(maxWidth: .infinity)
            }
            .font(.caption)
            .foregroundColor(.secondaryLabel)
            .padding(.horizontal, CELL_PADDING)
            .listRowBackground(Color.fill)
            .listRowInsets(EdgeInsets())
            ZStack {
                ColorMeter(items: [templateSetGroup.exercise?.muscleGroup?.color,
                                   templateSetGroup.secondaryExercise?.muscleGroup?.color]
                    .compactMap({$0}).map{ ColorMeter.Item(color: $0, amount: 1) })
                .padding( .vertical, CELL_PADDING)
                .frame(maxWidth: .infinity, alignment: .leading)
                VStack(spacing: 0) {
                    ForEach(templateSetGroup.sets, id:\.objectID) { templateSet in
                        HStack(spacing: 0) {
                            Text("\((templateSetGroup.index(of: templateSet) ?? 0) + 1)")
                                .font(.body.monospacedDigit())
                                .frame(minWidth: SET_GROUP_FIRST_COLUMN_WIDTH)
                            VStack(spacing: 0) {
                                EmptyView()
                                    .frame(height: 1)
                                TemplateSetCell(templateSet: templateSet)
                                    .padding(.vertical, 15)
                                Divider()
                                    .padding(.leading)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .padding(.horizontal, CELL_PADDING)
        } header: {
            VStack(alignment: .leading, spacing: 0) {
                Text(supplementaryText)
                    .font(.footnote.weight(.medium))
                    .foregroundColor(.secondaryLabel)
                    .textCase(.none)
                ExerciseHeader(exercise: templateSetGroup.exercise,
                               secondaryExercise: templateSetGroup.secondaryExercise,
                               exerciseAction: { exerciseForDetail = templateSetGroup.exercise; navigateToDetail = true },
                               secondaryExerciseAction: { exerciseForDetail = templateSetGroup.secondaryExercise },
                               isSuperSet: templateSetGroup.setType == .superSet)
            }
            .padding(.vertical, 10)
        }
        .navigationDestination(isPresented: $navigateToDetail) {
            if let exercise = exerciseForDetail {
                ExerciseDetailView(exercise: exercise)
            }
        }
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
        VStack(spacing: 10) {
            ForEach(0..<(templateDropSet.repetitions?.count ?? 0), id:\.self) { index in
                TemplateSetEntry(repetitions: Int(templateDropSet.repetitions?.value(at: index) ?? 0),
                                weight: Int(templateDropSet.weights?.value(at: index) ?? 0))
            }
        }
    }
    
    private func TemplateSuperSetCell(for templateSuperSet: TemplateSuperSet) -> some View {
        VStack(spacing: 10) {
            TemplateSetEntry(repetitions: Int(templateSuperSet.repetitionsFirstExercise),
                            weight: Int(templateSuperSet.weightFirstExercise))
            TemplateSetEntry(repetitions: Int(templateSuperSet.repetitionsSecondExercise),
                            weight: Int(templateSuperSet.weightSecondExercise))
        }
    }
    
    private func TemplateSetEntry(repetitions: Int, weight: Int) -> some View {
        HStack(spacing: 0) {
            Text(repetitions > 0 ? String(repetitions) : "–")
                .font(.system(.body, design: .rounded, weight: .bold))
                .frame(maxWidth: .infinity)
            Text(weight > 0 ? String(convertWeightForDisplaying(weight)) : "–")
                .font(.system(.body, design: .rounded, weight: .bold))
                .frame(maxWidth: .infinity)
        }
    }
    
}
