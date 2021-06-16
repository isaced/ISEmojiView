//
//  SwiftUIView.swift
//  
//
//  Created by Michał Śmiałko on 16/06/2021.
//

import SwiftUI
import UIKit

public struct EmojiView_SwiftUI: UIViewRepresentable {
    public typealias UIViewType = EmojiView
    
    public var didSelect: ((String) -> Void)?
    
    public init(didSelect: ((String) -> Void)? = nil) {
        self.didSelect = didSelect
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
        
        public func emojiViewDidSelectEmoji(_ emoji: String, emojiView: EmojiView) {
            parent.didSelect?(emoji)
        }
    }
}

struct EmojiView_SwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        EmojiView_SwiftUI()
            .border(Color.green, width: 5)
            .frame(width: 300, height: 500)
            .border(Color.red, width: 2)
            .previewLayout(.fixed(width: 800, height: 600))
    }
}
