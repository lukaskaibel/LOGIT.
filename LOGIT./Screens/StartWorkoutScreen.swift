//
//  WorkoutRecorderStartScreen.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 06.04.22.
//

import SwiftUI

struct StartWorkoutScreen: View {
    
    enum FullScreenCoverType: Identifiable {
        case workoutRecorder(template: Template?)
        var id: Int { switch self { case .workoutRecorder: return 0 } }
    }
    
    enum SheetType: Identifiable {
        case templateDetail(template: Template)
        var id: UUID { UUID() }
    }
    
    // MARK: - Environment
    
    @EnvironmentObject var database: Database

    // MARK: - State
    
    private struct TemplateSelection: Identifiable {
        let id = UUID()
        let value: Template?
    }
    
    @State private var sheetType: SheetType? = nil
    @State private var fullScreenCoverType: FullScreenCoverType? = nil
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: SECTION_SPACING) {
                withoutTemplateButton
                    .padding(.horizontal)
                    .padding(.vertical, 30)
                VStack(spacing: SECTION_HEADER_SPACING) {
                    Text(NSLocalizedString("myTemplates", comment: ""))
                        .sectionHeaderStyle2()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    LazyVStack(spacing: CELL_SPACING) {
                        templateList
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, SCROLLVIEW_BOTTOM_PADDING)
            .padding(.top)
        }
        .navigationTitle(NSLocalizedString("startWorkout", comment: ""))
        .fullScreenCover(item: $fullScreenCoverType) { type in
            switch type {
            case let .workoutRecorder(template): WorkoutRecorderScreen(workout: database.newWorkout(), template: template)
            }
        }
        .sheet(item: $sheetType) { type in
            switch type {
            case let .templateDetail(template):
                NavigationStack {
                    TemplateDetailScreen(template: template)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(NSLocalizedString("back", comment: "")) {
                                    sheetType = nil
                                }
                            }
                        }
                }
            }
        }
    }
    
    // MARK: - Supporting Views
    
    private var chooseTemplateText: some View {
        Text(NSLocalizedString("chooseTemplateText", comment: ""))
            .foregroundColor(.secondaryLabel)
            .font(.subheadline)
            .padding(.top)
            .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private var withoutTemplateButton: some View {
        Button {
            fullScreenCoverType = .workoutRecorder(template: nil)
        } label: {
            Text(NSLocalizedString("startEmpty", comment: ""))
                .bigButton()
        }
    }
    
    private var templateList: some View {
        ForEach(database.getTemplates(), id:\.objectID) { template in
            Button {
                fullScreenCoverType = .workoutRecorder(template: template)
            } label: {
                HStack {
                    TemplateCell(template: template)
                        .foregroundColor(.label)
                    Spacer()
                    Button {
                        sheetType = .templateDetail(template: template)
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.title3)
                    }
                    NavigationChevron()
                }
                .muscleGroupGradientStyle(for: template.muscleGroups)
                .padding(CELL_PADDING)
                .tileStyle()
            }
        }
        .emptyPlaceholder(database.getTemplates()) {
            Text(NSLocalizedString("noTemplates", comment: ""))
                .frame(maxWidth: .infinity)
                .frame(height: 200)
        }
    }
    
}

struct WorkoutRecorderStartScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StartWorkoutScreen()
        }
        .environmentObject(Database.preview)
    }
}
