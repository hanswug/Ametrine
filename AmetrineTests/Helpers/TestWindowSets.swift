//
//  TestWindowSets.swift
//  AmetrineTests
//

@testable import Ametrine
import Foundation

extension WindowSet where Window == TestWindow {
    /// The windows in order, every one active, tiled and unfocused: the usual layout-test setup.
    static func tiled(_ windows: [TestWindow]) -> WindowSet<TestWindow> {
        return tiled(windows.map { LayoutWindow(id: $0.id(), frame: $0.frame(), isFocused: false) }, from: windows)
    }

    /// These layout windows, every one active and tiled; `windows` resolves their IDs.
    static func tiled(_ layoutWindows: [LayoutWindow<TestWindow>], from windows: [TestWindow]) -> WindowSet<TestWindow> {
        return WindowSet(
            windows: layoutWindows,
            isWindowWithIDActive: { _ in true },
            isWindowWithIDFloating: { _ in false },
            windowForID: { id in windows.first { $0.id() == id } }
        )
    }
}
