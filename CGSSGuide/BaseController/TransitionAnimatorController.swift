//
//  TransitionAnimatorController.swift
//  CGSSGuide
//
//  Created by zzk on 2017/6/13.
//  Copyright © 2017年 zzk. All rights reserved.
//

import UIKit

struct TransitionTypes: OptionSet {
    init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    let rawValue: UInt
    static let pop = TransitionTypes.init(rawValue: 1 << 0)
    static let push = TransitionTypes.init(rawValue: 1 << 1)
    static let present = TransitionTypes.init(rawValue: 1 << 2)
    static let dismiss = TransitionTypes.init(rawValue: 1 << 3)
    static let interactive = TransitionTypes.init(rawValue: 1 << 4)
    static let all: TransitionTypes = [.pop, .push, .present, .dismiss, .interactive]
    
    init(operation: UINavigationControllerOperation) {
        switch operation {
        case .pop:
            self = .pop
        case .push:
            self = .push
        default:
            self = []
        }
    }
}

protocol Transitionable {
    var transitionViews: [String: UIView] { get }
    var transitionTypes: TransitionTypes { get }
}

extension Transitionable {
    var transitionTypes: TransitionTypes {
        return .all
    }
}

extension CGAffineTransform {
    init(from: CGRect, toRect to: CGRect) {
        self.init(translationX: to.midX-from.midX, y: to.midY-from.midY)
        self = self.scaledBy(x: to.width/from.width, y: to.height/from.height)
    }
}

class TransitionAnimatorController: NSObject, UIViewControllerAnimatedTransitioning {
    
    var transitionTypes: TransitionTypes
    
    init(transitionTypes: TransitionTypes) {
        self.transitionTypes = transitionTypes
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if let isAnimated = transitionContext?.isAnimated {
            return isAnimated ? 0.35 : 0
        } else {
            return 0
        }
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let toView = transitionContext.view(forKey: .to),
            let fromView = transitionContext.view(forKey: .from)
        else {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            return
        }
        
        guard let toViewController = transitionContext.viewController(forKey: .to) as? Transitionable,
        let fromViewController = transitionContext.viewController(forKey: .from) as? Transitionable
        else {
            transitionContext.containerView.addSubview(toView)
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            return
        }
        
        transitionContext.containerView.insertSubview(toView, belowSubview: fromView)
        toView.layoutIfNeeded()
        
        var transforms = [String: CGAffineTransform]()
        for (id, sourceView) in fromViewController.transitionViews {
            if let destView = toViewController.transitionViews[id] {
                let sourceFrame = sourceView.convert(sourceView.bounds, to: transitionContext.containerView)
                let destFrame = destView.convert(destView.bounds, to: transitionContext.containerView)
//                if #available(iOS 11.0, *) {
//                    var frame = destView.convert(destView.bounds, to: transitionContext.containerView)
////                    frame.origin.y -= (fromViewController as? UIViewController)?.navigationController?.navigationBar.frame.maxY ?? 0
//                    destFrame = frame
//                } else {
//                    destFrame = destView.convert(destView.bounds, to: transitionContext.containerView)
//                }
                let transform = CGAffineTransform.init(from: sourceFrame, toRect: destFrame)
                let negativeTransform = CGAffineTransform.init(from: destFrame, toRect: sourceFrame)
                transforms[id] = transform
                destView.transform = negativeTransform
            }
        }
        
        let duration = self.transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            fromView.alpha = 0
            for (id, sourceView) in fromViewController.transitionViews {
                if let destView = toViewController.transitionViews[id] {
                    sourceView.transform = transforms[id] ?? .identity
                    destView.transform = .identity
                }
            }
        }) { (finished) in
            for (_, sourceView) in fromViewController.transitionViews {
                sourceView.transform = .identity
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    /*
    func animationEnded(_ transitionCompleted: Bool) {
        
    }
    */
}
