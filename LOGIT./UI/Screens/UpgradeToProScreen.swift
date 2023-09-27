//
//  UpgradeToProScreen.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 14.09.23.
//

import SwiftUI

struct UpgradeToProScreen: View {

    private let database = Database.preview

    var body: some View {
        ScrollView {
            VStack(spacing: SECTION_SPACING) {
                LogitProLogo()
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()

                VStack(spacing: SECTION_HEADER_SPACING) {
                    Text("Features")
                        .sectionHeaderStyle2()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    VStack(alignment: .leading, spacing: 10) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Visualisation")
                                .font(.body.weight(.semibold))
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                            Text("Plot your Progress")
                                .font(.title.weight(.bold))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.horizontal, .top], CELL_PADDING)
                        Text("Choose from a collection of powerful charts.")
                            .font(.title3.weight(.medium))
                            .padding(.horizontal, CELL_PADDING)
                        TabView {
                            bestWeightChart
                                .padding(.horizontal, CELL_PADDING)
                            muscleGroupGraph
                                .padding(.horizontal, CELL_PADDING)
                        }
                        .tabViewStyle(.page)
                        .frame(height: 300)
                        .padding(.bottom, CELL_PADDING)
                    }
                    .tileStyle()
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 10) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Save time")
                                .font(.body.weight(.semibold))
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                            Text("Scan a Workout")
                                .font(.title.weight(.bold))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Text(
                            "Take a photo or screenshot of a workout to start working out in seconds."
                        )

                    }
                    .padding(CELL_PADDING)
                    .tileStyle()
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 10) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Track More")
                                .font(.body.weight(.semibold))
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                            Text("Measure your Body")
                                .font(.title.weight(.bold))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Stay on track by measuring and tracking your individual body parts.")

                    }
                    .padding(CELL_PADDING)
                    .tileStyle()
                    .padding(.horizontal)

                }

                Spacer()
            }
            .padding(.bottom, 200)
        }
        .overlay {
            VStack(spacing: 20) {
                HStack {
                    Text("Pricing")
                    Spacer()
                    HStack(alignment: .lastTextBaseline, spacing: 3) {
                        Text("1.99")
                            .font(.body.weight(.semibold))
                        Text("€ / Month")
                            .font(.footnote.weight(.semibold))
                    }
                }
                Button {

                } label: {
                    HStack {
                        Image(systemName: "crown.fill")
                        Text("Upgrade to")
                        LogitProLogo()
                            .environment(\.colorScheme, .light)
                    }
                }
                .buttonStyle(BigButtonStyle())
                Button {

                } label: {
                    Text("Restore Purchase")
                }
            }
            .padding()
            .background {
                Rectangle()
                    .foregroundStyle(.thinMaterial)
                    .edgesIgnoringSafeArea(.bottom)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }

    private var bestWeightChart: some View {
        let exercise = database.getExercises(withNameIncluding: "benchpress").first!
        return VStack {
            VStack(alignment: .leading) {
                Text(NSLocalizedString("weight", comment: ""))
                    .tileHeaderStyle()
                Text(NSLocalizedString("bestPerDay", comment: ""))
                    .tileHeaderSecondaryStyle()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            DateLineChart(dateDomain: .threeMonths) {
                database.getWorkoutSets(with: exercise, onlyHighest: .weight, in: .day)
                    .filter { $0.max(.weight) > 0 }
                    .map {
                        .init(
                            date: $0.setGroup!.workout!.date!,
                            value: convertWeightForDisplaying($0.max(.weight))
                        )
                    }
            }
            .foregroundStyle((exercise.muscleGroup?.color.gradient)!)
        }
        .padding(CELL_PADDING)
        .secondaryTileStyle()
    }

    private var muscleGroupGraph: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("muscleGroups", comment: ""))
                        .tileHeaderStyle()
                    Text(NSLocalizedString("lastTenWorkouts", comment: ""))
                        .tileHeaderSecondaryStyle()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            PieGraph(
                items:
                    Array(
                        Array(database.getWorkouts(sortedBy: .date).prefix(10))
                            .reduce(
                                [:],
                                { current, workout in
                                    current.merging(
                                        workout.muscleGroupOccurances,
                                        uniquingKeysWith: +
                                    )
                                }
                            )
                            .merging(
                                MuscleGroup.allCases.reduce(
                                    into: [MuscleGroup: Int](),
                                    { $0[$1, default: 0] = 0 }
                                ),
                                uniquingKeysWith: +
                            )
                    )
                    .sorted {
                        MuscleGroup.allCases.firstIndex(of: $0.key)! < MuscleGroup.allCases
                            .firstIndex(
                                of: $1.key
                            )!
                    }
                    .map {
                        PieGraph.Item(
                            title: $0.0.description.capitalized,
                            amount: $0.1,
                            color: $0.0.color,
                            isSelected: false
                        )
                    },
                showZeroValuesInLegend: true
            )
        }
        .padding(CELL_PADDING)
        .secondaryTileStyle()
    }

}

struct UpgradeToProScreen_Previews: PreviewProvider {
    static var previews: some View {
        UpgradeToProScreen()
    }
}
