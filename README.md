![logo](https://raw.github.com/isaced/ISEmojiView/master/logo@2x.jpg)
[![Version](https://img.shields.io/cocoapods/v/ISEmojiView.svg?style=flat)](http://cocoapods.org/pods/ISEmojiView) [![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![License](https://img.shields.io/cocoapods/l/ISEmojiView.svg?style=flat)](http://cocoapods.org/pods/ISEmojiView) [![Platform](https://img.shields.io/cocoapods/p/ISEmojiView.svg?style=flat)](http://cocoapods.org/pods/ISEmojiView)  ![Swift](https://img.shields.io/badge/%20in-swift%203.0-orange.svg)

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

```Ruby
# Swift
pod 'ISEmojiView'

# Objective-C
pod 'ISEmojiView', '0.0.1'
```

#### Carthage

```Ruby
github "isaced/ISEmojiView"
```

### Import

```Swift
import ISEmojiView
```

### Initialization

```Swift
let emojiView = ISEmojiView()
emojiView.delegate = self
textView.inputView = emojiView
```

### Delegate

Implement `<ISEmojiViewDelegate>`

```Swift
// callback when tap a emoji on keyboard
func emojiViewDidSelectEmoji(emojiView: ISEmojiView, emoji: String) {
    textView.insertText(emoji)
}

// callback when tap delete button on keyboard
func emojiViewDidPressDeleteButton(emojiView: ISEmojiView) {
    textView.deleteBackward()
}
```

### Customize

#### custom emoji list

You can load emojis from file or other, load them in initialization.

```Swift
let emojiView = ISEmojiView(emojis: [[String]])
```

#### pop animation

```Swift
// long press to pop preview effect like iOS10 system emoji keyboard, Default is true
public var isShowPopPreview = true
```

## Others

If you are looking for a React Native solution, take a look at this [brendan-rius/react-native-emoji-keyboard](https://github.com/brendan-rius/react-native-emoji-keyboard)

## License

MIT
