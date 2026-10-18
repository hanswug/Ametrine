//
//  CGInfo.swift
//  Ametrine
//
//  Created by Ian Ynda-Hummel on 3/29/19.
//  Copyright © 2019 Ian Ynda-Hummel. All rights reserved.
//

import Foundation
import Silica
import SwiftyJSON

/// Windows info as taken from the underlying system.
struct CGWindowsInfo<Window: WindowType> {
    /// An array of dictionaries of window information
    let descriptions: [[String: AnyObject]]

    /**
     - Parameters:
     - options: Any options for getting info.
     - windowID: ID of window to find windows relative to. 0 gets all windows.
     */
    init?(options: CGWindowListOption, windowID: CGWindowID) {
        guard let cfWindowDescriptions = CGWindowListCopyWindowInfo(options, windowID) else {
            return nil
        }

        guard let windowDescriptions = cfWindowDescriptions as? [[String: AnyObject]] else {
            return nil
        }

        self.descriptions = windowDescriptions
    }

    /**
     - Returns:
     The set of windows that are currently active.
     */
    func activeIDs() -> Set<CGWindowID> {
        var ids: Set<CGWindowID> = Set()

        for windowDescription in descriptions {
            guard let windowID = windowDescription[kCGWindowNumber as String] as? NSNumber else {
                continue
            }

            ids.insert(CGWindowID(windowID.uint64Value))
        }

        return ids
    }

    static func windowIDsArray(_ window: Window) -> NSArray {
        return [NSNumber(value: window.cgID() as UInt32)] as NSArray
    }

    static func windowSpace(_ window: Window) -> Int? {
        let windowIDsArray = CGWindowsInfo.windowIDsArray(window)

        guard let cfSpaces = CGSCopySpacesForWindows(CGSMainConnectionID(), kCGSAllSpacesMask, windowIDsArray)?.takeRetainedValue() else {
            return nil
        }

        guard let spaces = cfSpaces as NSArray as? [NSNumber] else {
            return nil
        }

        guard !spaces.isEmpty else {
            return nil
        }

        return spaces.first?.intValue
    }
}

struct CGScreensInfo<Window: WindowType> {
    typealias Screen = Window.Screen

    let descriptions: [JSON]

    init?() {
        guard let descriptions = Screen.screenDescriptions() else {
            return nil
        }

        self.descriptions = descriptions
    }

    func space(at index: Int) -> Space {
        return CGSpacesInfo<Window>.space(fromScreenDescription: descriptions[index])
    }
}

struct CGSpacesInfo<Window: WindowType> {
    typealias Screen = Window.Screen

    static func currentSpaceForScreen(_ screen: Screen) -> Space? {
        guard let screenDescriptions = Screen.screenDescriptions(), let screenID = screen.screenID() else {
            return nil
        }

        guard screenDescriptions.count > 0 else {
            return nil
        }

        if Screen.screensHaveSeparateSpaces {
            for screenDescription in screenDescriptions {
                guard screenDescription["Display Identifier"].string == screenID else {
                    continue
                }

                return space(fromScreenDescription: screenDescription)
            }
        } else {
            return space(fromScreenDescription: screenDescriptions[0])
        }

        return nil
    }

    static func currentFocusedSpace() -> Space? {
        guard let focusedWindow = Window.currentlyFocused(), let screen = focusedWindow.screen() else {
            return nil
        }

        return currentSpaceForScreen(screen)
    }

    static func space(fromScreenDescription screenDictionary: JSON) -> Space {
        return space(fromSpaceDescription: screenDictionary["Current Space"])
    }

    static func space(fromSpaceDescription spaceDictionary: JSON) -> Space {
        let id: CGSSpaceID = spaceDictionary["ManagedSpaceID"].intValue
        let type = CGSSpaceType(rawValue: spaceDictionary["type"].uInt32Value)
        let uuid = spaceDictionary["uuid"].stringValue
        return Space(id: id, type: type, uuid: uuid)
    }
}
