# ISEmojiView

[![Version](https://img.shields.io/cocoapods/v/ISEmojiView.svg?style=flat)](http://cocoapods.org/pods/ISEmojiView)
[![License](https://img.shields.io/cocoapods/l/ISEmojiView.svg?style=flat)](http://cocoapods.org/pods/ISEmojiView)
[![Platform](https://img.shields.io/cocoapods/p/ISEmojiView.svg?style=flat)](http://cocoapods.org/pods/ISEmojiView)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- Swift3
- iOS7+

## Useage

### Cocoapods

```ruby
pod "ISEmojiView"
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

## License

ISEmojiView is available under the MIT license. See the LICENSE file for more info.
