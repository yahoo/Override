// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

#ifndef FeatureTestSupport_h
#define FeatureTestSupport_h

#define withFeature(FEATURE) [[FeatureTestSupport alloc] init:@[FEATURE]]

#define withFeatures(FEATURE_LIST) [[FeatureTestSupport alloc] init:FEATURE_LIST]

#endif /* FeatureTestSupport_h */
