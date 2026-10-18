//
//  CachedPIDTests.swift
//  AmetrineTests
//

@testable import Ametrine
import Foundation
import Nimble
import Quick

class CachedPIDTests: QuickSpec {
    override func spec() {
        describe("CachedPID") {
            it("is empty until a pid is stored") {
                expect(CachedPID().value).to(beNil())
            }

            it("keeps the stored pid") {
                let cached = CachedPID()
                cached.store(42)
                expect(cached.value).to(equal(42))
            }

            it("holds one of the stored pids when threads race") {
                let cached = CachedPID()
                DispatchQueue.concurrentPerform(iterations: 1000) { index in
                    cached.store(pid_t(index))
                    _ = cached.value
                }
                expect(cached.value).to(beGreaterThanOrEqualTo(0))
                expect(cached.value).to(beLessThan(1000))
            }
        }
    }
}
