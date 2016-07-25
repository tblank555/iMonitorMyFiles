#
# Be sure to run `pod lib lint iMonitorMyFiles.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'iMonitorMyFiles'
  s.version          = '0.1.0'
  s.summary          = 'Modern implementation of a file monitoring system for iOS.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
    iMonitorMyFiles provides a simple Objective-C interface for responding to file system changes in iOS. If your users can create, modify, and/or delete files in your app's sandbox, this library provides a way to respond to those events. It also insulates you from a low-level C API (yikes!).
                       DESC

  s.homepage         = 'https://github.com/tblank555/iMonitorMyFiles'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Travis Blankenship' => 'travis@sawtoothapps.com' }
  s.source           = { :git => 'https://github.com/tblank555/iMonitorMyFiles.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/tblank555'

  s.ios.deployment_target = '7.0'

  s.source_files = 'iMonitorMyFiles/Classes/TABFileMonitor.{h,m}'

  # s.resource_bundles = {
  #   'iMonitorMyFiles' => ['iMonitorMyFiles/Assets/*.png']
  # }

  s.public_header_files = 'iMonitorMyFiles/Classes/TABFileMonitor.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
