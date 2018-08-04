//
//  Constants.swift
//  ISEmojiView
//
//  Created by Beniamin Sarkisyan on 01/08/2018.
//

import UIKit
import Foundation

internal let EmojiSize = CGSize(width: 45, height: 35)
internal let EmojiFont = UIFont(name: "Apple color emoji", size: 30)
internal let TopPartSize = CGSize(width: EmojiSize.width * 1.3, height: EmojiSize.height * 1.6)
internal let BottomPartSize = CGSize(width: EmojiSize.width * 0.8, height: EmojiSize.height + 10)
internal let EmojiPopViewSize = CGSize(width: TopPartSize.width, height: TopPartSize.height + BottomPartSize.height)
internal let CollectionMinimumLineSpacing = CGFloat(0)
internal let CollectionMinimumInteritemSpacing = CGFloat(0)

public let MaxCountOfRecentsEmojis: Int = 50
