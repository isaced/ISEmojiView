ISEmojiView
===========

Emoji Keyboard for iOS

![screenshot](https://raw.github.com/isaced/ISEmojiView/master/screenshot.jpg)

##Useage

###import

```
#import "ISEmojiView.h"
```

###Init
```
// init ISEmojiView
ISEmojiView *emojiView = [[ISEmojiView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 216)];
emojiView.delegate = self;
self.textView.inputView = emojiView;
```

###Response

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
##Author

isaced@163.com

##License

MIT