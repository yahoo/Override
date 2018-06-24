// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

import Quick
import Nimble
import OverrideTestSupport

class TestHelpersSpec: QuickSpec {

    override func spec() {
        let features = MyFeatures(withFeatureStore: nil)

        describe("features") {

            it("test helpers work") {
                withFeature(features.aRemoteFeature).enabled {
                    expect(features.aRemoteFeature.enabled).to(beTrue())
                }

                withFeature(features.aRemoteFeature).disabled {
                    expect(features.articlePreviews.enabled).to(beFalse())
                }

                withFeatures([features.aRemoteFeature, features.articlePreviews]).enabled {
                    expect(features.aRemoteFeature.enabled).to(beTrue())
                    expect(features.articlePreviews.enabled).to(beTrue())
                }

                withFeatures([features.aRemoteFeature, features.articlePreviews]).disabled {
                    expect(features.aRemoteFeature.enabled).to(beFalse())
                    expect(features.articlePreviews.enabled).to(beFalse())
                }
            }
        }
    }
}
