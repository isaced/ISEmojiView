![logo](/logo@2x.jpg)
[![Version](https://img.shields.io/cocoapods/v/ISEmojiView.svg?style=flat)](http://cocoapods.org/pods/ISEmojiView) [![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![SPM supported](https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat)](https://swift.org/package-manager/) [![License](https://img.shields.io/cocoapods/l/ISEmojiView.svg?style=flat)](http://cocoapods.org/pods/ISEmojiView) [![Platform](https://img.shields.io/cocoapods/p/ISEmojiView.svg?style=flat)](http://cocoapods.org/pods/ISEmojiView)  ![Swift](https://img.shields.io/badge/%20in-swift%205-orange.svg)

一个简单易用的 iOS Emoji 键盘

已经使用 Swift 重写，旧 *Objective-C* 版本在 [oc](https://github.com/isaced/ISEmojiView/tree/oc) 分支

<img src="/screenshot1.png" width="375" height="667"> <img src="/screenshot2.png" width="375" height="667">

## 特性

- Swift 编写
- 自定义 Emoji
- 多种肤色支持（ 🏻 🏼 🏽 🏾 🏿 ）
- 分类 Bottom Bar（类似 iOS 系统的 Emoji 键盘）
- 最近使用的 Emoji
- 深色模式（Dark Mode）
- SwiftUI 支持
- 最新 Emoji 数据（Unicode 17）
- 网格密度随设备自适应（与系统键盘一致）
- 类目栏支持按住滑动切换

## Example

clone 项目后直接打开 `Example/ISEmojiViewExample.xcodeproj`（UIKit）或 `SwiftUIExample/SwiftUIExample.xcodeproj`（SwiftUI）即可运行，两者均通过本地 Swift Package 引用库源码，无需额外安装步骤。

## 环境

- Swift 5
- iOS 8+（CocoaPods / Carthage）、iOS 12+（Swift Package Manager）
- SwiftUI 组件需要 iOS 13+

## 使用

### 安装

#### Swift Package Manager

通过 [Swift Package Manager](https://swift.org/package-manager/) 安装 ISEmojiView 到你的项目，在 Package.swift 中添加：

```swift
.package(name: "ISEmojiView", url: "https://github.com/isaced/ISEmojiView.git", .upToNextMinor(from: "0.4.0")),
```

在 Xcode 中：

- 菜单 File > Swift Packages > Add Package Dependency
- 搜索 https://github.com/isaced/ISEmojiView.git
- 选择 "Up to Next Major" 版本 "0.4.0"


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

遵循 `EmojiViewDelegate` 协议

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
- `needToShowDeleteButton` - 是否在底部视图展示删除按钮。默认为 true。
- `updateRecentEmojiImmediately` - 选择 Emoji 后立即更新最近使用列表。默认为 true。

### SwiftUI

SwiftUI 组件仅通过 Swift Package Manager 提供（CocoaPods 只包含 UIKit 源码），需要 iOS 13+。

暂不支持 macOS SwiftUI 原生使用。

#### EmojiTextField（推荐）

用 Emoji 键盘替换输入框的系统键盘。`Binding` 是唯一数据源：点击 Emoji、删除键、字素整体回删（肤色变体、ZWJ 组合 emoji）都会自动同步。

```Swift
import ISEmojiView

@State private var text = ""

EmojiTextField(
    text: $text,
    placeholder: "轻触输入",
    bottomType: .categories,
    needToShowAbcButton: true
)
.frame(height: 44)
```

#### EmojiView_SwiftUI（内嵌面板）

将键盘直接嵌入页面。`EmojiView` 没有固有尺寸（intrinsic content size），需要显式指定 frame。

```Swift
import ISEmojiView

EmojiView_SwiftUI(
    bottomType: .categories,
    didSelect: { emoji in
        print(emoji)
    }
)
.frame(width: 300, height: 300)
```

所有键盘配置只在视图创建时生效一次；如需修改配置，请重建视图，例如使用 `.id(...)`。

完整可运行示例见 [`SwiftUIExample/`](SwiftUIExample)。

## License

MIT
