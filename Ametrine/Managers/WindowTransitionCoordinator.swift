//
//  WindowTransitionCoordinator.swift
//  Ametrine
//
//  Created by Ian Ynda-Hummel on 3/24/19.
//  Copyright © 2019 Ian Ynda-Hummel. All rights reserved.
//

import Cocoa
import Foundation
import Silica

enum WindowTransition<Window: WindowType> {
    typealias Screen = Window.Screen
    case switchWindows(_ window1: Window, _ window2: Window)
    case resetFocus
    case warpWindow(_ window: Window, direction: Direction)
    case warpWindowToMain(_ window: Window)
}

protocol WindowTransitionTarget: AnyObject {
    associatedtype Application: ApplicationType
    typealias Window = Application.Window
    typealias Screen = Window.Screen

    func executeTransition(_ transition: WindowTransition<Window>)

    func isWindowFloating(_ window: Window) -> Bool
    func currentLayout() -> Layout<Application.Window>?
    func activeWindows(on screen: Screen) -> [Window]
    func lastMainWindowForCurrentSpace() -> Window?
    func directionalNeighbor(of window: Window, toward direction: Direction) -> Window?
    func assignedFrame(of window: Window) -> CGRect?
    func isFullscreenLayout(on screen: Screen) -> Bool
}

class WindowTransitionCoordinator<Target: WindowTransitionTarget> {
    typealias Window = Target.Window
    typealias Screen = Window.Screen

    weak var target: Target?

    init() {}

    func swapFocusedWindowToMain() {
        guard let focusedWindow = Window.currentlyFocused(), target?.isWindowFloating(focusedWindow) == false, let screen = focusedWindow.screen() else {
            return
        }

        guard let windows = target?.activeWindows(on: screen), let focusedIndex = windows.firstIndex(of: focusedWindow) else {
            return
        }

        if windows.count <= 1 {
            return
        }

        if focusedIndex == 0 {
            guard let lastMainWindow = target?.lastMainWindowForCurrentSpace() else {
                return
            }
            target?.executeTransition(.switchWindows(lastMainWindow, focusedWindow))
            return
        }

        if focusedIndex != 0 {
            // Swap focused window with main window if other window is focused
            target?.executeTransition(.switchWindows(focusedWindow, windows[0]))
        }
    }

    func swapFocusedWindowCounterClockwise() {
        guard let focusedWindow = Window.currentlyFocused(), target?.isWindowFloating(focusedWindow) == false else {
            target?.executeTransition(.resetFocus)
            return
        }

        guard let screen = focusedWindow.screen() else {
            return
        }

        guard let windows = target?.activeWindows(on: screen), let focusedWindowIndex = windows.firstIndex(of: focusedWindow) else {
            return
        }

        let windowToSwapWith = windows[(focusedWindowIndex == 0 ? windows.count - 1 : focusedWindowIndex - 1)]

        target?.executeTransition(.switchWindows(focusedWindow, windowToSwapWith))
    }

    func swapFocusedWindowClockwise() {
        guard let focusedWindow = Window.currentlyFocused(), target?.isWindowFloating(focusedWindow) == false else {
            target?.executeTransition(.resetFocus)
            return
        }

        guard let screen = focusedWindow.screen() else {
            return
        }

        guard let windows = target?.activeWindows(on: screen), let focusedWindowIndex = windows.firstIndex(of: focusedWindow) else {
            return
        }

        let windowToSwapWith = windows[(focusedWindowIndex + 1) % windows.count]

        target?.executeTransition(.switchWindows(focusedWindow, windowToSwapWith))
    }

    /// Swaps the focused window with the window in that direction; does nothing in Fullscreen or from a floating window.
    func swapFocusedWindow(_ direction: Direction) {
        guard let focusedWindow = Window.currentlyFocused(), target?.isWindowFloating(focusedWindow) == false, let screen = focusedWindow.screen() else {
            return
        }

        guard target?.isFullscreenLayout(on: screen) == false, let otherWindow = target?.directionalNeighbor(of: focusedWindow, toward: direction) else {
            return
        }

        let destination = target?.assignedFrame(of: otherWindow)
        target?.executeTransition(.switchWindows(focusedWindow, otherWindow))

        // The focused window takes the other window's tile; the cursor goes with it.
        if let destination, UserConfiguration.shared.mouseFollowsFocus() {
            Cursor.move(to: CGPoint(x: destination.midX, y: destination.midY))
        }
    }

    /// Warps the focused window toward `direction` (handover §5.5); does nothing in Fullscreen or from a floating window.
    func warpFocusedWindow(_ direction: Direction) {
        guard let focusedWindow = Window.currentlyFocused(), target?.isWindowFloating(focusedWindow) == false, let screen = focusedWindow.screen() else {
            return
        }

        guard target?.isFullscreenLayout(on: screen) == false else {
            return
        }

        target?.executeTransition(.warpWindow(focusedWindow, direction: direction))
    }

    /// Warps the focused window into main (`warp-main`); does nothing in Fullscreen or from a floating window.
    func warpFocusedWindowToMain() {
        guard let focusedWindow = Window.currentlyFocused(), target?.isWindowFloating(focusedWindow) == false, let screen = focusedWindow.screen() else {
            return
        }

        guard target?.isFullscreenLayout(on: screen) == false else {
            return
        }

        target?.executeTransition(.warpWindowToMain(focusedWindow))
    }
}
