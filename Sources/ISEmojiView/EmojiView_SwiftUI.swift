//
//  SwiftUIView.swift
//  
//
//  Created by Michał Śmiałko on 16/06/2021.
//

import SwiftUI
import UIKit

@available(iOS 13.0, *)
public struct EmojiView_SwiftUI: UIViewRepresentable {
    public typealias UIViewType = EmojiView
    
    var didSelect: ((String) -> Void)?
    var didPressChangeKeyboard: (() -> Void)?
    var didPressDeleteBackward: (() -> Void)?
    var dDidPressDismissKeyboard: (() -> Void)?
    
    public init(didSelect: ((String) -> Void)? = nil, didPressChangeKeyboard: (() -> Void)? = nil, didPressDeleteBackward: (() -> Void)? = nil, dDidPressDismissKeyboard: (() -> Void)? = nil) {
        self.didSelect = didSelect
        self.didPressChangeKeyboard = didPressChangeKeyboard
        self.didPressDeleteBackward = didPressDeleteBackward
        self.dDidPressDismissKeyboard = dDidPressDismissKeyboard
    }

    public func makeUIView(context: Context) -> EmojiView {
        let keyboardSettings = KeyboardSettings(bottomType: .categories)
        let emojiView = EmojiView(keyboardSettings: keyboardSettings)
        emojiView.translatesAutoresizingMaskIntoConstraints = false
        emojiView.delegate = context.coordinator
        
        return emojiView
    }
    
    public func updateUIView(_ uiView: EmojiView, context: Context) {
        guard let superview = uiView.superview else { return }
        
        NSLayoutConstraint.activate([
            uiView.widthAnchor.constraint(equalTo: superview.widthAnchor),
            uiView.heightAnchor.constraint(equalTo: superview.heightAnchor)
        ])
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: NSObject, EmojiViewDelegate {
        
        let parent: EmojiView_SwiftUI
        
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
            parent.dDidPressDismissKeyboard?()
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
