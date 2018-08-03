//
//  KeyboardSettings.swift
//  ISEmojiView
//
//  Created by Beniamin Sarkisyan on 03/08/2018.
//

import Foundation

final public class KeyboardSettings {
    
    // MARK: - Public variables
    
    /// type of bottom view
    public var bottomType: BottomType!
    
    /// array with custom emojis
    public var customEmojis: [EmojiCategory]?
    
    /// long press to pop preview effect like iOS10 system emoji keyboard, Default is true
    public var isShowPopPreview: Bool = true
    
    /// the max number of recent emojis
    /// if set 0, nothing will be shown
    public var countOfRecentsEmojis: Int = 50
    
    /// need to show change keyboard button
    public var needToShowAbcButton: Bool = false
    
    // MARK: - Init functions
    
    public init(bottomType: BottomType) {
        self.bottomType = bottomType
    }
    
}
