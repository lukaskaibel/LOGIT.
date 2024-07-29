//
//  Database+EntityFetching.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 02.11.22.
//

import Foundation

extension Database {

    // MARK: - Exercise Fetch

    func getExercises(
        withNameIncluding filterText: String = "",
        for muscleGroup: MuscleGroup? = nil
    ) -> [Exercise] {
        (fetch(
            Exercise.self,
            sortingKey: "name",
            ascending: true,
            predicate: filterText.isEmpty
                ? nil
                : NSPredicate(
                    format: "name CONTAINS[c] %@",
                    filterText
                )
        ) as! [Exercise])
        .filter { muscleGroup == nil || $0.muscleGroup == muscleGroup }
    }

    func getGroupedExercises(
        withNameIncluding filterText: String = "",
        for muscleGroup: MuscleGroup? = nil
    ) -> [[Exercise]] {
        var result = [[Exercise]]()
        for exercise in getExercises(withNameIncluding: filterText, for: muscleGroup) {
            if let lastExerciseNameFirstLetter = result.last?.last?.name?.first,
                let exerciseFirstLetter = exercise.name?.first,
                lastExerciseNameFirstLetter == exerciseFirstLetter
            {
                result[result.count - 1].append(exercise)
            } else {
                result.append([exercise])
            }
        }
        return result
    }

    // MARK: - Template Fetch

    enum TemplateSortingKey {
        case lastUsed, name
    }

    func getTemplates(
        withNameIncluding filterText: String = "",
        sortedBy sortingKey: TemplateSortingKey = .name,
        usingMuscleGroup muscleGroup: MuscleGroup? = nil
    ) -> [Template] {
        (fetch(
            Template.self,
            sortingKey: "creationDate",
            ascending: false,
            predicate: filterText.isEmpty
                ? nil
                : NSPredicate(
                    format: "name CONTAINS[c] %@",
                    filterText
                )
        ) as! [Template])
        .sorted {
            switch sortingKey {
            case .name: return $0.name ?? "" < $1.name ?? ""
            case .lastUsed: return $0.lastUsed ?? .now > $1.lastUsed ?? .now
            }
        }
        .filter {
            muscleGroup == nil || ($0.exercises.map { $0.muscleGroup }).contains(muscleGroup)
        }
    }

    func getGroupedTemplates(
        withNameIncluding filteredText: String = "",
        groupedBy sortingKey: TemplateSortingKey = .name,
        usingMuscleGroup muscleGroup: MuscleGroup? = nil
    ) -> [[Template]] {
        var result = [[Template]]()
        getTemplates(
            withNameIncluding: filteredText,
            sortedBy: sortingKey,
            usingMuscleGroup: muscleGroup
        )
        .forEach { template in
            switch sortingKey {
            case .name:
                if let firstLetterOfLastTemplateName = result.last?.last?.name?.first,
                    let templateFirstLetter = template.name?.first,
                    firstLetterOfLastTemplateName == templateFirstLetter
                {
                    result[result.count - 1].append(template)
                } else {
                    result.append([template])
                }
            case .lastUsed:
                if let lastLastUsed = result.last?.last?.lastUsed,
                    let templateLastUsed = template.lastUsed,
                    Calendar.current.isDate(
                        templateLastUsed,
                        equalTo: lastLastUsed,
                        toGranularity: .month
                    )
                {
                    result[result.count - 1].append(template)
                } else if !result.isEmpty && result.last?.last?.lastUsed == nil
                    && template.lastUsed == nil
                {
                    result[result.count - 1].append(template)
                } else {
                    result.append([template])
                }
            }
        }
        return result
    }

}
