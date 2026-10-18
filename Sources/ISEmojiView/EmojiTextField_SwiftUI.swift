//
//  EmojiTextField_SwiftUI.swift
//
//  A SwiftUI text field that replaces the system keyboard with ISEmojiView.
//

import SwiftUI
import UIKit

/// A `UITextField` wrapper that uses `EmojiView` as its `inputView`, the
/// recommended way to integrate the emoji keyboard into a SwiftUI app.
///
/// The bound text stays the single source of truth: emoji taps, deletions and
/// typing all sync through the text field delegate, so cursor position and
/// grapheme-cluster deletion keep working.
///
/// All keyboard settings are applied once when the underlying view is created.
/// To change them later, replace the view with a new one, for example via `.id(...)`.
@available(iOS 13.0, *)
public struct EmojiTextField: UIViewRepresentable {
    
    public typealias UIViewType = UITextField
    
    @Binding var text: String
    
    var placeholder: String?
    var bottomType: BottomType
    var customEmojis: [EmojiCategory]?
    var isShowPopPreview: Bool
    var needToShowAbcButton: Bool?
    var needToShowDeleteButton: Bool?
    var updateRecentEmojiImmediately: Bool?
    var countOfRecentsEmojis: Int?
    var didSelect: ((String) -> Void)?
    var didPressChangeKeyboard: (() -> Void)?
    var didPressDeleteBackward: (() -> Void)?
    var didPressDismissKeyboard: (() -> Void)?
    
    public init(
        text: Binding<String>,
        placeholder: String = "",
        bottomType: BottomType = .categories,
        customEmojis: [EmojiCategory]? = nil,
        isShowPopPreview: Bool = true,
        needToShowAbcButton: Bool? = false,
        needToShowDeleteButton: Bool? = true,
        updateRecentEmojiImmediately: Bool? = true,
        countOfRecentsEmojis: Int? = MaxCountOfRecentsEmojis,
        didSelect: ((String) -> Void)? = nil,
        didPressChangeKeyboard: (() -> Void)? = nil,
        didPressDeleteBackward: (() -> Void)? = nil,
        didPressDismissKeyboard: (() -> Void)? = nil) {
            self._text = text
            self.placeholder = placeholder
            self.bottomType = bottomType
            self.customEmojis = customEmojis
            self.isShowPopPreview = isShowPopPreview
            self.needToShowAbcButton = needToShowAbcButton
            self.needToShowDeleteButton = needToShowDeleteButton
            self.updateRecentEmojiImmediately = updateRecentEmojiImmediately
            self.countOfRecentsEmojis = countOfRecentsEmojis
            self.didSelect = didSelect
            self.didPressChangeKeyboard = didPressChangeKeyboard
            self.didPressDeleteBackward = didPressDeleteBackward
            self.didPressDismissKeyboard = didPressDismissKeyboard
        }
    
    public func makeUIView(context: Context) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.delegate = context.coordinator
        textField.placeholder = placeholder
        textField.text = text
        
        let keyboardSettings = KeyboardSettings(bottomType: bottomType)
        keyboardSettings.customEmojis = customEmojis
        keyboardSettings.isShowPopPreview = isShowPopPreview
        keyboardSettings.needToShowAbcButton = needToShowAbcButton ?? false
        keyboardSettings.needToShowDeleteButton = needToShowDeleteButton ?? true
        keyboardSettings.updateRecentEmojiImmediately = updateRecentEmojiImmediately ?? true
        keyboardSettings.countOfRecentsEmojis = countOfRecentsEmojis ?? MaxCountOfRecentsEmojis
        
        let emojiView = EmojiView(keyboardSettings: keyboardSettings)
        emojiView.translatesAutoresizingMaskIntoConstraints = false
        emojiView.delegate = context.coordinator
        
        textField.inputView = emojiView
        context.coordinator.textField = textField
        
        return textField
    }
    
    public func updateUIView(_ uiView: UITextField, context: Context) {
        context.coordinator.parent = self
        
        // Assigning `text` resets the caret, so only sync real external changes.
        if uiView.text != text {
            uiView.text = text
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: NSObject, UITextFieldDelegate, EmojiViewDelegate {
        
        var parent: EmojiTextField
        
        weak var textField: UITextField?
        
        init(_ parent: EmojiTextField) {
            self.parent = parent
        }
        
        // MARK: UITextFieldDelegate
        
        public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let currentText = (textField.text ?? "") as NSString
            parent.text = currentText.replacingCharacters(in: range, with: string)
            return true
        }
        
        // MARK: EmojiViewDelegate
        
        public func emojiViewDidSelectEmoji(_ emoji: String, emojiView: EmojiView) {
            // Insert through the text field so cursor and undo keep working.
            // UITextField.insertText(_:) does not go through the delegate, so
            // sync the binding afterwards.
            if let textField = textField {
                textField.insertText(emoji)
                parent.text = textField.text ?? ""
            }
            parent.didSelect?(emoji)
        }
        
        public func emojiViewDidPressChangeKeyboardButton(_ emojiView: EmojiView) {
            if let didPressChangeKeyboard = parent.didPressChangeKeyboard {
                didPressChangeKeyboard()
            } else if let textField = textField {
                // Default: switch back to the system keyboard.
                textField.inputView = nil
                textField.reloadInputViews()
            }
        }
        
        public func emojiViewDidPressDeleteBackwardButton(_ emojiView: EmojiView) {
            textField?.deleteBackward()
            
            // deleteBackward() does not go through the delegate, so sync manually.
            if let textField = textField {
                parent.text = textField.text ?? ""
            }
            
            parent.didPressDeleteBackward?()
        }
        
        public func emojiViewDidPressDismissKeyboardButton(_ emojiView: EmojiView) {
            textField?.resignFirstResponder()
            parent.didPressDismissKeyboard?()
        }
    }
}
