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
                VerticalMuscleGroupIndicator(muscleGroupAmounts: template.muscleGroupOccurances)
                VStack(alignment: .leading) {
                    Text(lastUsedDate)
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
            Image(systemName: "chevron.right")
                .font(.body.weight(.medium))
                .foregroundColor(.secondaryLabel)
        }
    }
    
    // MARK: - Computed UI Properties
    
    private var lastUsedDate: String {
        if let date = template.date {
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
