//
//  ViewController.swift
//  UIViewControllerTransitionCoordinatorBug
//
//  Created by Kazuhiro Hayashi on 2018/09/17.
//  Copyright © 2018 kazuhiro hayashi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var percentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.delegate = self
        let edgeSwipeGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        edgeSwipeGestureRecognizer.edges = .left
        navigationController?.view.addGestureRecognizer(edgeSwipeGestureRecognizer)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func handleSwipe(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        guard let view = gestureRecognizer.view else {
            fatalError()
        }
        
        let percent = gestureRecognizer.translation(in: view).x / view.bounds.size.width
        if gestureRecognizer.state == .began {
            percentDrivenInteractiveTransition = UIPercentDrivenInteractiveTransition()
            navigationController?.popViewController(animated: true)
        } else if gestureRecognizer.state == .changed {
            percentDrivenInteractiveTransition?.update(percent)
        } else if gestureRecognizer.state == .ended {
            if percent > 0.5 && gestureRecognizer.state != .cancelled {
                percentDrivenInteractiveTransition?.finish()
            } else {
                percentDrivenInteractiveTransition?.cancel()
            }
            percentDrivenInteractiveTransition = nil
        }
    }
}


extension ViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        if let vc = transitionCoordinator?.viewController(forKey: .from) as? SecondViewController {
            transitionCoordinator?.animateAlongsideTransition(in: navigationController.view, animation: { (_) in
                vc.contentView.layer.cornerRadius = 0
                vc.contentView.backgroundColor = .red
            }, completion: { context in
                
            })
//            vc.contentView.layer.cornerRadius = 0
//            vc.contentView.backgroundColor = .red
        } else if let vc = transitionCoordinator?.viewController(forKey: .to) as? SecondViewController {
            transitionCoordinator?.animateAlongsideTransition(in: navigationController.view, animation: { (_) in
                vc.contentView.layer.cornerRadius = 150
                vc.contentView.backgroundColor = .blue
            }, completion: nil)
//            vc.contentView.layer.cornerRadius = 150
//            vc.contentView.backgroundColor = .blue
        }
    }
//
//        func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//            return operation == .push ? CustomPushAnimator() : CustomPopAnimator()
//        }
//
//        func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//            return percentDrivenInteractiveTransition
//        }
}


class CustomPushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to),
            let fromVC = transitionContext.viewController(forKey: .from) else {
                fatalError()
        }
        
        
        let overlayView = UIView()
        overlayView.frame = transitionContext.containerView.frame
        overlayView.backgroundColor = UIColor(white: 0, alpha: 0)
        transitionContext.containerView.insertSubview(overlayView, aboveSubview: fromVC.view)
        
        let finalFrameToVC = transitionContext.finalFrame(for: toVC)
        
        toVC.view.frame = finalFrameToVC
        toVC.view.frame.origin.x = transitionContext.containerView.bounds.width
        transitionContext.containerView.addSubview(toVC.view)
        
        toVC.view.layer.masksToBounds = false
        toVC.view.layer.shadowOpacity = 0.2
        toVC.view.layer.shadowRadius = 8
        toVC.view.layer.shadowColor = UIColor.black.cgColor
        toVC.view.layer.shadowOffset = CGSize(width: -1, height: 0)
        toVC.view.layer.shouldRasterize = true
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            fromVC.view.frame.origin.x = -(transitionContext.containerView.bounds.width * 0.2)
            toVC.view.frame = finalFrameToVC
            overlayView.backgroundColor = UIColor(white: 0, alpha: 0.1)
        }) { (finished) in
            overlayView.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}


class CustomPopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) else {
                fatalError()
        }
        
        toVC.view.frame = transitionContext.finalFrame(for: toVC)
        toVC.view.frame.origin.x = -(transitionContext.containerView.bounds.width * 0.2)
        transitionContext.containerView.insertSubview(toVC.view, at: 0)
        
        let overlayView = UIView()
        overlayView.frame = transitionContext.containerView.frame
        overlayView.backgroundColor = UIColor(white: 0, alpha: 0.1)
        transitionContext.containerView.insertSubview(overlayView, aboveSubview: toVC.view)
        
        fromVC.view.layer.masksToBounds = false
        fromVC.view.layer.shadowOpacity = 0.2
        fromVC.view.layer.shadowRadius = 8
        fromVC.view.layer.shadowColor = UIColor.black.cgColor
        fromVC.view.layer.shadowOffset = CGSize(width: -1, height: 0)
        fromVC.view.layer.shouldRasterize = true
        
        if transitionContext.isInteractive {
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveLinear, animations: {
                fromVC.view.frame.origin.x = transitionContext.containerView.frame.maxX
                toVC.view.frame.origin.x = 0
                overlayView.backgroundColor = .clear

            }, completion: { _ in
                overlayView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        } else {
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                fromVC.view.frame.origin.x = transitionContext.containerView.frame.maxX
                toVC.view.frame.origin.x = 0
                overlayView.backgroundColor = .clear

            }) { (finished) in
                overlayView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
}
