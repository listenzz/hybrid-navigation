require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = "NavigationHybrid"
  s.version      = package['version']
  s.summary      = "A native navigation for React Native which support navigation between native and react side"

  s.authors      = { "listen" => "listenzz@163.com" }
  s.homepage     = "https://github.com/listenzz/react-native-navigation-hybrid"
  s.license      = package['license']
  s.platform     = :ios, "8.0"

  s.module_name  = 'NavigationHybrid'

  s.source       = { :git => "https://github.com/listenzz/react-native-navigation-hybrid.git", :tag => "v#{s.version}" }
  s.source_files  = "ios/NavigationHybrid/*.{h,m,swift}"

  s.dependency 'React'
  s.frameworks = 'UIKit'
end
