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
    
    
    /// is finished typing
    ///
    /// - Parameter emojiView: the emoji view
    func emojiViewDidPressDoneButton(emojiView: ISEmojiView)
}

fileprivate let EmojiSize = CGSize(width: 45, height: 35)
fileprivate let EmojiFontSize = CGFloat(30.0)
fileprivate let collectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 38, right: 10)
fileprivate let collectionMinimumLineSpacing = CGFloat(0)
fileprivate let collectionMinimumInteritemSpacing = CGFloat(0)
fileprivate let ISMainBackgroundColor = UIColor(red: 249/255.0, green: 249/255.0, blue: 249/255.0, alpha: 1)

/// A emoji keyboard view
public class ISEmojiView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    /// the delegate for callback
    public weak var delegate: ISEmojiViewDelegate?
    
    /// long press to pop preview effect like iOS10 system emoji keyboard, Default is true
    public var isShowPopPreview = true
    
    private var defaultFrame: CGRect {
        var defaultFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 236)
        defaultFrame.size.height += safeAreaBottomInset
        return defaultFrame
    }
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: defaultFrame.size.height)
    }
    var safeAreaBottomInset: CGFloat {
        if #available(iOS 11.0, *) {
            return safeAreaInsets.bottom
        } else {
            return 0
        }
    }
    public var collectionView: UICollectionView = {
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
        collection.backgroundColor = ISMainBackgroundColor
        collection.register(ISEmojiCell.self, forCellWithReuseIdentifier: "cell")
        return collection
    }()
    public var pageControl: UIPageControl = {
        let pageContr = UIPageControl()
        pageContr.hidesForSinglePage = true
        pageContr.currentPage = 0
        pageContr.backgroundColor = .clear
        return pageContr
    }()
    public var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("⌫", for: .normal)
        button.tintColor = .lightGray
        return button
    }()
    public var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("⏎", for: .normal)
        button.tintColor = .lightGray
        return button
    }()
    
    public var emojis: [[AnyObject]]!
    
    fileprivate let emojiPopView = ISEmojiPopView()
    
    public init(emojis: [[AnyObject]]) {
        self.init()
        
        self.emojis = emojis
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @available(iOS 11.0, *)
    public override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            
            var sectionInset = collectionInset
            sectionInset.bottom += safeAreaInsets.bottom
            
            layout.sectionInset = sectionInset
            layout.invalidateLayout()
        }
        
        setNeedsLayout()
        
        invalidateIntrinsicContentSize()
    }
    
    public override func layoutSubviews() {
        updateControlLayout()
    }
    
    private func setupUI() {
        frame = defaultFrame
        
        emojiPopView.delegate = self
        
        // Default emojis
        if emojis == nil {
            self.emojis = ISEmojiView.defaultEmojis()
        }
        
        // ScrollView
        collectionView.frame = self.bounds
        collectionView.dataSource = self
        collectionView.delegate = self
        addSubview(collectionView)
        collectionView.reloadData()
        
        // DeleteButton
        deleteButton.addTarget(self, action: #selector(deleteButtonPressed), for: .touchUpInside)
        addSubview(deleteButton)
        
        // PageControl
        pageControl.addTarget(self, action: #selector(pageControlTouched), for: .touchUpInside)
        pageControl.pageIndicatorTintColor = UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1)
        pageControl.currentPageIndicatorTintColor = UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
        pageControl.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin]
        addSubview(pageControl)
        
        // DoneButton
        doneButton.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
        addSubview(doneButton)
        
        // Long press to pop preview
        let emojiLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(emojiLongPressHandle))
        self.addGestureRecognizer(emojiLongPressGestureRecognizer)
        addSubview(emojiPopView)
    }
    
    private func updateControlLayout() {
        
        frame.origin.x = defaultFrame.origin.x
        frame.size = defaultFrame.size
        
        // update delete button
        deleteButton.frame = CGRect(x: 12, y: frame.height - 40 - safeAreaBottomInset, width: 40, height: 40)
        
        // update page control
        let pageCount = collectionView.numberOfSections
        let pageControlSizes = pageControl.size(forNumberOfPages: pageCount)
        
        var pageControlFrame = CGRect(x: frame.midX - pageControlSizes.width / 2.0,
                                      y: frame.height - pageControlSizes.height,
                                      width: pageControlSizes.width,
                                      height: pageControlSizes.height)
        
        pageControlFrame.origin.y -= safeAreaBottomInset
        
        pageControl.frame = pageControlFrame
        
        pageControl.numberOfPages = pageCount
        
        // update done button
        doneButton.frame = CGRect(x: frame.width - 48, y: frame.height - 40 - safeAreaBottomInset, width: 40, height: 40)
    }
    
    func dismissPopView(_ usePopViewEmoji: Bool) {
        emojiPopView.dismiss()
        let currentEmoji = emojiPopView.currentEmoji
        if currentEmoji != "" && usePopViewEmoji {
            self.delegate?.emojiViewDidSelectEmoji(emojiView: self, emoji: currentEmoji)
        }
        emojiPopView.currentEmoji = ""
    }
    
    //MARK: LongPress
    @objc private func emojiLongPressHandle(sender: UILongPressGestureRecognizer){
        guard isShowPopPreview else { return }
        
        let location = sender.location(in: collectionView)
        if longPressLocationInEdge(location) {
            if let indexPath = collectionView.indexPathForItem(at: location),
                let attr = collectionView.layoutAttributesForItem(at: indexPath) {
                var emojiArr: [String] = [""]
                if let emojiString = emojis[indexPath.section][indexPath.row] as? String {
                    emojiArr = [emojiString]
                } else if let emojiArray = emojis[indexPath.section][indexPath.row] as? [String] {
                    emojiArr = emojiArray
                }
                if sender.state != .ended {
                    let cellRect = attr.frame
                    let cellFrameInSuperView = collectionView.convert(cellRect, to: self)
                    emojiPopView.setEmojis(emojiArr)
                    let emojiPopLocation = CGPoint(
                        x: cellFrameInSuperView.origin.x - ((topPartSize.width - bottomPartSize.width) / 2.0) + 5,
                        y: cellFrameInSuperView.origin.y - topPartSize.height - 10
                    )
                    emojiPopView.move(location: emojiPopLocation, animation: sender.state != .began)
                }
            }
        }
    }
    
    private func longPressLocationInEdge(_ location: CGPoint) -> Bool {
        let edgeRect = UIEdgeInsetsInsetRect(collectionView.bounds, collectionInset)
        return edgeRect.contains(location)
    }
    
    //MARK: <UICollectionView>
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return emojis.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis[section].count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ISEmojiCell
        if let emojiString: String = emojis[indexPath.section][indexPath.row] as? String {
            cell.setEmoji(emojiString)
        } else if let emojiArr: [String] = emojis[indexPath.section][indexPath.row] as? [String],
            let emojiString = emojiArr.first {
            cell.setEmoji(emojiString)
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !emojiPopView.isHidden {
            dismissPopView(false)
        } else {
            if let emojiString: String = emojis[indexPath.section][indexPath.row] as? String {
                self.delegate?.emojiViewDidSelectEmoji(emojiView: self, emoji: emojiString)
            } else if let emojiArr: [String] = emojis[indexPath.section][indexPath.row] as? [String],
                let emojiString = emojiArr.first {
                self.delegate?.emojiViewDidSelectEmoji(emojiView: self, emoji: emojiString)
            }
        }
    }
    
    //MARK: <UIScrollView>
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        dismissPopView(false)
        if let firstVisibleCell = collectionView.visibleCells.first {
            if let indexpath = collectionView.indexPath(for: firstVisibleCell){
                pageControl.currentPage = indexpath.section
            }
        }
    }
    
    //MARK: Action
    private func emojiButtonPressed(sender: UIButton) {
        if let emoji = sender.titleLabel?.text {
            self.delegate?.emojiViewDidSelectEmoji(emojiView: self, emoji: emoji)
        }
    }
    
    @objc private func deleteButtonPressed(sender: UIButton) {
        self.delegate?.emojiViewDidPressDeleteButton(emojiView: self)
    }
    
    @objc private func doneButtonPressed(sender: UIButton) {
        self.delegate?.emojiViewDidPressDoneButton(emojiView: self)
    }
    
    @objc private func pageControlTouched(sender: UIPageControl) {
        var bounds = collectionView.bounds
        bounds.origin.x = bounds.width * CGFloat(sender.currentPage)
        collectionView.scrollRectToVisible(bounds, animated: true)
    }
    
    //MARK: Tools
    static private func thisBundle() -> Bundle {
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
    
    static private func pathOfResourceInBundle(filename:String, filetype: String) -> String? {
        if let filePath = thisBundle().path(forResource: filename, ofType: filetype) {
            return filePath
        }
        return nil
    }
    
    static private func defaultEmojis() -> [[AnyObject]] {
        var emojiPListFileName = "ISEmojiList_iOS10";
        if #available(iOS 11.0, *) {
            emojiPListFileName = "ISEmojiList"
        }
        if let filePath = ISEmojiView.pathOfResourceInBundle(filename: emojiPListFileName, filetype: "plist") {
            if let sections = NSArray(contentsOfFile: filePath) as? [[String: AnyObject]] {
                var emojiList: [[AnyObject]] = []
                for section in sections {
                    if let emojis = section["emojis"] as? [AnyObject] {
                        emojiList.append(emojis)
                    }
                }
                return emojiList
            }
        }
        return []
    }
}

extension ISEmojiView: ISEmojiPopViewDelegate {
    fileprivate func emojiPopViewShouldDismiss(emojiPopView: ISEmojiPopView) {
        dismissPopView(true)
    }
}

/// the emoji cell in the grid
fileprivate class ISEmojiCell: UICollectionViewCell {
    
    var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Apple color emoji", size: EmojiFontSize)
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

fileprivate let topPartSize = CGSize(width: EmojiSize.width * 1.3, height: EmojiSize.height * 1.6)
fileprivate let bottomPartSize = CGSize(width: EmojiSize.width * 0.8, height: EmojiSize.height + 10)

fileprivate protocol ISEmojiPopViewDelegate: class {
    
    /// called when the popView needs to dismiss itself
    ///
    func emojiPopViewShouldDismiss(emojiPopView: ISEmojiPopView)
    
}

fileprivate class ISEmojiPopView: UIView {
    /// the delegate for callback
    fileprivate weak var delegate: ISEmojiPopViewDelegate?
    
    let EmojiPopViewSize = CGSize(width: topPartSize.width, height: topPartSize.height + bottomPartSize.height)
    let popBackgroundColor = UIColor.white
    
    var currentEmoji: String = ""
    
    var locationX: CGFloat = 0.0 // the x location in the main viewController
    
    var emojiArray: [String] = []
    var emojiButtons: [UIButton] = []
    var emojisView: UIView = UIView()
    
    var emojisX: CGFloat = 0.0
    var emojisWidth: CGFloat = 0.0
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: EmojiPopViewSize.width, height: EmojiPopViewSize.height))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func createEmojiButton(_ emoji: String) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = UIFont(name: "Apple color emoji", size: EmojiFontSize)
        btn.setTitle(emoji, for: .normal)
        btn.frame = CGRect(x: CGFloat(emojiButtons.count) * EmojiSize.width, y: 0, width: EmojiSize.width, height: EmojiSize.height)
        btn.addTarget(self, action: #selector(selectEmojiType(_:)), for: .touchUpInside)
        btn.isUserInteractionEnabled = true
        return (btn)
    }
    
    @objc func selectEmojiType(_ sender: UIButton) {
        if let selectedEmoji = sender.titleLabel?.text {
            currentEmoji = selectedEmoji
            self.delegate?.emojiPopViewShouldDismiss(emojiPopView: self)
        }
    }
    
    func setupUI() {
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        // path
        let path = CGMutablePath()
        
        // adjust location of emoji bar if it is off the screen
        emojisWidth = topPartSize.width + EmojiSize.width * CGFloat(emojiArray.count - 1)
        emojisX = 0.0 // the x adjustment within the popView to account for the shift in location
        let screenWidth = UIScreen.main.bounds.width
        if emojisWidth + locationX > screenWidth {
            emojisX = -CGFloat(emojisWidth + locationX - screenWidth + 8) // 8 for padding to border
        }
        // readjust in case someone is long-pressing right at the edge of the screen
        if emojisX + emojisWidth < (topPartSize.width / 2.0 - bottomPartSize.width / 2.0) + bottomPartSize.width {
            emojisX = emojisX + ((topPartSize.width / 2.0 - bottomPartSize.width / 2.0) + bottomPartSize.width) - (emojisX + emojisWidth)
        }
        
        path.addRoundedRect(
            in: CGRect(
                x: emojisX,
                y: 0.0,
                width: emojisWidth,
                height: topPartSize.height
            ),
            cornerWidth: 10,
            cornerHeight: 10
        )
        path.addRoundedRect(
            in: CGRect(
                x: topPartSize.width / 2.0 - bottomPartSize.width / 2.0,
                y: topPartSize.height - 10,
                width: bottomPartSize.width,
                height: bottomPartSize.height + 10
            ),
            cornerWidth: 5,
            cornerHeight: 5
        )
        
        // border
        let borderLayer = CAShapeLayer()
        borderLayer.path = path
        borderLayer.strokeColor = UIColor(white: 0.8, alpha: 1).cgColor
        borderLayer.fillColor = UIColor.white.cgColor
        borderLayer.lineWidth = 1
        self.layer.addSublayer(borderLayer)
        
        // mask
        let maskLayer = CAShapeLayer()
        maskLayer.path = path
        
        // content layer
        let contentLayer = CALayer()
        contentLayer.frame = bounds
        contentLayer.backgroundColor = popBackgroundColor.cgColor
        contentLayer.mask = maskLayer
        
        layer.addSublayer(contentLayer)
        
        emojisView.removeFromSuperview()
        emojisView = UIView(frame: CGRect(x: emojisX + 8, y: 10, width: CGFloat(emojiArray.count) * EmojiSize.width, height: EmojiSize.height))
        
        // add buttons
        emojiButtons = []
        for emoji in emojiArray {
            let button = createEmojiButton(emoji)
            emojiButtons.append(button)
            emojisView.addSubview(button)
        }
        
        self.addSubview(emojisView)
        
        isHidden = true
    }
    
    func move(location: CGPoint, animation: Bool = true) {
        locationX = location.x
        setupUI()
        
        UIView.animate(withDuration: animation ? 0.08 : 0, animations: {
            self.alpha = 1
            self.frame = CGRect(x: location.x, y: location.y, width: self.frame.width, height: self.frame.height)
        }, completion: { complate in
            self.isHidden = false
        })
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.08, animations: {
            self.alpha = 0
        }, completion: { complate in
            self.isHidden = true
        })
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if point.x >= emojisX &&
            point.x <= emojisX + emojisWidth &&
            point.y >= 0 &&
            point.y <= topPartSize.height {
            return true
        }
        
        return false
    }
    
    func setEmojis(_ emojis: [String]) {
        self.currentEmoji = emojis.first ?? ""
        self.emojiArray = emojis
    }
    
}


