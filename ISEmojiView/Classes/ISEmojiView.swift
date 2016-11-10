//
//  ISEmojiView.swift
//  Pods
//
//  Created by isaced on 2016/11/8.
//
//

import Foundation

/// emoji view action callback delegate
public protocol ISEmojiViewDelegate: class {
    
    /// did press a emoji button
    ///
    /// - Parameters:
    ///   - emojiView: the emoji view
    ///   - emoji: a emoji
    func emojiViewDidSelectEmoji(emojiView: ISEmojiView, emoji: String)
    
    
    /// will delete last character in you input view
    ///
    /// - Parameter emojiView: the emoji view
    func emojiViewDidPressDeleteButton(emojiView: ISEmojiView)
}

fileprivate let EmojiSize = CGSize(width: 38, height: 38)
fileprivate let EmojiFontSize = CGFloat(35.0)
fileprivate let collectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 35, right: 10)
fileprivate let collectionMinimumLineSpacing = CGFloat(0)
fileprivate let collectionMinimumInteritemSpacing = CGFloat(8.0)

/// A emoji keyboard view
public class ISEmojiView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {

    var defaultFrame: CGRect {
        return CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 216)
    }
    var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = EmojiSize
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = collectionMinimumLineSpacing
        layout.minimumInteritemSpacing = collectionMinimumInteritemSpacing
        layout.sectionInset = collectionInset
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.showsHorizontalScrollIndicator = false
        collection.showsVerticalScrollIndicator = false
        collection.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collection.backgroundColor = UIColor(red: 249/255.0, green: 249/255.0, blue: 249/255.0, alpha: 1)
        collection.register(ISEmojiCell.self, forCellWithReuseIdentifier: "cell")
        return collection
    }()
    var pageControl: UIPageControl = {
        let pageContr = UIPageControl()
        pageContr.hidesForSinglePage = true
        pageContr.currentPage = 0
        pageContr.backgroundColor = .clear
        return pageContr
    }()
    var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        let deleteButtonImage = UIImage(named: "icon_delete", in: ISEmojiView.thisBundle(), compatibleWith: nil)
        button.setImage(deleteButtonImage, for: .normal)
        button.tintColor = .lightGray
        return button
    }()
    var emojis: [[String]] = {
        if let filePath = ISEmojiView.pathOfResourceInBundle(filename: "ISEmojiList", filetype: "plist") {
            if let sections = NSDictionary(contentsOfFile: filePath) as? [String:[String]] {
                var emojiList: [[String]] = []
                for sectionName in ["People","Nature","Objects","Places","Symbols"] {
                    emojiList.append(sections[sectionName]!)
                }
                return emojiList
            }
        }
        return []
    }()
    public weak var delegate: ISEmojiViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func layoutSubviews() {
        updateControlLayout()
    }

    func setupUI() {
        frame = defaultFrame
        
        // ScrollView
        collectionView.frame = self.bounds
        collectionView.dataSource = self
        collectionView.delegate = self
        addSubview(collectionView)
        collectionView.reloadData()
        
        // PageControl
        pageControl.addTarget(self, action: #selector(pageControlTouched), for: .touchUpInside)
        pageControl.pageIndicatorTintColor = UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1)
        pageControl.currentPageIndicatorTintColor = UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
        pageControl.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin]
        addSubview(pageControl)
        
        // DeleteButton
        deleteButton.addTarget(self, action: #selector(deleteButtonPressed), for: .touchUpInside)
        addSubview(deleteButton)
    }
    
    func updateControlLayout() {
        frame = defaultFrame
        
        // update page control
        let pageCount = Int(ceil(collectionView.contentSize.width / collectionView.bounds.width))
        let pageControlSizes = pageControl.size(forNumberOfPages: pageCount)
        pageControl.frame = CGRect(x: frame.midX - pageControlSizes.width / 2.0,
                                        y: frame.height-pageControlSizes.height,
                                        width: pageControlSizes.width,
                                        height: pageControlSizes.height)
        pageControl.numberOfPages = pageCount
        
        // update delete button
        deleteButton.frame = CGRect(x: frame.width - 45, y: frame.height - 40, width: 40, height: 40)
    }
    
    //MARK: <UICollectionView>
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 5
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ISEmojiCell
        cell.setEmoji(emojis[indexPath.section][indexPath.row])
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let emoji = emojis[indexPath.section][indexPath.row]
        self.delegate?.emojiViewDidSelectEmoji(emojiView: self, emoji: emoji)
    }
    
    //MARK: <UIScrollView>
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.bounds.width
        let newPageNumber = Int(floor((scrollView.contentOffset.x - pageWidth / 2.0) / pageWidth) + 1)
        if pageControl.currentPage != newPageNumber {
            pageControl.currentPage = newPageNumber
        }
    }
    
    //MARK: Action
    
    func emojiButtonPressed(sender: UIButton) {
        if let emoji = sender.titleLabel?.text {
            self.delegate?.emojiViewDidSelectEmoji(emojiView: self, emoji: emoji)
        }
    }
    
    func deleteButtonPressed(sender: UIButton) {
        self.delegate?.emojiViewDidPressDeleteButton(emojiView: self)
    }
    
    func pageControlTouched(sender: UIPageControl) {
        var bounds = collectionView.bounds
        bounds.origin.x = bounds.width * CGFloat(sender.currentPage)
        collectionView.scrollRectToVisible(bounds, animated: true)
    }
    
    //MARK: Tools
    
    static func thisBundle() -> Bundle {
        let podBundle = Bundle(for: ISEmojiView.classForCoder())
        if let bundleURL = podBundle.url(forResource: "ISEmojiView", withExtension: "bundle") {
            if let bundle = Bundle(url: bundleURL) {
                return bundle
            }else{
                assertionFailure("Could not load the bundle")
            }
        }else{
            assertionFailure("Could not create a path to the bundle")
        }
        return Bundle()
    }
    static func pathOfResourceInBundle(filename:String, filetype: String) -> String? {
        if let filePath = thisBundle().path(forResource: filename, ofType: filetype) {
            return filePath
        }
        return nil
    }
}

/// the emoji cell in the grid
fileprivate class ISEmojiCell: UICollectionViewCell {
    
    var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Apple color e  moji", size: EmojiFontSize)
        label.textAlignment = .center
        label.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    func setupUI() {
        emojiLabel.frame = bounds
        self.addSubview(emojiLabel)
    }
    
    func setEmoji(_ emoji: String) {
        self.emojiLabel.text = emoji
    }
}
