//
//  ISEmojiCategoryCell.swift
//  ISEmojiView
//
//  Created by Beniamin Sarkisyan on 01/08/2018.
//

import Foundation

private let HighlightedBackgroundViewSize = CGFloat(30)

internal class CategoryCell: UICollectionViewCell {
    
    // MARK: - Private variables
    
    private var highlightedBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 201/255, green: 206/255, blue: 214/255, alpha: 1)
        view.isHidden = true
        return view
    }()
    
    private var emojiImageView: UIImageView = {
        let emojiImageView = UIImageView()
        emojiImageView.contentMode = .center
        return emojiImageView
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
    
    override var isHighlighted: Bool {
        didSet {
            highlightedBackgroundView.isHidden = !isHighlighted
        }
    }
    
    override var isSelected: Bool {
        didSet {
            highlightedBackgroundView.isHidden = !isSelected
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = min(HighlightedBackgroundViewSize, contentView.bounds.width)
        highlightedBackgroundView.frame.size.width = size
        highlightedBackgroundView.frame.size.height = size
        highlightedBackgroundView.frame.origin.x = contentView.center.x - size/2
        highlightedBackgroundView.frame.origin.y = contentView.center.y - size/2
        
        highlightedBackgroundView.layer.cornerRadius = highlightedBackgroundView.frame.width/2
        
        emojiImageView.frame = contentView.bounds
    }
    
    // MARK: - Internal functions
    
    internal func setEmojiCategory(_ category: Category) {
        if let imagePath = Bundle.podBundle.path(forResource: category.iconName, ofType: "png", inDirectory: "Images") {
            emojiImageView.image = UIImage(contentsOfFile: imagePath)
        } else {
            emojiImageView.image = UIImage(named: category.iconName)
        }
    }
    
    // MARK: - Private functions
    
    private func setupView() {
        contentView.addSubview(highlightedBackgroundView)
        contentView.addSubview(emojiImageView)
    }
    
}
