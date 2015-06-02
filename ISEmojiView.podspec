Pod::Spec.new do |s|
  s.name         = "ISEmojiView"
  s.version      = "0.0.1"
  s.summary      = "Emoji Keyboard for iOS."

  s.description  = <<-DESC
                   Emoji Keyboard for iOS.
                   DESC

  s.homepage     = "https://github.com/isaced/ISEmojiView"
  s.screenshots  = "https://raw.githubusercontent.com/isaced/ISEmojiView/master/screenshot.jpg"

  s.license      = "MIT"
  s.author       = { "isaced" => "isaced@163.com" }
  s.platform     = :ios

  s.source       = { :git => "https://github.com/isaced/ISEmojiView.git", :tag => "0.0.1" }
  s.source_files  = "ISEmojiView", "ISEmojiView/**/*.{h,m}"
  s.resource  = "ISEmojiView/ISEmojiList.plist"

  s.requires_arc = true
end
