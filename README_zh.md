![logo](/logo@2x.jpg)
[![Version](https://img.shields.io/cocoapods/v/ISEmojiView.svg?style=flat)](http://cocoapods.org/pods/ISEmojiView) [![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![License](https://img.shields.io/cocoapods/l/ISEmojiView.svg?style=flat)](http://cocoapods.org/pods/ISEmojiView) [![Platform](https://img.shields.io/cocoapods/p/ISEmojiView.svg?style=flat)](http://cocoapods.org/pods/ISEmojiView)  ![Swift](https://img.shields.io/badge/%20in-swift%205-orange.svg)

一个简单易用的 iOS Emoji 键盘

已经使用 Swift 重写，旧 *Objective-C* 版本在 [oc](https://github.com/isaced/ISEmojiView/tree/oc) 分支

<img src="/screenshot1.png" width="375" height="667"> <img src="/screenshot2.png" width="375" height="667">

## 特性

- Swift 编写
- 自定义 Emoji
- 多种肤色支持（ 🏻 🏼 🏽 🏾 🏿 ）
- 分类 Bottom Bar（类似 iOS 系统的 Emoji 键盘）
- 最近使用的 Emoji

## Example

clone 项目，在项目根目录执行 `pod install` 命令来运行

## 环境

- Swift 5
- iOS8+
- Xcode 10

## 使用

### 安装

#### Swift Package Manager

通过 [Swift Package Manager](https://swift.org/package-manager/) 安装 ISEmojiView 到你的项目，在 Package.swift 中添加：

```swift
.package(name: "ISEmojiView", url: "https://github.com/isaced/ISEmojiView.git", .upToNextMinor(from: "0.3.0")),
```

在 Xcode 中：

- 菜单 File > Swift Packages > Add Package Dependency
- 搜索 https://github.com/isaced/ISEmojiView.git
- 选择 "Up to Next Major" 版本 "0.3.0"


#### CocoaPods

```Ruby
# Swift
pod 'ISEmojiView'

# Objective-C (不再维护)
pod 'ISEmojiView', '0.0.1'
```

#### Carthage

```Ruby
github "isaced/ISEmojiView"
```

### 引入

```Swift
import ISEmojiView
```

### 初始化

```Swift
let keyboardSettings = KeyboardSettings(bottomType: .categories)
let emojiView = EmojiView(keyboardSettings: keyboardSettings)
emojiView.translatesAutoresizingMaskIntoConstraints = false
emojiView.delegate = self
textView.inputView = emojiView
```

### 代理

实现 `<EmojiViewDelegate>`

```Swift
// 回调：点击某个 Emoji 表情的
func emojiViewDidSelectEmoji(_ emoji: String, emojiView: EmojiView) {
    textView.insertText(emoji)
}

// 回调：点击切换键盘按钮
func emojiViewDidPressChangeKeyboardButton(_ emojiView: EmojiView) {
    textView.inputView = nil
    textView.keyboardType = .default
    textView.reloadInputViews()
}
    
// 回调：点击删除按钮
func emojiViewDidPressDeleteBackwardButton(_ emojiView: EmojiView) {
    textView.deleteBackward()
}

// 回调：点击隐藏按钮
func emojiViewDidPressDismissKeyboardButton(_ emojiView: EmojiView) {
    textView.resignFirstResponder()
}
```

### 定制

#### KeyboardSettings

这个类用来描述键盘设置，可以使用如下属性：

- `bottomType` - 键盘底部视图，有这几个选项： `.pageControl`、 `.categories`，可以看看 `BottomType` 枚举，默认是 `.pageControl`。
- `customEmojis` - 自定义 Emoji 列表。 需要使用到 `EmojiCategory` 类。
- `isShowPopPreview` - 长按 Emoji 弹出浮层（可供选择肤色），效果类似 iOS10 系统键盘的。默认为 true。
- `countOfRecentsEmojis` - 最近 Emoji 最大数量，如果设置为 0 则不开启 “最近” 功能。默认为 50。
- `needToShowAbcButton` - 是否展示切换键盘按钮。这个按钮在 `Categories` 底部视图。


## 其他

如果你在找一个关于 React Native 的实现，可以参考 [brendan-rius/react-native-emoji-keyboard](https://github.com/brendan-rius/react-native-emoji-keyboard)，也是基于本项目开发。

## License

MIT
