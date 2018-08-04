//
//  EmojiCollectionCell.swift
//  ISEmojiView
//
//  Created by Beniamin Sarkisyan on 01/08/2018.
//

import Foundation

internal class EmojiCollectionCell: UICollectionViewCell {
    
    // MARK: - Private variables
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = EmojiFont
        label.textAlignment = .center
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return label
    }()
    
    // MARK: - Override functions
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    // MARK: - Internal functions
    
    internal func setEmoji(_ emoji: String) {
        emojiLabel.text = emoji
    }
    
    // MARK: - Private functions
    
    private func setupView() {
        emojiLabel.frame = bounds
        addSubview(emojiLabel)
    }
    
}
