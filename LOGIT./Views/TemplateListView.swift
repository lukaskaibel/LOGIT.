//
//  TemplateListView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 06.04.22.
//

import SwiftUI

struct TemplateListView: View {
    
    // MARK: - Environment
    
    @EnvironmentObject var database: Database
    
    // MARK: - State
    
    @State private var searchedText = ""
    @State private var sortingKey: Database.TemplateSortingKey = .name
    @State private var showingTemplateCreation = false
    
    // MARK: - Body
    
    var body: some View {
        List {
            ForEach(groupedTemplates.indices, id:\.self) { index in
                Section {
                    ForEach(groupedTemplates.value(at: index) ?? [], id:\.objectID) { template in
                        ZStack {
                            HStack {
                                TemplateCell(template: template)
                                NavigationChevron()
                                    .foregroundColor(template.primaryMuscleGroup?.color ?? .separator)
                            }
                            NavigationLink(destination: TemplateDetailView(template: template)) {
                                EmptyView()
                            }.opacity(0)
                        }.padding(CELL_PADDING)
                    }
                } header: {
                    Text(header(for: index))
                        .sectionHeaderStyle()
                }
                .listRowInsets(EdgeInsets())
            }
        }.listStyle(.insetGrouped)
            .searchable(text: $searchedText)
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle(NSLocalizedString("templates", comment: ""))
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            sortingKey = .name
                        }) {
                            Label(NSLocalizedString("name", comment: ""), systemImage: "textformat")
                        }
                        Button(action: {
                            sortingKey = .lastUsed
                        }) {
                            Label(NSLocalizedString("lastUsed", comment: ""), systemImage: "calendar")
                        }
                    } label: {
                        Label(NSLocalizedString(sortingKey == .name ? "name" : "lastUsed", comment: ""), 
                              systemImage: "arrow.up.arrow.down")
                    }
                    Button(action: {
                        showingTemplateCreation = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .popover(isPresented: $showingTemplateCreation) {
                TemplateEditorView(template: database.newTemplate(), isEditingExistingTemplate: false)
            }
    }
    
    // MARK: - Computed Properties
    
    private var groupedTemplates: [[Template]] {
        database.getGroupedTemplates(withNameIncluding: searchedText, groupedBy: sortingKey)
    }
    
    private func header(for index: Int) -> String {
        switch sortingKey {
        case .name:
            return String(groupedTemplates.value(at: index)?.first?.name?.first ?? " ").capitalized
        case .lastUsed:
            guard let date = groupedTemplates.value(at: index)?.first?.lastUsed else { return NSLocalizedString("unused", comment: "") }
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: date)
        
        }
    }
    
}

struct TemplateListView_Previews: PreviewProvider {
    static var previews: some View {
        TemplateListView()
    }
}
