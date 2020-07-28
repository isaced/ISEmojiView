#
# Be sure to run `pod lib lint ISEmojiView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ISEmojiView'
  s.version          = '0.2.6'
  s.summary          = 'Emoji Keyboard for iOS.'
  s.description      = <<-DESC
An easy to use Emoji keyboard for iOS.
  DESC

  s.homepage         = 'https://github.com/isaced/ISEmojiView'
  s.screenshots      = 'https://github.com/isaced/ISEmojiView/raw/master/screenshot1.png'
  s.license          = { type: 'MIT', file: 'LICENSE' }
  s.author           = { 'isaced' => 'isaced@163.com' }
  s.source           = { git: 'https://github.com/isaced/ISEmojiView.git', tag: '0.2.6' }
  s.swift_version    = '5'

  s.ios.deployment_target = '8.0'

  s.source_files = 'Source/Classes/**/*'

  s.resource_bundles = {
    'ISEmojiView' => ['Source/Assets/**/*']
  }
end
