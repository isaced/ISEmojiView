//
//  KeyboardSettings.swift
//  ISEmojiView
//
//  Created by Beniamin Sarkisyan on 03/08/2018.
//

import Foundation

final public class KeyboardSettings {
    
    // MARK: - Public variables
    
    /// Type of bottom view. Default is `.pageControl`.
    public var bottomType: BottomType! = .pageControl
    
    /// Array with custom emojis
    public var customEmojis: [EmojiCategory]?
    
    /// Long press to pop preview effect like iOS10 system emoji keyboard. Default is true.
    public var isShowPopPreview: Bool = true
    
    /// The max number of recent emojis, if set 0, nothing will be shown. Default is 50.
    public var countOfRecentsEmojis: Int = MaxCountOfRecentsEmojis
    
    /// Need to show change keyboard button
    /// This button is located in `Categories` bottom view.
    /// Default is false.
    public var needToShowAbcButton: Bool = false
    
    // MARK: - Init functions
    
    public init(bottomType: BottomType) {
        self.bottomType = bottomType
    }
    
}
