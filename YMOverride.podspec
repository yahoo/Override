#
# Be sure to run `pod lib lint Override.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'YMOverride'
    s.version          = '2.2.0'
    s.summary          = 'Simple Swift Feature Flag Managment, From Yahoo'
    s.description      = <<-DESC
    Override helps minimize the boilerplate involved with adding and maintaining feature flags.
    Typically app developers employ feature flags to manage access to feature which are still in
    development, experimental, or behind an A/B test.

    Feature flags typically have 3 states: on, off, or defaulted. The default state of a feature
    may be a preset mode or defined by a remote configuration or A/B testing system. Override
    supports these use cases.
    DESC

    s.homepage         = 'https://github.com/Yahoo/Override'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Adam Kaplan' => 'adamkaplan@verizonmedia.com', 'David Grandinetti' => 'dbgrandi@verizonmedia.com' }
    s.source           = { :git => 'https://github.com/yahoo/Override.git', :tag => s.version.to_s }

    s.ios.deployment_target = '10.0'
    s.tvos.deployment_target = '10.0'

    s.swift_version = '4.0'
    s.default_subspecs = 'Features'

    s.subspec 'Features' do |fe|
        fe.frameworks = 'Foundation'
        fe.source_files = [
          'Source/*.swift',
          'Source/UI/*.{swift,h}',
          'Source/UI/**/*.{swift,h}'
        ]
    end
end
