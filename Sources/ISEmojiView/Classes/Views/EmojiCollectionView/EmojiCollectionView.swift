//
//  EmojiCollectionView.swift
//  ISEmojiView
//
//  Created by Beniamin Sarkisyan on 01/08/2018.
//

import Foundation
import UIKit

/// emoji view action callback delegate
internal protocol EmojiCollectionViewDelegate: AnyObject {
    
    /// did press a emoji button
    ///
    /// - Parameters:
    ///   - emojiView: the emoji view
    ///   - emoji: a emoji
    ///   - selectedEmoji: the selected emoji
    func emojiViewDidSelectEmoji(emojiView: EmojiCollectionView, emoji: Emoji, selectedEmoji: String)
    
    /// changed section
    ///
    /// - Parameters:
    ///   - category: current category
    ///   - emojiView: the emoji view
    func emojiViewDidChangeCategory(_ category: Category, emojiView: EmojiCollectionView)
    
}

/// A emoji keyboard view
internal class EmojiCollectionView: UIView {
    
    // MARK: - Public variables
    
    /// the delegate for callback
    internal weak var delegate: EmojiCollectionViewDelegate?
    
    /// long press to pop preview effect like iOS10 system emoji keyboard, Default is true
    internal var isShowPopPreview = true
    
    internal var emojis: [EmojiCategory] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    // MARK: - Private variables
    
    private var scrollViewWillBeginDragging = false
    private var scrollViewWillBeginDecelerating = false
    private var lastLongPressIndexPath: IndexPath?
    private var lastLayoutSize: CGSize = .zero
    private let emojiCellReuseIdentifier = "EmojiCell"
    
    private lazy var emojiPopView: EmojiPopView = {
        let emojiPopView = EmojiPopView()
        emojiPopView.delegate = self
        emojiPopView.isHidden = true
        return emojiPopView
    }()
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(EmojiCollectionCell.self, forCellWithReuseIdentifier: emojiCellReuseIdentifier)
        }
    }
    
    // MARK: - Override variables
    
    internal override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: frame.size.height)
    }
    
    // MARK: - Override functions
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Cell size depends on the collection view bounds, so recompute the
        // layout after rotation or container resizes.
        if collectionView.bounds.size != lastLayoutSize {
            lastLayoutSize = collectionView.bounds.size
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }

    
    // MARK: - Public
    
    internal func popPreviewShowing() -> Bool {
        return !self.emojiPopView.isHidden;
    }
    
    // MARK: - Init functions
    
    static func loadFromNib(emojis: [EmojiCategory]) -> EmojiCollectionView {
        let nibName = String(describing: EmojiCollectionView.self)
        
        guard let nib = Bundle.podBundle.loadNibNamed(nibName, owner: nil, options: nil) as? [EmojiCollectionView] else {
            fatalError()
        }
        
        guard let view = nib.first else {
            fatalError()
        }
        
        view.emojis = emojis
        view.setupView()
        
        return view
    }
    
    // MARK: - Override functions
    
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard point.y < 0 else {
            return super.point(inside: point, with: event)
        }
        
        return point.y >= -TopPartSize.height
    }
    
    // MARK: - Internal functions
    
    internal func updateRecentsEmojis(_ emojis: [Emoji]) {
        self.emojis[0].emojis = emojis
        collectionView.reloadSections(IndexSet(integer: 0))
    }
    
    internal func scrollToCategory(_ category: Category) {
        guard var section = emojis.firstIndex(where: { $0.category == category }) else {
            return
        }
        
        if category == .recents && emojis[section].emojis.isEmpty {
            section = emojis.firstIndex(where: { $0.category == Category.smileysAndPeople })!
        }
        
        let indexPath = IndexPath(item: 0, section: section)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
    }
    
}

// MARK: - UICollectionViewDataSource

extension EmojiCollectionView: UICollectionViewDataSource {
    
    internal func numberOfSections(in collectionView: UICollectionView) -> Int {
        return emojis.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis[section].emojis.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let emojiCategory = emojis[indexPath.section]
        let emoji = emojiCategory.emojis[indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emojiCellReuseIdentifier, for: indexPath) as! EmojiCollectionCell
        
        if let selectedEmoji = emoji.selectedEmoji {
            cell.setEmoji(selectedEmoji)
        } else {
            cell.setEmoji(emoji.emoji)
        }
        
        return cell
    }

    
}

// MARK: - UICollectionViewDelegate

extension EmojiCollectionView: UICollectionViewDelegate {
    
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard emojiPopView.isHidden else {
            dismissPopView(false)
            return
        }
        
        let emojiCategory = emojis[indexPath.section]
        let emoji = emojiCategory.emojis[indexPath.item]
        
        delegate?.emojiViewDidSelectEmoji(emojiView: self, emoji: emoji, selectedEmoji: emoji.selectedEmoji ?? emoji.emoji)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !scrollViewWillBeginDecelerating && !scrollViewWillBeginDragging {
            return
        }
        
        if let indexPath = collectionView.indexPathsForVisibleItems.min() {
            let emojiCategory = emojis[indexPath.section]
            delegate?.emojiViewDidChangeCategory(emojiCategory.category, emojiView: self)
        }
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension EmojiCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let bounds = collectionView.bounds
        
        // Keep the grid density close to the system emoji keyboard on every
        // device: derive columns/rows from a target cell size instead of a
        // fixed cell, so large phones and iPad get bigger cells rather than
        // an ever denser grid.
        let columns = max(8, min(12, (bounds.width / 50).rounded()))
        let rows = max(4, min(6, (bounds.height / 56).rounded()))
        
        return CGSize(
            width: (bounds.width / columns).rounded(.down),
            height: (bounds.height / rows).rounded(.down)
        )
    }
    
}

// MARK: - UIScrollView

extension EmojiCollectionView {

    internal func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollViewWillBeginDragging = true
    }
    
    internal func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollViewWillBeginDecelerating = true
    }
    
    internal func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard lastLongPressIndexPath == nil else {
            return
        }

        dismissPopView(false)
    }
    
    internal func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollViewWillBeginDragging = false
    }
    
    internal func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewWillBeginDecelerating = false
    }

}

// MARK: - EmojiPopViewDelegate

extension EmojiCollectionView: EmojiPopViewDelegate {
    
    internal func emojiPopViewShouldDismiss(emojiPopView: EmojiPopView) {
        dismissPopView(true)
    }
    
}

// MARK: - Private functions

extension EmojiCollectionView {
    
    private func setupView() {
        let emojiLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(emojiLongPressHandle))
        addGestureRecognizer(emojiLongPressGestureRecognizer)
        
        addSubview(emojiPopView)
    }
    
    @objc private func emojiLongPressHandle(sender: UILongPressGestureRecognizer) {
        guard isShowPopPreview else { return }

        let location = sender.location(in: collectionView)

        switch sender.state {
        case .began:
            lastLongPressIndexPath = nil
            collectionView.isScrollEnabled = false
            updatePopPreview(at: location, animated: false)
        case .changed:
            updatePopPreview(at: location, animated: true)
        case .ended:
            collectionView.isScrollEnabled = true
            lastLongPressIndexPath = nil

            guard let indexPath = indexPathForItem(near: location) else {
                return
            }

            let emoji = emojis[indexPath.section].emojis[indexPath.item]
            if emoji.variants.count == 1 {
                dismissPopView(true)
            }
        case .cancelled, .failed:
            collectionView.isScrollEnabled = true
            lastLongPressIndexPath = nil
            dismissPopView(false)
        case .possible:
            break
        @unknown default:
            break
        }
    }

    private func updatePopPreview(at location: CGPoint, animated: Bool) {
        let edgeRect = collectionView.bounds.inset(by: collectionView.contentInset)

        guard edgeRect.contains(location) else {
            dismissPopView(true)
            lastLongPressIndexPath = nil
            return
        }

        guard let indexPath = indexPathForItem(near: location),
              let attributes = collectionView.layoutAttributesForItem(at: indexPath) else {
            return
        }

        guard indexPath != lastLongPressIndexPath else {
            return
        }

        lastLongPressIndexPath = indexPath

        let emoji = emojis[indexPath.section].emojis[indexPath.item]
        emojiPopView.setEmoji(emoji)

        let cellFrame = collectionView.convert(attributes.frame, to: self)
        let emojiPopLocation = CGPoint(
            x: cellFrame.origin.x - ((TopPartSize.width - BottomPartSize.width) / 2.0) + 5,
            y: cellFrame.origin.y - TopPartSize.height - 10
        )
        emojiPopView.move(location: emojiPopLocation, animation: animated)
    }

    private func indexPathForItem(near location: CGPoint) -> IndexPath? {
        if let indexPath = collectionView.indexPathForItem(at: location) {
            return indexPath
        }

        let maxDistance: CGFloat = 22
        var nearest: (indexPath: IndexPath, distance: CGFloat)?

        for indexPath in collectionView.indexPathsForVisibleItems {
            guard let attributes = collectionView.layoutAttributesForItem(at: indexPath) else {
                continue
            }

            let frame = attributes.frame
            let dx = max(0, max(frame.minX - location.x, location.x - frame.maxX))
            let dy = max(0, max(frame.minY - location.y, location.y - frame.maxY))
            let distance = dx * dx + dy * dy

            guard distance <= maxDistance * maxDistance else {
                continue
            }

            if distance < (nearest?.distance ?? .greatestFiniteMagnitude) {
                nearest = (indexPath, distance)
            }
        }

        return nearest?.indexPath
    }
    
    private func dismissPopView(_ usePopViewEmoji: Bool) {
        emojiPopView.dismiss()
        
        let currentEmoji = emojiPopView.currentEmoji
        if !currentEmoji.isEmpty && usePopViewEmoji {
            self.delegate?.emojiViewDidSelectEmoji(emojiView: self, emoji: Emoji(variants: emojiPopView.emojiArray), selectedEmoji: currentEmoji)
        }
        
        emojiPopView.currentEmoji = ""
    }
    
}
