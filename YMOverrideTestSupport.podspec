#
# Be sure to run `pod lib lint Override.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'YMOverrideTestSupport'
    s.version          = '2.4.0'
    s.summary          = 'Test support helpers for YMOverride feature management'
    s.description      = <<-DESC
    This pod provides test support facilities for the Override pod.
    DESC

    s.homepage         = 'https://github.com/Yahoo/Override'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Adam Kaplan' => 'adamkaplan@verizonmedia.com', 'David Grandinetti' => 'dbgrandi@verizonmedia.com' }
    s.source           = { :git => 'https://github.com/yahoo/Override.git', :tag => s.version.to_s }

    s.ios.deployment_target = '10.0'
    s.tvos.deployment_target = '10.0'

    s.swift_versions = ['4.0', '4.2', '5.0']

    s.source_files = 'Source/TestSupport/*.{swift,h}'

    # Require the version of OverrideTestSupport to match the version of Override
    s.dependency 'YMOverride', '=' + s.version.to_s
end
