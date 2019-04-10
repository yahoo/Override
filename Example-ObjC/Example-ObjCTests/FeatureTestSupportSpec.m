// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

#import "Example_ObjC-Swift.h"

#import <Expecta/Expecta.h>
#import <Specta/Specta.h>
#import <YMOverrideTestSupport/OverrideTestSupport-Swift.h>
#import <YMOverrideTestSupport/FeatureTestSupport.h>

SpecBegin(FeatureTestSupport)
describe(@"Feature Test Support", ^{
    describe(@"withFeature", ^{
        it(@"enables/disables the passed in feature within the block", ^{
            MyFeatures *features = [[MyFeatures alloc] initWithFeatureStore:nil];
            withFeature(features.articlePreviews).enabled(^{
                expect(features.articlePreviews.enabled).to.beTruthy();
            });
            withFeature(features.articlePreviews).disabled(^{
                expect(features.articlePreviews.enabled).to.beFalsy();
            });
        });
    });
    describe(@"withFeatures", ^{
        it(@"enables/disables multiple passed in features within the block", ^{
            MyFeatures *features = [[MyFeatures alloc] initWithFeatureStore:nil];
            NSArray *list = @[features.articlePreviews, features.aRemoteFeature];
            withFeatures(list).enabled(^{
                expect(features.articlePreviews.enabled).to.beTruthy();
                expect(features.aRemoteFeature.enabled).to.beTruthy();
            });
            withFeatures(list).disabled(^{
                expect(features.articlePreviews.enabled).to.beFalsy();
                expect(features.aRemoteFeature.enabled).to.beFalsy();
            });
        });
    });
});
SpecEnd
