//
//  CHPageCardView.swift
//  Pods
//
//  Created by Chance on 2017/2/27.
//
//

import UIKit


/// 组件委托代理方法
@objc
public protocol CHPageCardViewDelegate: class {
    
    
    /// 卡片单元总数量
    ///
    /// - Parameter pageCardView: 卡片切换组件
    /// - Returns:  委托的卡片的数量
    func numberOfCards(in pageCardView: CHPageCardView) -> Int
    
    
    /// 卡片的样式配置
    ///
    /// - Parameters:
    ///   - pageCardView: 卡片切换组件
    ///   - row: 索引
    /// - Returns: 布局样式对象
    func pageCardView(_ pageCardView: CHPageCardView, cellForIndexAt index: Int) -> UICollectionViewCell
    
    
    /// 选择卡片方法
    ///
    /// - Parameters:
    ///   - pageCardView: 卡片切换组件
    ///   - row: 选中的索引
    func pageCardView(_ pageCardView: CHPageCardView, didSelectIndexAt index: Int)
    
}


/// 横向切换的卡片选择组件
/*
 实现原理：
 1.初始化后，注册用户自定义的Cell视图到组件的collectionView
 2.建立所有View，通过委托方法获取数据源，实现UICollectionView的代理方法
 3.滑动过程响应相关委托方法，返回数据
 
 */
public class CHPageCardView: UIView {
    
    
    /// 卡片控制的主视图
    public var collectionView: UICollectionView!
    
    
    /// 页面数显示
    public var pageControl: UIPageControl!
    
    //单元格之间的间距
    @IBInspectable public var fixLineSpace: CGFloat = 0 {
        didSet {
            if self.layout != nil {
                self.layout.minimumLineSpacing = self.fixLineSpace
            }
        }
    }
    
    //单元格的固定大小
    @IBInspectable public var fixCellSize: CGSize = CGSize.zero {
        didSet {
            if self.layout != nil {
                self.layout.itemSize = self.fixCellSize
            }
        }
    }
    
    
    /// 单元格固定内间距，如果使用了fixPadding，则fixCellSize不起效果
    @IBInspectable public var fixPadding: UIEdgeInsets = UIEdgeInsets.zero
    
    @IBInspectable public var bgImage: UIImage? {
        didSet {
            self.backgroundView.image = self.bgImage!
            self.backgroundView.isHidden = false
        }
    }
    
    /// 布局控制
    var layout: CHPageCardFlowLayout!
    
    var backgroundView: UIImageView!
    
    @IBOutlet public weak var delegate: CHPageCardViewDelegate?
    
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        self.setupUI()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if self.fixPadding != .zero {
            //如果设置了固定内间距，重新计算cell的尺寸
            let vPadding = self.fixPadding.top > self.fixPadding.bottom ? self.fixPadding.top : self.fixPadding.bottom
            let hPadding = self.fixPadding.left > self.fixPadding.right ? self.fixPadding.left : self.fixPadding.right
            
            let height = self.bounds.size.height - vPadding * 2
            let width = self.bounds.size.width - (hPadding + self.fixLineSpace) * 2
            
            self.fixCellSize = CGSize(width: width, height: height)
        }
    }
    
    
    /// 初始化布局
    func setupUI() {
        
        /********* 初始化 *********/
        self.layout = CHPageCardFlowLayout()
        self.layout.delegate = self
        self.layout.itemSize = self.fixCellSize
        self.layout.minimumLineSpacing = self.fixLineSpace
        
        self.collectionView = UICollectionView(frame: CGRect.zero,
                                               collectionViewLayout: self.layout)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.collectionView)
        self.collectionView.decelerationRate = 0;
        self.collectionView.showsHorizontalScrollIndicator = false;
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = UIColor.clear

        
        self.pageControl = UIPageControl()
        self.pageControl.translatesAutoresizingMaskIntoConstraints = false
        self.pageControl.pageIndicatorTintColor = UIColor(white: 1, alpha: 0.3)
        self.addSubview(self.pageControl)
        
        self.backgroundView = UIImageView()
        self.backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundView.isHidden = true
        self.addSubview(self.backgroundView)
        
        /********* 约束布局 *********/
        
        let views: [String : Any] = [
            "collectionView": self.collectionView,
            "pageControl": self.pageControl,
            "backgroundView": self.backgroundView
        ]
        
        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[pageControl]-0-|",
            options: NSLayoutFormatOptions(),
            metrics: nil,
            views:views))
        
        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:[pageControl(30)]-0-|",
            options: NSLayoutFormatOptions(),
            metrics: nil,
            views:views))
        
        
        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[collectionView]-0-|",
            options: NSLayoutFormatOptions(),
            metrics: nil,
            views:views))
        
        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-0-[collectionView]-0-[pageControl]",
            options: NSLayoutFormatOptions(),
            metrics: nil,
            views:views))
        
        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[backgroundView]-0-|",
            options: NSLayoutFormatOptions(),
            metrics: nil,
            views:views))
        
        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-0-[backgroundView]-0-|",
            options: NSLayoutFormatOptions(),
            metrics: nil,
            views:views))
 
    }
    
    
    /// 获取一个可重用的单元格
    ///
    /// - Parameters:
    ///   - identifier:
    ///   - index:
    /// - Returns:
    public func dequeueReusableCell(withReuseIdentifier identifier: String, for index: Int) -> UICollectionViewCell {
        return self.collectionView.dequeueReusableCell(withReuseIdentifier: identifier,
                                                for: IndexPath(row: index, section: 0))
    }
    
    
    /// 注册一个可重用的识别名
    public func register(cellClass: Swift.AnyClass?, forCellWithReuseIdentifier identifier: String) {
        self.collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    /// 注册一个可重用的识别名
    public func register(nib: UINib?, forCellWithReuseIdentifier identifier: String) {
        self.collectionView.register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    
    /// 滚动到某个位置
    ///
    /// - Parameters:
    ///   - index:  滚动的目标索引未
    ///   - animated:   是否动画
    open func scroll(toIndex index: Int, animated animated: Bool) {
        let indexPath = IndexPath(row: index, section: 0)
        let attr = self.collectionView.layoutAttributesForItem(at: indexPath)

        self.collectionView.scrollToItem(at: attr!.indexPath, at: .centeredHorizontally, animated: animated)
        
        self.layout.previousOffsetX = CGFloat(index) * (self.fixCellSize.width + self.fixLineSpace)
        self.pageControl.currentPage = index
    }
    
    
    /// 重新加载
    open func reloadData() {
        if self.collectionView != nil {
            self.collectionView.reloadData()
        }
    }
    
    
    /// 更新索引位单元格对象
    ///
    /// - Parameter index: 索引位
    open func reloadItems(at index: Int, animated animated: Bool = true) {
        let indexPath = IndexPath(row: index, section: 0)
        if animated {
            self.collectionView.reloadItems(at: [indexPath])
        } else {
            UIView.performWithoutAnimation {
                self.collectionView.reloadItems(at: [indexPath])
            }
        }
    }
}


// MARK: - 实现布局控制委托方法
extension CHPageCardView: CHPageCardFlowLayoutDelegate {
    
    func scrollToPageIndex(index: Int) {
        self.pageControl.currentPage = index
        self.delegate?.pageCardView(self, didSelectIndexAt: index)
    }
    
}


// MARK: - 实现CollectionView的委托方法
extension CHPageCardView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = self.delegate?.numberOfCards(in: self) ?? 0
        self.pageControl.numberOfPages = count
        return count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return self.delegate!.pageCardView(self, cellForIndexAt: indexPath.row)
    }
    
}
