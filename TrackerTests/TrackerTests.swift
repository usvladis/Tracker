//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Владислав Усачев on 27.06.2024.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    func testViewController() {
        let vc = TrackerViewController()
        assertSnapshot(matching: vc, as: .image)
    }
}
