//
//  CategoriesBottomView.swift
//  ISEmojiView
//
//  Created by Beniamin Sarkisyan on 01/08/2018.
//

import Foundation
import UIKit

private let MinCellSize = CGFloat(35)

internal protocol CategoriesBottomViewDelegate: AnyObject {
    
    func categoriesBottomViewDidSelectCategory(_ category: Category, bottomView: CategoriesBottomView)
    func categoriesBottomViewDidPressChangeKeyboardButton(_ bottomView: CategoriesBottomView)
    func categoriesBottomViewDidPressDeleteBackwardButton(_ bottomView: CategoriesBottomView)
    
}

final internal class CategoriesBottomView: UIView {
    
    // MARK: - Internal variables
    
    internal weak var delegate: CategoriesBottomViewDelegate?
    internal var needToShowAbcButton: Bool? {
        didSet {
            guard let showAbcButton = needToShowAbcButton else {
                return
            }
            
            changeKeyboardButton.isHidden = !showAbcButton
            collectionViewToSuperViewLeadingConstraint.priority = showAbcButton ? .defaultHigh : .defaultLow
        }
    }
    
    internal var categories: [Category]! {
        didSet {
            collectionView.reloadData()
            
            if let selectedItems = collectionView.indexPathsForSelectedItems, selectedItems.isEmpty {
                selectFirstCell()
            }
        }
    }
    
    // MARK: - Private variables
    
    private var lastSwipedIndexPath: IndexPath?
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var changeKeyboardButton: UIButton!
    @IBOutlet private weak var deleteButton: UIButton! {
        didSet {
            let image = UIImage(named: "ic_emojiDelete", in: Bundle.podBundle,compatibleWith: nil)
            deleteButton.setImage(image, for: .normal)
        }
    }
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: "CategoryCell")
            
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(categoryBarPan(_:)))
            panGesture.delegate = self
            collectionView.addGestureRecognizer(panGesture)
        }
    }
    
    @IBOutlet private var collectionViewToSuperViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet private var collectionViewToSuperViewTrailingConstraint: NSLayoutConstraint!

    @IBOutlet private var deleteButtonToCollectionViewLeadingConstraint: NSLayoutConstraint!

    @IBOutlet private var deleteButtonToSuperViewTrailingConstraint: NSLayoutConstraint!

    // MARK: - Init functions
    
    static internal func loadFromNib(with categories: [Category], needToShowAbcButton: Bool, needToShowDeleteButton: Bool) -> CategoriesBottomView {
        let nibName = String(describing: CategoriesBottomView.self)
        
        guard let nib = Bundle.podBundle.loadNibNamed(nibName, owner: nil, options: nil) as? [CategoriesBottomView] else {
            fatalError()
        }
        
        guard let bottomView = nib.first else {
            fatalError()
        }
        
        bottomView.categories = categories
        bottomView.changeKeyboardButton.isHidden = !needToShowAbcButton
        bottomView.updateDeleteButtonVisibility(needToShowDeleteButton)
        
        if needToShowAbcButton {
            bottomView.collectionViewToSuperViewLeadingConstraint.priority = .defaultHigh
        }

        bottomView.selectFirstCell()
        
        return bottomView
    }

    private func updateDeleteButtonVisibility(_ isVisible: Bool) {
        deleteButton.isHidden = !isVisible
        deleteButtonToCollectionViewLeadingConstraint.isActive = isVisible
        deleteButtonToSuperViewTrailingConstraint.isActive = isVisible
        collectionViewToSuperViewTrailingConstraint.priority = isVisible ? .defaultLow : .required
    }
    
    // MARK: - Override functions
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            var size = collectionView.bounds.size
            let builtInCategoryCount = Category.count - 1
            let shouldScroll = categories.count > builtInCategoryCount
            
            if categories.count < Category.count - 2 {
                size.width = MinCellSize
            } else {
                size.width = collectionView.bounds.width / CGFloat(min(categories.count, builtInCategoryCount))
            }
            
            collectionView.isScrollEnabled = shouldScroll
            layout.itemSize = size
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    // MARK: - Internal functions
    
    internal func updateCurrentCategory(_ category: Category) {
        guard let item = categories.firstIndex(where: { $0 == category }) else {
            return
        }
        
        guard let selectedItem = collectionView.indexPathsForSelectedItems?.first?.item else {
            return
        }
        
        guard selectedItem != item else {
            return
        }
        
        (0..<categories.count).forEach {
            let indexPath = IndexPath(item: $0, section: 0)
            collectionView.deselectItem(at: indexPath, animated: false)
        }
        
        let indexPath = IndexPath(item: item, section: 0)
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
    
    // MARK: - IBActions
    
    @IBAction private func changeKeyboard() {
        delegate?.categoriesBottomViewDidPressChangeKeyboardButton(self)
    }
    
    @IBAction private func deleteBackward() {
        delegate?.categoriesBottomViewDidPressDeleteBackwardButton(self)
    }
    
}

// MARK: - UICollectionViewDataSource

extension CategoriesBottomView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        cell.setEmojiCategory(categories[indexPath.item])
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate

extension CategoriesBottomView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.categoriesBottomViewDidSelectCategory(categories[indexPath.item], bottomView: self)
    }
    
}

// MARK: - UIGestureRecognizerDelegate

extension CategoriesBottomView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return otherGestureRecognizer === collectionView.panGestureRecognizer
    }
    
}

// MARK: - Private functions

extension CategoriesBottomView {
    
    @objc private func categoryBarPan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            let location = gesture.location(in: collectionView)
            
            guard let indexPath = collectionView.indexPathForItem(at: location),
                  indexPath != lastSwipedIndexPath else {
                return
            }
            
            lastSwipedIndexPath = indexPath
            selectCategory(at: indexPath)
        case .ended, .cancelled, .failed:
            lastSwipedIndexPath = nil
        default:
            break
        }
    }
    
    private func selectCategory(at indexPath: IndexPath) {
        (0..<categories.count).forEach {
            collectionView.deselectItem(at: IndexPath(item: $0, section: 0), animated: false)
        }
        
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
        delegate?.categoriesBottomViewDidSelectCategory(categories[indexPath.item], bottomView: self)
    }
    
    private func selectFirstCell() {
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
    
}
