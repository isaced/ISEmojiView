//
//  EmojiView.swift
//  ISEmojiView
//
//  Created by Beniamin Sarkisyan on 01/08/2018.
//

import Foundation

public enum BottomType: Int {
    case pageControl, categories
}

public protocol EmojiViewDelegate: class {
    
    func emojiViewDidSelectEmoji(_ emoji: String, emojiView: EmojiView)
    func emojiViewDidPressChangeKeyboardButton(_ emojiView: EmojiView)
    func emojiViewDidPressDeleteBackwardButton(_ emojiView: EmojiView)
    func emojiViewDidPressDismissKeyboardButton(_ emojiView: EmojiView)
    
}

public extension EmojiViewDelegate {
    
    func emojiViewDidPressChangeKeyboardButton(_ emojiView: EmojiView) {}
    func emojiViewDidPressDeleteBackwardButton(_ emojiView: EmojiView) {}
    func emojiViewDidPressDismissKeyboardButton(_ emojiView: EmojiView) {}
    
}

final public class EmojiView: UIView {
    
    // MARK: - IBInspectable variables
    
    @IBInspectable private var _bottomType: Int = BottomType.pageControl.rawValue {
        didSet {
            guard let type = BottomType(rawValue: _bottomType) else {
                fatalError()
            }
            
            bottomType = type
            setupBottomView()
        }
    }
    
    @IBInspectable private var isShowPopPreview: Bool = true {
        didSet {
            emojiCollectionView?.isShowPopPreview = isShowPopPreview
        }
    }
    
    @IBInspectable private var countOfRecentsEmojis: Int = MaxCountOfRecentsEmojis {
        didSet {
            RecentEmojisManager.sharedInstance.maxCountOfCenetEmojis = countOfRecentsEmojis
            
            if countOfRecentsEmojis > 0 {
                if !emojis.contains(where: { $0.category == .recents }) {
                    emojis.insert(EmojiLoader.recentEmojiCategory(), at: 0)
                }
            } else if let index = emojis.index(where: { $0.category == .recents }) {
                emojis.remove(at: index)
            }
            
            emojiCollectionView?.emojis = emojis
            categoriesBottomView?.categories = emojis.map { $0.category }
        }
    }
    
    @IBInspectable private var needToShowAbcButton: Bool = false {
        didSet {
            categoriesBottomView?.needToShowAbcButton = needToShowAbcButton
        }
    }
    
    // MARK: - Public variables
    
    public weak var delegate: EmojiViewDelegate?
    
    // MARK: - Private variables
    
    private weak var bottomContainerView: UIView?
    private weak var emojiCollectionView: EmojiCollectionView?
    private weak var pageControlBottomView: PageControlBottomView?
    private weak var categoriesBottomView: CategoriesBottomView?
    private var bottomConstraint: NSLayoutConstraint?
    
    private var bottomType: BottomType!
    private var emojis: [EmojiCategory]!
    private var keyboardSettings: KeyboardSettings?
    
    // MARK: - Init functions
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        emojis = EmojiLoader.emojiCategories()
        
        if countOfRecentsEmojis > 0 {
            emojis.insert(EmojiLoader.recentEmojiCategory(), at: 0)
        }
        
        setupView()
        setupSubviews()
    }
    
    public init(keyboardSettings: KeyboardSettings) {
        super.init(frame: .zero)
        
        self.keyboardSettings = keyboardSettings
        
        bottomType = keyboardSettings.bottomType
        emojis = keyboardSettings.customEmojis ?? EmojiLoader.emojiCategories()
        
        if keyboardSettings.countOfRecentsEmojis > 0 {
            emojis.insert(EmojiLoader.recentEmojiCategory(), at: 0)
        }
        
        RecentEmojisManager.sharedInstance.maxCountOfCenetEmojis = keyboardSettings.countOfRecentsEmojis
        
        setupView()
        setupSubviews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        bottomType = BottomType(rawValue: _bottomType)
        emojis = EmojiLoader.emojiCategories()
        
        if countOfRecentsEmojis > 0 {
            emojis.insert(EmojiLoader.recentEmojiCategory(), at: 0)
        }
        
        setupSubviews()
    }
    
    // MARK: - Override functions
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if #available(iOS 11.0, *) {
            bottomConstraint?.constant = -safeAreaInsets.bottom
        } else {
            bottomConstraint?.constant = 0
        }
        
    }
    
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if point.y > 0 || !(emojiCollectionView?.popPreviewShowing() ?? false) {
            return super.point(inside: point, with: event)
        }
        
        return point.y >= -TopPartSize.height
    }
    
}

// MARK: - EmojiCollectionViewDelegate

extension EmojiView: EmojiCollectionViewDelegate {
    
    func emojiViewDidSelectEmoji(emojiView: EmojiCollectionView, emoji: Emoji, selectedEmoji: String) {
        if RecentEmojisManager.sharedInstance.add(emoji: emoji, selectedEmoji: selectedEmoji) {
            emojiCollectionView?.updateRecentsEmojis(RecentEmojisManager.sharedInstance.recentEmojis())
        }
        
        delegate?.emojiViewDidSelectEmoji(selectedEmoji, emojiView: self)
    }
    
    func emojiViewDidChangeCategory(_ category: Category, emojiView: EmojiCollectionView) {
        if let section = emojis.index(where: { $0.category == category }) {
            pageControlBottomView?.updatePageControlPage(section)
        }
        
        categoriesBottomView?.updateCurrentCategory(category)
    }
}

// MARK: - PageControlBottomViewDelegate

extension EmojiView: PageControlBottomViewDelegate {
    
    func pageControlBottomViewDidPressDeleteBackwardButton(_ bottomView: PageControlBottomView) {
        delegate?.emojiViewDidPressDeleteBackwardButton(self)
    }
    
    func pageControlBottomViewDidPressDismissKeyboardButton(_ bottomView: PageControlBottomView) {
        delegate?.emojiViewDidPressDismissKeyboardButton(self)
    }
    
}

// MARK: - CategoriesBottomViewDelegate

extension EmojiView: CategoriesBottomViewDelegate {
    
    func categoriesBottomViewDidSelecteCategory(_ category: Category, bottomView: CategoriesBottomView) {
        emojiCollectionView?.scrollToCategory(category)
    }
    
    func categoriesBottomViewDidPressChangeKeyboardButton(_ bottomView: CategoriesBottomView) {
        delegate?.emojiViewDidPressChangeKeyboardButton(self)
    }
    
    func categoriesBottomViewDidPressDeleteBackwardButton(_ bottomView: CategoriesBottomView) {
        delegate?.emojiViewDidPressDeleteBackwardButton(self)
    }
    
}

// MARK: - Private functions

extension EmojiView {
    
    private func setupView() {
        backgroundColor = UIColor(red: 249/255.0, green: 249/255.0, blue: 249/255.0, alpha: 1)
    }
    
    private func setupSubviews() {
        setupEmojiCollectionView()
        setupBottomContainerView()
        setupConstraints()
    }
    
    private func setupEmojiCollectionView() {
        let emojiCollectionView = EmojiCollectionView.loadFromNib(emojis: emojis)
        emojiCollectionView.isShowPopPreview = keyboardSettings?.isShowPopPreview ?? isShowPopPreview
        emojiCollectionView.delegate = self
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(emojiCollectionView)
        
        self.emojiCollectionView = emojiCollectionView
    }
    
    private func setupBottomContainerView() {
        let bottomContainerView = UIView()
        bottomContainerView.backgroundColor = .clear
        bottomContainerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomContainerView)
        
        self.bottomContainerView = bottomContainerView
        
        setupBottomView()
    }
    
    private func setupBottomView() {
        bottomContainerView?.subviews.forEach { $0.removeFromSuperview() }
        
        let categories: [Category] = emojis.map { $0.category }
        
        var _bottomView: UIView?
        
        if bottomType == .pageControl {
            let bottomView = PageControlBottomView.loadFromNib(categoriesCount: categories.count)
            bottomView.delegate = self
            self.pageControlBottomView = bottomView
            
            _bottomView = bottomView
        } else if bottomType == .categories {
            let needToShowAbcButton = keyboardSettings?.needToShowAbcButton ?? self.needToShowAbcButton
            let bottomView = CategoriesBottomView.loadFromNib(
                with: categories,
                needToShowAbcButton: needToShowAbcButton
            )
            bottomView.delegate = self
            self.categoriesBottomView = bottomView
            
            _bottomView = bottomView
        }
        
        guard let bottomView = _bottomView else {
            return
        }
        
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomContainerView?.addSubview(bottomView)
        
        let views = ["bottomView": bottomView]
        
        addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-0-[bottomView]-0-|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: nil,
                views: views
            )
        )
        
        addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0-[bottomView]-0-|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: nil,
                views: views
            )
        )
    }
    
    private func setupConstraints() {
        guard let emojiCollectionView = emojiCollectionView, let bottomContainerView = bottomContainerView else {
            return
        }
        
        let views = [
            "emojiCollectionView": emojiCollectionView,
            "bottomContainerView": bottomContainerView
        ]
        
        addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-0-[emojiCollectionView]-0-|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: nil,
                views: views
            )
        )
        
        addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-0-[bottomContainerView]-0-|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: nil,
                views: views
            )
        )
        
        addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-5-[emojiCollectionView]-(0)-[bottomContainerView(44)]",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: nil,
                views: views
            )
        )
        
        var bottomOffset = CGFloat(0)
        
        if #available(iOS 11.0, *) {
            bottomOffset = -safeAreaInsets.bottom
        }
        
        let bottomConstraint = NSLayoutConstraint(
            item: bottomContainerView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self,
            attribute: .bottom,
            multiplier: 1,
            constant: bottomOffset
        )
        
        addConstraint(bottomConstraint)
        
        self.bottomConstraint = bottomConstraint
    }
    
}
