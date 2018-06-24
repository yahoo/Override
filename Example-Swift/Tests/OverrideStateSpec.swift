// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

import Quick
import Nimble
@testable import Override
import OverrideTestSupport

class OverrideStateSpec: QuickSpec {
    override func spec() {

        describe("override state enum") {
            it("has correct description") {
                expect(OverrideState.featureDefault.description).to(equal("Default"))
                expect(OverrideState.disabled.description).to(equal("OFF"))
                expect(OverrideState.enabled.description).to(equal("ON"))
            }

            it("inits from raw value") {
                expect(OverrideState(rawValue: 0)).to(equal(OverrideState.featureDefault))
                expect(OverrideState(rawValue: 1)).to(equal(OverrideState.disabled))
                expect(OverrideState(rawValue: 2)).to(equal(OverrideState.enabled))
            }

            it("creates from string") {
                expect(OverrideState.fromString("Default")).to(equal(OverrideState.featureDefault))
                expect(OverrideState.fromString("AnythingElse")).to(equal(OverrideState.featureDefault))

                expect(OverrideState.fromString("OFF")).to(equal(OverrideState.disabled))
                expect(OverrideState.fromString("ON")).to(equal(OverrideState.enabled))
            }
        }

    }
}
