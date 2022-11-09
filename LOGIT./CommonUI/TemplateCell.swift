//
//  TemplateCell.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 06.04.22.
//

import SwiftUI

struct TemplateCell: View {
    
    // MARK: - Variables
    
    @ObservedObject var template: Template
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            HStack(alignment: .top) {
                ColorMeter(items: template.muscleGroupOccurances
                    .map { ColorMeter.Item(color: $0.color, amount: $1) })
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 5) {
                        Image(systemName: "list.bullet.rectangle.portrait")
                        Text(lastUsedDate)
                    }
                    .font(.footnote.weight(.medium))
                    .foregroundColor(.secondaryLabel)
                    Text(template.name ?? "No name")
                        .font(.headline)
                        .lineLimit(1)
                    Text(exercisesString)
                        .lineLimit(2, reservesSpace: true)
                }
            }
            Spacer()
        }
    }
    
    // MARK: - Computed Properties
    
    private var lastUsedDate: String {
        if let date = template.lastUsed {
            return "\(NSLocalizedString("lastUsed", comment: "")) \(date.description(.short))"
        } else {
            return NSLocalizedString("unused", comment: "")
        }
    }
    
    private var exercisesString: String {
        var result = ""
        for exercise in template.exercises {
            if let name = exercise.name {
                result += (!result.isEmpty ? ", " : "") + name
            }
        }
        return result.isEmpty ? " " : result
    }
    
}

struct TemplateCell_Previews: PreviewProvider {
    static var previews: some View {
        TemplateCell(template: Database.preview.newTemplate(name: "Pushday"))
    }
}
