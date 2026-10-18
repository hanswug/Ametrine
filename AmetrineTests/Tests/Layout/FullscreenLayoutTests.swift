//
//  FullscreenLayoutTests.swift
//  AmetrineTests
//
//  Created by Ian Ynda-Hummel on 9/14/19.
//  Copyright © 2019 Ian Ynda-Hummel. All rights reserved.
//

@testable import Ametrine
import Nimble
import Quick
import Silica

class FullscreenLayoutTests: QuickSpec {
    private lazy var operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        return operationQueue
    }()

    override func spec() {
        afterEach {
            TestScreen.availableScreens = []
        }

        describe("layout") {
            it("makes all windows fullscreen") {
                let screen = TestScreen()
                TestScreen.availableScreens = [screen]

                let windows = [TestWindow(element: nil)!, TestWindow(element: nil)!, TestWindow(element: nil)!]
                let windowSet = WindowSet.tiled(windows)
                let layout = FullscreenLayout<TestWindow>()
                let frameAssignments = layout.frameAssignments(windowSet, on: screen)!

                frameAssignments.forEach { assignment in
                    expect(assignment.frameAssignment.frame).to(equal(screen.adjustedFrame()))
                    expect(assignment.frameAssignment.finalFrame).to(equal(screen.adjustedFrame()))
                }
            }

            it("handles non-origin screen") {
                let screen = TestScreen(frame: CGRect(x: 100, y: 100, width: 2000, height: 1000))
                TestScreen.availableScreens = [screen]

                let windows = [TestWindow(element: nil)!, TestWindow(element: nil)!, TestWindow(element: nil)!]
                let windowSet = WindowSet.tiled(windows)
                let layout = FullscreenLayout<TestWindow>()
                let frameAssignments = layout.frameAssignments(windowSet, on: screen)!

                frameAssignments.forEach { assignment in
                    expect(assignment.frameAssignment.frame).to(equal(screen.adjustedFrame()))
                    expect(assignment.frameAssignment.finalFrame).to(equal(screen.adjustedFrame()))
                }
            }
        }

        describe("coding") {
            it("encodes and decodes") {
                let layout = FullscreenLayout<TestWindow>()
                let encodedLayout = try! JSONEncoder().encode(layout)
                expect {
                    try JSONDecoder().decode(FullscreenLayout<TestWindow>.self, from: encodedLayout)
                }.toNot(throwError())
            }
        }
    }
}
