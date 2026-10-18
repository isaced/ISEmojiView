//
//  KeyboardSettings.swift
//  ISEmojiView
//
//  Created by Beniamin Sarkisyan on 03/08/2018.
//

import Foundation

final public class KeyboardSettings {
    
    // MARK: - Public variables
    
    /// The default max number of recent emojis.
    public static let defaultCountOfRecentsEmojis: Int = 50
    
    /// false if you want update recent emoji every popup.
    public var updateRecentEmojiImmediately:Bool = true
    
    /// Type of bottom view. Default is `.pageControl`.
    public var bottomType: BottomType = .pageControl
    
    /// Array with custom emojis
    public var customEmojis: [EmojiCategory]?
    
    /// Long press to pop preview effect like iOS10 system emoji keyboard. Default is true.
    public var isShowPopPreview: Bool = true
    
    /// The max number of recent emojis, if set 0, nothing will be shown. Default is 50.
    public var countOfRecentsEmojis: Int = KeyboardSettings.defaultCountOfRecentsEmojis
    
    /// Need to show change keyboard button
    /// This button is located in `Categories` bottom view.
    /// Default is false.
    public var needToShowAbcButton: Bool = false

    /// Need to show the delete (backspace) button in the bottom view. Default is true.
    public var needToShowDeleteButton: Bool = true
    
    // MARK: - Init functions
    
    public init(bottomType: BottomType) {
        self.bottomType = bottomType
    }
    
}
