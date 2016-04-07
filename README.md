ISEmojiView [![CocoaPods](https://img.shields.io/cocoapods/v/ISEmojiView.svg?style=flat-square)](http://cocoadocs.org/docsets/ISEmojiView) [![Platform](https://img.shields.io/cocoapods/p/ISEmojiView.svg?style=flat-square)](http://cocoadocs.org/docsets/ISEmojiView) [![GitHub license](https://img.shields.io/github/license/mashape/apistatus.svg?style=flat-square)](http://opensource.org/licenses/MIT)
===========



An easy to use Emoji keyboard for iOS.

![screenshot](https://raw.github.com/isaced/ISEmojiView/master/screenshot.jpg)

## Install

### CocoaPods

```
pod 'ISEmojiView'
```

## Useage

### Init
```
// init ISEmojiView
ISEmojiView *emojiView = [[ISEmojiView alloc] initWithTextField:textView delegate:self popAnimationEnable:YES];
textView.inputView = emojiView;
```

### Response

add protocol `ISEmojiViewDelegate` and implementation `emojiView:didSelectEmoji:` method

```
-(void)emojiView:(ISEmojiView *)emojiView didSelectEmoji:(NSString *)emoji{
    self.textView.text = [self.textView.text stringByAppendingString:emoji];
}
```
and `emojiView:didPressDeleteButton:` method:

```
-(void)emojiView:(ISEmojiView *)emojiView didPressDeleteButton:(UIButton *)deletebutton{
    if (self.textView.text.length > 0) {
        NSRange lastRange = [self.textView.text rangeOfComposedCharacterSequenceAtIndex:self.textView.text.length-1];
        self.textView.text = [self.textView.text substringToIndex:lastRange.location];
    }
}
```

##License

MIT
