//
//  CHPageCardFlowLayout.swift
//  Pods
//
//  Created by Chance on 2017/2/27.
//
//

import UIKit

protocol CHPageCardFlowLayoutDelegate: class {

    func scrollToPageIndex(index: Int)

}


/// 卡片组内元素布局控制
/// 教程在http://llyblog.com/2016/09/01/iOS卡片控件的实现/
class CHPageCardFlowLayout: UICollectionViewFlowLayout {

    var previousOffsetX: CGFloat = 0
    
    /// 当前页码
    var pageNum: Int = 0
    
    weak var delegate: CHPageCardFlowLayoutDelegate?
    
    
    /// 重载准备方法
    override func prepare() {
        super.prepare()
        //滑动方向
        self.scrollDirection = .horizontal
        //计算cell超出显示的宽度
        let width = ((self.collectionView!.frame.size.width - self.itemSize.width) - (self.minimumLineSpacing * 2)) / 2
        //每个section的间距
        self.sectionInset = UIEdgeInsetsMake(0, self.minimumLineSpacing + width, 0, self.minimumLineSpacing + width)
    }
    
    
    /// 控制元素布局的属性的动态变化
    ///
    /// - Parameter rect:
    /// - Returns:
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let attributes = super.layoutAttributesForElements(in: rect)
        
        let visibleRect = CGRect(
            x: self.collectionView!.contentOffset.x,
            y: self.collectionView!.contentOffset.y,
            width: self.collectionView!.frame.size.width,
            height: self.collectionView!.frame.size.height)
        
        let offset = visibleRect.midX
        
        for attribute in attributes! {
            
            let distance = offset - attribute.center.x
            // 越往中心移动，值越小，从而显示就越大
            // 同样，超过中心后，越往左、右走，显示就越小
            let scaleForDistance = distance / self.itemSize.width
            // 0.1可调整，值越大，显示就越小
            let scaleForCell = 1 - 0.1 * fabs(scaleForDistance)
            
            //只在Y轴方向做缩放，这样中间的那个distance = 0，不进行缩放，非中心的缩小
            attribute.transform3D =  CATransform3DMakeScale(1, scaleForCell, 1)
            attribute.zIndex = 1
            
            //渐变
            let scaleForAlpha = 1 - fabsf(Float(scaleForDistance)) * 0.6
            attribute.alpha = CGFloat(scaleForAlpha)
        }
        
        return attributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    
    /// 控制滑动元素目标落点的位置
    ///
    /// - Parameters:
    ///   - proposedContentOffset:
    ///   - velocity:
    /// - Returns:
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        // 分页以1/3处
        if proposedContentOffset.x > self.previousOffsetX + self.itemSize.width / 3.0 {
            self.previousOffsetX += self.itemSize.width + self.minimumLineSpacing
            self.pageNum = Int(self.previousOffsetX / (self.itemSize.width + self.minimumLineSpacing))
            self.delegate?.scrollToPageIndex(index: self.pageNum)
        } else if proposedContentOffset.x < self.previousOffsetX - self.itemSize.width / 3.0 {
            self.previousOffsetX -= self.itemSize.width + self.minimumLineSpacing
            self.pageNum = Int(self.previousOffsetX / (self.itemSize.width + self.minimumLineSpacing))
            self.delegate?.scrollToPageIndex(index: self.pageNum)
        }
        
        //将当前cell移动到屏幕中间位置
        let newPoint = CGPoint(x: self.previousOffsetX, y: proposedContentOffset.y)
        
        return newPoint
        
    }

}
