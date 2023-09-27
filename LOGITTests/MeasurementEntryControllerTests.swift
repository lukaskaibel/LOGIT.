//
//  MeasurementEntryControllerTests.swift
//  LOGITTests
//
//  Created by Lukas Kaibel on 20.09.23.
//

import XCTest
@testable import LOGIT

final class MeasurementEntryControllerTests: XCTestCase {

    private let controller = MeasurementEntryController.preview
    private let database = Database.preview
    
    func testAddMeasurementEntry() throws {
        controller.addMeasurementEntry(ofType: .weight, value: 85, onDate: .now)
        controller.addMeasurementEntry(ofType: .length(.chest), value: 50, onDate: .now)
        
        let measurements = database.fetch(MeasurementEntry.self) as! [MeasurementEntry]
        XCTAssertTrue(measurements.count == 2, "Expected 2 measurements")
        let values = measurements.map { $0.value }
        XCTAssertTrue(values.contains { $0 == 50 }, "Expected measurement with 50 as value")
        let types = measurements.map { $0.type }
        XCTAssertTrue(types.contains { $0 == MeasurementEntryType.length(.chest) })
    }
    
    func testGetMeasurementEntries() throws {
        // 1. Setup test data
        controller.addMeasurementEntry(ofType: .weight, value: 85, onDate: .now)
        controller.addMeasurementEntry(ofType: .length(.chest), value: 50, onDate: .now)
        controller.addMeasurementEntry(ofType: .length(.neck), value: 45, onDate: .now)
        
        // 2. Retrieve measurement entries
        let weightEntries = controller.getMeasurementEntries(ofType: .weight)
        let chestEntries = controller.getMeasurementEntries(ofType: .length(.chest))
        let neckEntries = controller.getMeasurementEntries(ofType: .length(.neck))
        
        // 3. Assert results
        
        // 3.1 Assert the counts
        XCTAssertTrue(weightEntries.count == 1, "Expected 1 weight entry")
        XCTAssertTrue(chestEntries.count == 1, "Expected 1 chest entry")
        XCTAssertTrue(neckEntries.count == 1, "Expected 1 neck entry")
        
        // 3.2 Assert the values for each type
        XCTAssertEqual(weightEntries.first?.value, 85, "Expected weight entry value to be 85")
        XCTAssertEqual(chestEntries.first?.value, 50, "Expected chest entry value to be 50")
        XCTAssertEqual(neckEntries.first?.value, 45, "Expected neck entry value to be 45")
    }


}