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
    @State private var showingTemplateCreation = false
    
    // MARK: - Body
    
    var body: some View {
        List {
            ForEach(templates, id:\.objectID) { template in
                ZStack {
                    TemplateCell(template: template)
                    NavigationLink(destination: TemplateDetailView(template: template)) {
                        EmptyView()
                    }.opacity(0)
                }.padding(CELL_PADDING)
            }.onDelete { indexSet in
                templates
                    .elements(for: indexSet)
                    .forEach { database.delete($0, saveContext: true) }
            }
            .listRowInsets(EdgeInsets())
        }.listStyle(.insetGrouped)
            .searchable(text: $searchedText)
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle(NSLocalizedString("templates", comment: ""))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
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
    
    // MARK: - Supporting Methods
    
    private var templates: [Template] {
        database.getTemplates(withNameIncluding: searchedText)
    }
    
}

struct TemplateListView_Previews: PreviewProvider {
    static var previews: some View {
        TemplateListView()
    }
}
