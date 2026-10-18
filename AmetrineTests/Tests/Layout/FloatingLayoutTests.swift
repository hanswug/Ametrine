//
//  FloatingLayoutTests.swift
//  AmetrineTests
//
//  Created by Ian Ynda-Hummel on 9/21/19.
//  Copyright © 2019 Ian Ynda-Hummel. All rights reserved.
//

@testable import Ametrine
import Nimble
import Quick
import Silica

class FloatingLayoutTests: QuickSpec {
    override func spec() {
        afterEach {
            TestScreen.availableScreens = []
        }

        describe("layout") {
            it("generates no assignments") {
                let screen = TestScreen(frame: CGRect(origin: .zero, size: CGSize(width: 2000, height: 1000)))
                TestScreen.availableScreens = [screen]

                let windows = [
                    TestWindow(element: nil)!,
                    TestWindow(element: nil)!,
                    TestWindow(element: nil)!,
                    TestWindow(element: nil)!
                ]
                let windowSet = WindowSet.tiled(windows)
                let layout = FloatingLayout<TestWindow>()

                expect(layout.frameAssignments(windowSet, on: screen)).to(beNil())
            }
        }

        describe("coding") {
            it("encodes and decodes") {
                let layout = FloatingLayout<TestWindow>()
                let encodedLayout = try! JSONEncoder().encode(layout)
                expect {
                    try JSONDecoder().decode(FloatingLayout<TestWindow>.self, from: encodedLayout)
                }.toNot(throwError())
            }
        }
    }
}
