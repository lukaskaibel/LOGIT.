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
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading) {
                Text("\(lastUsedDate)  ·  \(template.numberOfSetGroups) \(NSLocalizedString("exercise" + "\(template.numberOfSetGroups == 1 ? "" : "s")", comment: ""))")
                    .font(.footnote.weight(.medium))
                    .foregroundColor(.secondaryLabel)
                Text(template.name ?? NSLocalizedString("noName", comment: ""))
                    .font(.title3.weight(.bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            HStack {
                ColorMeter(items: template.muscleGroupOccurances.map {
                    ColorMeter.Item(color: $0.color, amount: $1)
                })
                Text("\(exercisesString)")
                    .foregroundColor(.primary)
                    .lineLimit(2, reservesSpace: true)
                    .multilineTextAlignment(.leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
