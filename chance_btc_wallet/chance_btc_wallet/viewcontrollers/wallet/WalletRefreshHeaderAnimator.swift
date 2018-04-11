//
//  WalletRefreshHeaderAnimator.swift
//  chance_btc_wallet
//
//  Created by Chance on 2017/3/3.
//  Copyright © 2017年 chance. All rights reserved.
//

import UIKit
import ESPullToRefresh

public class WalletRefreshHeaderAnimator: UIView, ESRefreshProtocol, ESRefreshAnimatorProtocol {

    public var insets: UIEdgeInsets = UIEdgeInsets.zero
    public var view: UIView { return self }
    public var duration: TimeInterval = 0.3
    public var trigger: CGFloat = 60
    public var executeIncremental: CGFloat = 60
    public var state: ESRefreshViewState = .pullToRefresh
    
    private var timer: Timer?
    private var timerProgress: Double = 0.0
    
    private var imageViewLoadingCircular: UIImageView!
    
    private var imageViewLoadingLogo: UIImageView!

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.imageViewLoadingCircular = UIImageView()
        self.imageViewLoadingCircular.image = UIImage.init(named: "loading_circular")
        self.imageViewLoadingCircular.sizeToFit()
        let size = self.imageViewLoadingCircular.image?.size ?? CGSize.zero
        self.imageViewLoadingCircular.center = CGPoint(x: UIScreen.main.bounds.size.width / 2.0, y: -size.height)
        self.addSubview(self.imageViewLoadingCircular)
        
        self.imageViewLoadingLogo = UIImageView()
        self.imageViewLoadingLogo.image = UIImage(named: "loading_logo")
        self.imageViewLoadingLogo.sizeToFit()
        self.imageViewLoadingLogo.center = self.imageViewLoadingCircular.center
        self.addSubview(self.imageViewLoadingLogo)
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func refreshAnimationBegin(view: ESRefreshComponent) {
        self.imageViewLoadingCircular.center = self.center
        self.imageViewLoadingLogo.center = self.center
        self.startAnimating()
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            let y = self.bounds.size.height - self.trigger / 2
            let center = CGPoint(x: UIScreen.main.bounds.size.width / 2.0, y: y)
            self.imageViewLoadingCircular.center = center
            self.imageViewLoadingLogo.center = center
        }, completion: { (finished) in })
    }
    
    public func refreshAnimationEnd(view: ESRefreshComponent) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {

            self.imageViewLoadingCircular.transform = CGAffineTransform.identity
            self.imageViewLoadingCircular.center = CGPoint(x: UIScreen.main.bounds.size.width / 2.0, y: -self.trigger / 2)
            self.imageViewLoadingLogo.center = self.imageViewLoadingCircular.center
        }, completion: { (finished) in
            self.stopAnimating()
        })
    }
    
    public func refresh(view: ESRefreshComponent, progressDidChange progress: CGFloat) {

        let y = self.bounds.size.height - self.trigger / 2
        let center = CGPoint(x: UIScreen.main.bounds.size.width / 2.0, y: y)
        self.imageViewLoadingCircular.center = center
        self.imageViewLoadingLogo.center = center
        self.imageViewLoadingCircular.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI) * progress)
    }
    
    public func refresh(view: ESRefreshComponent, stateDidChange state: ESRefreshViewState) {
        guard self.state != state else {
            return
        }
        self.state = state
    }
    
    @objc func timerAction() {
        timerProgress += 0.01
        self.imageViewLoadingCircular.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI) * CGFloat(timerProgress))
    }
    
    func startAnimating() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true)
            RunLoop.current.add(timer!, forMode: RunLoopMode.commonModes)
        }
    }
    
    func stopAnimating() {
        if timer != nil {
            timerProgress = 0.0
            timer?.invalidate()
            timer = nil
        }
    }
    
}
