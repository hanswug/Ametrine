//
//  RestoredWindowOrderTests.swift
//  AmetrineTests
//

@testable import Ametrine
import Foundation
import Nimble
import Quick
import Silica

class RestoredWindowOrderTests: QuickSpec {
    override func spec() {
        describe("one window taking another's place") {
            it("gives a new tab the place of the tab it hides, which leaves the order") {
                // The new tab was already tracked at the end: it moves into the old tab's place.
                expect(TrackingOrder.replacing("old", with: "new", in: ["a", "old", "b", "new"])).to(equal(["a", "new", "b"]))
                expect(TrackingOrder.replacing("old", with: "new", in: ["new", "a", "old"])).to(equal(["a", "new"]))
            }

            it("puts a window that wasn't tracked yet in the place") {
                expect(TrackingOrder.replacing("old", with: "new", in: ["a", "old", "b"])).to(equal(["a", "new", "b"]))
            }

            it("does nothing when the window to replace isn't tracked") {
                expect(TrackingOrder.replacing("old", with: "new", in: ["a", "new"])).to(beNil())
            }

            it("keeps a window that takes its own place") {
                expect(TrackingOrder.replacing("a", with: "a", in: ["a", "b"])).to(equal(["a", "b"]))
            }
        }

        describe("which tab gives way to a tab that came to the front") {
            func givesWay(wasActive: Bool = true, onScreen: Bool, invalid: Bool = false, standard: Bool = true, recentFocus: Bool = false) -> Bool {
                return TabCandidate.givesWay(wasActive: wasActive, isOnScreen: onScreen, isInvalid: invalid, isStandard: standard, recentFocusChange: recentFocus)
            }

            it("is a tab hidden behind the new one") {
                expect(givesWay(onScreen: false)).to(beTrue())
            }

            it("is a closing tab still on screen, which has lost its standard subrole") {
                // Ghostty, 2026-10-26: the tab behind is announced ~5 ms before the closing tab leaves the screen.
                expect(givesWay(onScreen: true, standard: false)).to(beTrue())
                expect(givesWay(onScreen: true, standard: false, recentFocus: true)).to(beTrue())
            }

            it("is a tab whose window is gone") {
                expect(givesWay(wasActive: false, onScreen: true, invalid: true)).to(beTrue())
            }

            it("isn't a tab still on screen") {
                expect(givesWay(onScreen: true)).to(beFalse())
            }

            it("isn't a window that was never active") {
                expect(givesWay(wasActive: false, onScreen: false)).to(beFalse())
                expect(givesWay(wasActive: false, onScreen: false, standard: false)).to(beFalse())
            }

            it("isn't a window off screen right after a focus change") {
                expect(givesWay(onScreen: false, recentFocus: true)).to(beFalse())
            }
        }

        /// Adds windows the way `Windows.add` does: saved ones by their saved place, the rest at the end.
        func arrive(_ arrivals: [String], savedOrder: [String]) -> (windows: [String], order: RestoredWindowOrder<String>) {
            var order = RestoredWindowOrder(savedOrder)
            var windows: [String] = []
            for window in arrivals {
                if let index = order.insertionIndex(for: window, among: windows) {
                    windows.insert(window, at: index)
                    order.arrived(window)
                } else {
                    windows.append(window)
                }
            }
            return (windows, order)
        }

        it("puts windows back in their saved order, whatever order they arrive in") {
            let saved = ["main", "second", "third", "fourth"]
            expect(arrive(["third", "main", "fourth", "second"], savedOrder: saved).windows).to(equal(saved))
            expect(arrive(["fourth", "third", "second", "main"], savedOrder: saved).windows).to(equal(saved))
        }

        it("keeps windows that weren't saved after the saved ones, in arrival order") {
            let result = arrive(["new1", "second", "new2", "main"], savedOrder: ["main", "second"])
            expect(result.windows).to(equal(["main", "second", "new1", "new2"]))
        }

        it("is done once every saved window has arrived") {
            expect(arrive(["second"], savedOrder: ["main", "second"]).order.isDone).to(beFalse())
            expect(arrive(["second", "main"], savedOrder: ["main", "second"]).order.isDone).to(beTrue())
        }

        it("places a saved window only once") {
            var order = RestoredWindowOrder(["main", "second"])
            expect(order.insertionIndex(for: "main", among: [])).to(equal(0))
            order.arrived("main")
            expect(order.insertionIndex(for: "main", among: ["main"])).to(beNil())
        }

        it("saves windows as pid and window number") {
            let saved = [SavedWindowID(pid: 501, windowID: 8670), SavedWindowID(pid: 777, windowID: 9324)]
            let data = try! JSONEncoder().encode(saved)
            expect(try! JSONDecoder().decode([SavedWindowID].self, from: data)).to(equal(saved))
            expect(String(data: data, encoding: .utf8)).to(contain("\"windowID\":8670"))
        }
    }
}

class PendingLastMainWindowsTests: QuickSpec {
    override func spec() {
        it("hands a saved window's Spaces back once") {
            var pending = PendingLastMainWindows<String>([1: "safari", 2: "kaku", 3: "safari"])

            expect(pending.takeSpaces(for: "safari").sorted()).to(equal([1, 3]))
            expect(pending.takeSpaces(for: "safari")).to(beEmpty())
            expect(pending.isEmpty).to(beFalse())
            expect(pending.takeSpaces(for: "kaku")).to(equal([2]))
            expect(pending.isEmpty).to(beTrue())
        }

        it("ignores windows that weren't saved") {
            var pending = PendingLastMainWindows<String>([1: "safari"])
            expect(pending.takeSpaces(for: "claude")).to(beEmpty())
            expect(pending.isEmpty).to(beFalse())
        }

        it("saves Spaces as string keys and reads them back") {
            let saved = ["7": SavedWindowID(pid: 55183, windowID: 7569)]
            let data = try! JSONEncoder().encode(saved)
            let decoded = try! JSONDecoder().decode([String: SavedWindowID].self, from: data)
            expect(decoded).to(equal(saved))
            expect(decoded.keys.compactMap { CGSSpaceID($0) }).to(equal([7]))
        }
    }
}
