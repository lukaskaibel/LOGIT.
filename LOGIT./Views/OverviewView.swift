//
//  OverviewView.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 11.09.23.
//

import SwiftUI

struct OverviewView<Content: View>: View {
    
    @EnvironmentObject var overviewController: OverviewController
    
    @ObservedObject var collection: OverviewItemCollection
    let content: (OverviewItem) -> Content
    
    @State private var isShowingUpgradeToPro = false
    
    var body: some View {
        VStack(spacing: SECTION_HEADER_SPACING) {
            HStack {
                Text(NSLocalizedString("overview", comment: ""))
                    .sectionHeaderStyle2()
                Spacer()
                Menu {
                    ForEach(collection.items) { item in
                        let canUseFeature = !item.isProFeature || isProUser
                        Button {
                            if canUseFeature {
                                item.isAdded.toggle()
                                overviewController.save()
                            } else {
                                isShowingUpgradeToPro = true
                            }
                        } label: {
                            HStack {
                                Text(NSLocalizedString(item.id!, comment: ""))
                                Spacer()
                                if canUseFeature {
                                    Image(systemName: item.isAdded ? "checkmark" : "plus")
                                } else {
                                    Image(systemName: "crown.fill")
                                }
                            }
                        }
                    }
                } label: {
                    Label("Widget", systemImage: "plus")
                }
            }
            VStack(spacing: CELL_SPACING) {
                ReorderableForEach($collection.items) { item in
                    if item.isAdded {
                        content(item)
                            .transition(.scale)
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingUpgradeToPro) {
            UpgradeToProScreen()
        }
    }
    
}

// MARK: - Preview

//private struct PreviewWrapperView: View {
//
//    @State private var items: [OverviewView.Item] = [.init(id: "1", name: "1", content: AnyView(Text("1")), isAdded: false), .init(id: "2", name: "2", content: AnyView(Text("2")), isAdded: true), .init(id: "3", name: "3", content: AnyView(Text("3")), isAdded: false)]
//
//    var body: some View {
//        OverviewView(items: $items)
//    }
//
//}
//
//struct OverviewView_Previews: PreviewProvider {
//    static var previews: some View {
//        PreviewWrapperView()
//    }
//}
