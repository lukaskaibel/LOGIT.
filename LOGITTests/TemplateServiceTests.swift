//
//  TemplateServiceTests.swift
//  LOGITTests
//
//  Created by Lukas Kaibel on 03.10.23.
//

import XCTest
import OSLog
import Combine
@testable import LOGIT

final class TemplateServiceTests: XCTestCase {
    
    var cancellables = [AnyCancellable]()
    
    func testAthleanXTotalBodyA() throws {
        let image = getImage("athleanx_total_body_A")
        XCTAssertNotNil(image, "Getting test image failed")
        TemplateService().createTemplate(from: image!)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    XCTFail("Failed to create template from image: \(error)")
                }
            }, receiveValue: { template in
                XCTAssertEqual(template.name?.lowercased(), "perfect total body workout a", "Template name not matching photo.")
                XCTAssertEqual(template.setGroups.count, 6, "Number of SetGroups not matching the photo")
                
                XCTAssertTrue(self.templateSetGroupEquals(
                    template.setGroups[0],
                    name: "barbell squats",
                    numberOfSets: [3],
                    repetitions: [5],
                    weight: [0]
                ))
                
                XCTAssertTrue(self.templateSetGroupEquals(
                    template.setGroups[1],
                    name: "barbell hip thrusts",
                    numberOfSets: [3, 4],
                    repetitions: [10, 11, 12],
                    weight: [0]
                ))
                
                XCTAssertTrue(self.templateSetGroupEquals(
                    template.setGroups[3],
                    name: "weighted chin ups",
                    numberOfSets: [3, 4],
                    repetitions: [6, 7, 8, 9, 10],
                    weight: [0]
                ))
                
                XCTAssertTrue(self.templateSetGroupEquals(
                    template.setGroups[3],
                    name: "db farmer's carry",
                    numberOfSets: [3, 4],
                    repetitions: [50],
                    weight: [0]
                ))
            })
            .store(in: &cancellables)
    }
    
    private func getImage(_ name: String) -> UIImage? {
        // Get the URL of the current file
        let currentFileURL = URL(fileURLWithPath: #file)

        // Construct the directory URL (assuming the directory is named "ImagesDirectory")
        let directoryURL = currentFileURL.deletingLastPathComponent().appendingPathComponent("WorkoutImages")

        do {
            // Fetch the content of the directory
            let contents = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: [])
            return contents
                .filter { $0.pathExtension == "jpeg" }
                .filter { $0.path().contains(name) }
                .compactMap { UIImage(contentsOfFile: $0.path) }
                .first
        } catch {
            XCTFail("Error reading image '\(name)' from WorkoutImages: \(error)")
            return nil
        }
    }
    
    private func templateSetGroupEquals(
        _ setGroup: TemplateSetGroup,
        name: String,
        numberOfSets: [Int],
        repetitions: [Int],
        weight: [Int]
    ) -> Bool {
        var result = true
        if setGroup.exercise?.name?.lowercased() != name.lowercased() {
            result = false
            Logger().error("Exercise name '\(setGroup.exercise?.name?.lowercased() ?? "nil")' not equal to '\(name.lowercased())'")
        }
        if !numberOfSets.contains(where: { $0 == setGroup.sets.count }) {
            result = false
            Logger().error("Number of sets '\(setGroup.sets.count)' not equal to '\(numberOfSets)'")
        }
        if !repetitions.contains(where: { $0 == (setGroup.sets.value(at: 0) as? StandardSet)!.repetitions }) {
            result = false
            Logger().error("Repetitions '\((setGroup.sets.value(at: 0) as? StandardSet)!.repetitions)' not equal to '\(repetitions)'")
        }
        if !weight.contains(where: { $0 == (setGroup.sets.value(at: 0) as? StandardSet)!.repetitions }) {
            result = false
            Logger().error("Weight '\((setGroup.sets.value(at: 0) as? StandardSet)!.repetitions)' not equal to '\(weight)'")
        }
        return result
    }

}
