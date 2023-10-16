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
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text(
                    "\(lastUsedDate)  ·  \(template.numberOfSetGroups) \(NSLocalizedString("exercise" + "\(template.numberOfSetGroups == 1 ? "" : "s")", comment: ""))"
                )
                .font(.footnote.weight(.medium))
                .foregroundColor(.secondaryLabel)
                Text(template.name ?? NSLocalizedString("noName", comment: ""))
                    .font(.title3.weight(.bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            HStack {
                ForEach(template.muscleGroups) { muscleGroup in
                    Text(muscleGroup.description)
                        .font(.system(.body, design: .rounded, weight: .bold))
                        .foregroundStyle(muscleGroup.color.gradient)
                        .lineLimit(1)
                }
            }
            Text("\(exercisesString)")
                .foregroundColor(.secondary)
                .lineLimit(1)
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
        return result.isEmpty ? NSLocalizedString("noExercises", comment: "") : result
    }

}

private struct PreviewWrapperView: View {
    @EnvironmentObject private var database: Database
    
    var body: some View {
        ScrollView {
            TemplateCell(template: database.testTemplate)
                .padding(CELL_PADDING)
                .tileStyle()
        }
    }
}

struct TemplateCell_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapperView()
            .previewEnvironmentObjects()
    }
}
