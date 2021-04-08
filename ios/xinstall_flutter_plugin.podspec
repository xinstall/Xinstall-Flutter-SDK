#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint xinstall_flutter_plugin.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'xinstall_flutter_plugin'
  s.version          = '0.0.8'
  s.summary          = 'Xinstall Flutter plugin.'
  s.description      = <<-DESC
  Xinstall Flutter plugin example.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
#  s.dependency 'XinstallSDK'
  s.vendored_libraries = 'Classes/**/libXinstallSDK.a'

  s.ios.deployment_target = '9.0'

end
