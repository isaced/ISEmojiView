//
//  EmojiView_SwiftUI.swift
//
//
//  Created by Michał Śmiałko on 16/06/2021.
//

import SwiftUI
import UIKit

/// A SwiftUI wrapper that embeds `EmojiView` inline as a panel.
///
/// All keyboard settings are applied once when the underlying view is created.
/// To change them later, replace the view with a new one, for example via `.id(...)`.
@available(iOS 13.0, *)
public struct EmojiView_SwiftUI: UIViewRepresentable {
    
    public typealias UIViewType = EmojiView
    
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
    
    public func makeUIView(context: Context) -> EmojiView {
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
        
        return emojiView
    }
    
    public func updateUIView(_ uiView: EmojiView, context: Context) {
        context.coordinator.parent = self
        context.coordinator.pinToSuperviewIfNeeded(uiView)
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: NSObject, EmojiViewDelegate {
        
        var parent: EmojiView_SwiftUI
        
        private weak var pinnedSuperview: UIView?
        private var pinnedConstraints: [NSLayoutConstraint]?
        
        init(_ parent: EmojiView_SwiftUI) {
            self.parent = parent
        }
        
        // MARK: EmojiViewDelegate
        
        public func emojiViewDidSelectEmoji(_ emoji: String, emojiView: EmojiView) {
            parent.didSelect?(emoji)
        }
        
        public func emojiViewDidPressChangeKeyboardButton(_ emojiView: EmojiView) {
            parent.didPressChangeKeyboard?()
        }
        
        public func emojiViewDidPressDeleteBackwardButton(_ emojiView: EmojiView) {
            parent.didPressDeleteBackward?()
        }
        
        public func emojiViewDidPressDismissKeyboardButton(_ emojiView: EmojiView) {
            parent.didPressDismissKeyboard?()
        }
        
        // EmojiView has no intrinsic content size, so it must be pinned to the
        // hosting view. Activate the constraints once and only re-pin when the
        // view moves to a different superview.
        func pinToSuperviewIfNeeded(_ uiView: EmojiView) {
            guard let superview = uiView.superview, superview !== pinnedSuperview else {
                return
            }
            
            NSLayoutConstraint.deactivate(pinnedConstraints ?? [])
            
            let constraints = [
                uiView.widthAnchor.constraint(equalTo: superview.widthAnchor),
                uiView.heightAnchor.constraint(equalTo: superview.heightAnchor)
            ]
            NSLayoutConstraint.activate(constraints)
            
            pinnedConstraints = constraints
            pinnedSuperview = superview
        }
    }
}

@available(iOS 13.0, *)
struct EmojiView_SwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        EmojiView_SwiftUI()
            .frame(width: 300, height: 500)
            .border(Color.red, width: 2)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
