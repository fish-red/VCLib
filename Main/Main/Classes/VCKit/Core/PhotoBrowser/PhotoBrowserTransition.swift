//
//  Transition.swift
//  Main
//
//  Created by 陈文强 on 16/8/24.
//  Copyright © 2016年 CWQ. All rights reserved.
//

import Foundation
//
////#MARK: - Protocol
//public protocol BrowserTransitionSource {
//    var currentIndexPath: NSIndexPath? {set get}
//    var collectionView: UICollectionView? {set get}
//}
//
//public protocol BrowserTrasitionDestination {
//    var view: UIView? {set get}
//}
//
//
//public protocol BrowserTransitionCell {
//    var indexPath: NSIndexPath? {set get}
//    var imageView: UIImageView? {set get}
//}
//
//
////#MARK: - --- BrowserAnimatedTransitioning ---
//open class BrowserAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
//    open var duration: NSTimeInterval = 2
//    open func transitionDuration(_ transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
//        return duration
//    }
//    
//    open func animateTransition(_ transitionContext: UIViewControllerContextTransitioning) {
//        // get toVc and fromVc
//        var fromVc = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as? BrowserTransitionSource
//        if fromVc == nil {
//            if let rootVc = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as? MainPageViewController {
//                fromVc = rootVc.viewControllers[rootVc.currentIdx] as? BrowserTransitionSource
//            }
//        }
//        
//        let toVc = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) // as? BrowserTrasitionDestination
//        
//        guard fromVc != nil && toVc != nil && fromVc?.currentIndexPath != nil else {
//            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
//            return
//        }
//        
//        // get cell
//        let cell = fromVc?.collectionView?.cellForItemAtIndexPath((fromVc!.currentIndexPath)!) as? BrowserTransitionCell
//        guard cell != nil else {
//            return
//        }
//        
//        // get containerView
//        let containView = transitionContext.containerView()
//        
//        // conver point
//        let rect = containView?.convertRect((cell?.imageView?.frame)!, fromView: (cell?.imageView?.superview)!)
//        guard rect != nil else {
//            return
//        }
//        
//        // get snapView
//        let coverView = UIView()
//        coverView.backgroundColor = UIColor.blackColor()
//        coverView.frame = (toVc!.view?.frame)!
//        
//        let snapView = UIImageView()
//        snapView.contentMode = .ScaleAspectFill
//        snapView.clipsToBounds = true
//        snapView.image = cell?.imageView?.image
//        snapView.frame = rect!
//        
//        // get hide cell
//        cell?.imageView?.hidden = true
//        
//        // transition
//        toVc?.view?.frame = transitionContext.finalFrameForViewController(toVc!)
//        coverView.frame = (toVc?.view?.frame)!
//        
//        
//        // add to containview
//        containView?.addSubview((toVc?.view)!)
//        containView?.addSubview(coverView)
//        containView?.addSubview(snapView)
//        
//        
//        // counting
//        let imageSize = (snapView.image?.size)!
//        let targetSize = (toVc?.view?.bounds.size)!
//        var width: CGFloat = 0
//        var height: CGFloat = 0
//        
//        if imageSize.width >= imageSize.height {
//            // 横图
//            width = targetSize.width
//            height = targetSize.width*(imageSize.height/imageSize.width)
//        }else {
//            // 竖图
////            if targetSize.height/targetSize.width <= imageSize.height/imageSize.width {
////                height = targetSize.height
////                width = targetSize.height*(imageSize.width/imageSize.height)
////            }else {
//                width = targetSize.width
//                height = targetSize.width*(imageSize.height/imageSize.width)
////            }
//        }
//        
//        let renderRect = CGRectMake((targetSize.width-width)*0.5, (targetSize.height-height)*0.5, width, height)
//        
//        // animation
//        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .CurveEaseInOut, animations: { 
//            snapView.frame = renderRect
//            }) { (suc) in
//                // show cell
//                cell?.imageView?.hidden = false
//            
//                // remove
//                snapView.removeFromSuperview()
//                coverView.removeFromSuperview()
//                
//                // complete
//                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
//        }
//    }
//}
//
//
////#MARK: - --- BrowserInteractiveTransitioning ---
//open class BrowserInteractiveTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
//    open var duration: NSTimeInterval = 0.45
//    open func transitionDuration(_ transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
//        return duration
//    }
//    
//    open func animateTransition(_ transitionContext: UIViewControllerContextTransitioning) {
//        // get toVc and fromVc
//        let fromVc = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
//        
//        var toVc = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as? BrowserTransitionSource
//        if toVc == nil {
//            if let rootVc = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as? MainPageViewController {
//                toVc = rootVc.viewControllers[rootVc.currentIdx] as? BrowserTransitionSource
//            }
//        }
//        
//        
//        guard fromVc != nil && toVc != nil && toVc?.currentIndexPath != nil else {
//            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
//            return
//        }
//        
//        // get cell
//        let cell = toVc?.collectionView?.cellForItemAtIndexPath((toVc!.currentIndexPath)!) as? BrowserTransitionCell
//        guard cell != nil else {
//            return
//        }
//    }
//}
//



