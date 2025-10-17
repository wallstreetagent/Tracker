//
//  TrackersViewControllerSnapshotTests.swift
//  Tracker
//
//  Created by Yanye Velikanova on 10/1/25.
//


import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackersViewControllerSnapshotTests: XCTestCase {
    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func testTrackersMain_Light_iPhone13() {
        let provider = StubTrackersProvider()
        let stack = CoreDataStack(modelName: "TrackerModel")
        let vc = TrackersViewController(coreDataStack: stack, provider: provider)
        let nav = UINavigationController(rootViewController: vc)
        nav.overrideUserInterfaceStyle = .light
        _ = nav.view
        assertSnapshot(matching: nav, as: .image(on: .iPhone13(.portrait)))
    }
}
