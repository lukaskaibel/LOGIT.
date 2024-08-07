//
//  WorkoutRecorderStartScreen.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 06.04.22.
//

import SwiftUI

struct StartWorkoutScreen: View {

    enum FullScreenCoverType: Identifiable {
        case scanScreen
        var id: Int {
            switch self {
            case .scanScreen: return 0
            }
        }
    }

    enum SheetType: Identifiable {
        case templateDetail(template: Template), upgradeToPro
        var id: UUID { UUID() }
    }

    // MARK: - Environment

    @EnvironmentObject var database: Database
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @EnvironmentObject var workoutRecorder: WorkoutRecorder

    // MARK: - State

    private struct TemplateSelection: Identifiable {
        let id = UUID()
        let value: Template?
    }

    @State private var sheetType: SheetType? = nil
    @State private var fullScreenCoverType: FullScreenCoverType? = nil
    
    @State private var templateImage: UIImage?
    @State private var generatedTemplate: Template?

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: SECTION_SPACING) {
                HStack {
                    scanWorkoutButton
                    withoutTemplateButton
                }
                .disabled(workoutRecorder.workout != nil)
                .padding(.horizontal)
                .padding(.vertical)
                VStack(spacing: SECTION_HEADER_SPACING) {
                    HStack {
                        Text(NSLocalizedString("myTemplates", comment: ""))
                            .sectionHeaderStyle2()
                        Spacer()
                        CreateTemplateMenu()
                    }
                    LazyVStack(spacing: CELL_SPACING) {
                        templateList
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, SCROLLVIEW_BOTTOM_PADDING)
            .padding(.top)
        }
        .templateGeneration(from: $templateImage, to: $generatedTemplate)
        .onChange(of: generatedTemplate) { newValue in
            if let template = newValue {
                database.flagAsTemporary(template)
                workoutRecorder.startWorkout(from: template)
            }
        }
        .navigationTitle(NSLocalizedString("startWorkout", comment: ""))
        .fullScreenCover(item: $fullScreenCoverType) { type in
            switch type {
            case .scanScreen:
                ScanScreen(selectedImage: $templateImage, type: .workout)
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
            case .upgradeToPro:
                UpgradeToProScreen()
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
            workoutRecorder.startWorkout()
        } label: {
            VStack(spacing: 12) {
                Image(systemName: "play.fill")
                    .font(.title2)
                Text(NSLocalizedString("startEmpty", comment: ""))
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .lineLimit(2, reservesSpace: true)
            }
            .fontWeight(.semibold)
        }
        .buttonStyle(BigButtonStyle())
    }
    
    private var scanWorkoutButton: some View {
        Button {
            if purchaseManager.hasUnlockedPro {
                guard networkMonitor.isConnected else { return }
                fullScreenCoverType = .scanScreen
            } else {
                sheetType = .upgradeToPro
            }
        } label: {
            VStack(spacing: 12) {
                Image(systemName: purchaseManager.hasUnlockedPro ? "camera.fill" : "crown.fill")
                    .font(.title2)
                Text(NSLocalizedString("startFromScan", comment: ""))
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .lineLimit(2, reservesSpace: true)
            }
            .fontWeight(.semibold)
        }
        .buttonStyle(SecondaryBigButtonStyle())
        .requiresNetworkConnection()
    }

    private var templateList: some View {
        ForEach(database.getTemplates(), id: \.objectID) { template in
            Button {
                workoutRecorder.startWorkout(from: template)
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
            .buttonStyle(TileButtonStyle())
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
        .previewEnvironmentObjects()
    }
}
