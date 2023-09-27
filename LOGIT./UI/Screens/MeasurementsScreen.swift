//
//  MeasurementsScreen.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 25.09.23.
//

import SwiftUI

struct MeasurementsScreen: View {

    // MARK: - Environment

    @EnvironmentObject var database: Database
    @EnvironmentObject var widgetController: WidgetController
    @EnvironmentObject var measurementController: MeasurementEntryController

    var body: some View {
        ScrollView {
            VStack(spacing: SECTION_SPACING) {
                WidgetCollectionView(
                    title: NSLocalizedString("coreMetrics", comment: ""),
                    collection: widgetController.baseMeasurementCollection
                ) { widget in
                    Group {
                        switch widget.type {
                        case .measurement(let measurementType):
                            MeasurementEntryView(measurementType: measurementType)
                                .padding(CELL_PADDING)
                                .tileStyle()
                        default: EmptyView()
                        }
                    }
                }
                WidgetCollectionView(
                    title: NSLocalizedString("bodyParts", comment: ""),
                    collection: widgetController.circumferenceMeasurementCollection
                ) { widget in
                    Group {
                        switch widget.type {
                        case .measurement(let measurementType):
                            MeasurementEntryView(measurementType: measurementType)
                                .padding(CELL_PADDING)
                                .tileStyle()
                        default: EmptyView()
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, SCROLLVIEW_BOTTOM_PADDING)
        }
        .navigationTitle(NSLocalizedString("measurements", comment: ""))
    }
}

struct MeasurementsScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MeasurementsScreen()
                .environmentObject(Database.preview)
                .environmentObject(WidgetController.preview)
                .environmentObject(MeasurementEntryController.preview)
        }
    }
}
