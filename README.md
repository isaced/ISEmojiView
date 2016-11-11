# ISEmojiView [![Version](https://img.shields.io/cocoapods/v/ISEmojiView.svg?style=flat)](http://cocoapods.org/pods/ISEmojiView) [![License](https://img.shields.io/cocoapods/l/ISEmojiView.svg?style=flat)](http://cocoapods.org/pods/ISEmojiView) [![Platform](https://img.shields.io/cocoapods/p/ISEmojiView.svg?style=flat)](http://cocoapods.org/pods/ISEmojiView)

An easy to use Emoji keyboard for iOS.

Has been rewritten with swift, the old *Objective-C* version on branch [oc](https://github.com/isaced/ISEmojiView/tree/oc).

<img src="https://raw.github.com/isaced/ISEmojiView/master/screenshot.jpg" alt="screenshot" width="375" height="667">

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- Swift3
- iOS8+
- Xcode8

## Useage

### Installation

#### Cocoapods

```ruby
# Swift
pod 'ISEmojiView'

# Objective-C
pod 'ISEmojiView', '0.0.1'
```

#### Carthage

```
github "isaced/ISEmojiView"
```

### Import

```
import ISEmojiView
```

### Initialization

```
let emojiView = ISEmojiView()
emojiView.delegate = self
textView.inputView = emojiView
```
### Delegate

<ISEmojiViewDelegate>

```
func emojiViewDidSelectEmoji(emojiView: ISEmojiView, emoji: String) {
    textView.text = textView.text.appending(emoji)
}
    
func emojiViewDidPressDeleteButton(emojiView: ISEmojiView) {
    if let currentText = textView.text {
        textView.text = currentText.substring(to: currentText.index(before: currentText.endIndex))
    }
}
```

### Customize

```
// long press to pop preview effect like iOS10 system emoji keyboard, Default is true
public var isShowPopPreview = true
```

## License

MIT
