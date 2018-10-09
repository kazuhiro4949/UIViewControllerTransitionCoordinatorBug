//
//  NavigationController.swift
//  UIViewControllerTransitionCoordinatorBug
//
//  Created by Kazuhiro Hayashi on 2018/10/09.
//  Copyright © 2018 kazuhiro hayashi. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    let globalView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
    
    var percentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition?

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        view.addSubview(globalView)
        globalView.translatesAutoresizingMaskIntoConstraints = false
        globalView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        globalView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        globalView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        globalView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        
        let edgeSwipeGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        edgeSwipeGestureRecognizer.edges = .left
        view.addGestureRecognizer(edgeSwipeGestureRecognizer)
    }
    
    @objc func handleSwipe(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        guard let view = gestureRecognizer.view else {
            fatalError()
        }
        
        let percent = gestureRecognizer.translation(in: view).x / view.bounds.size.width
        if gestureRecognizer.state == .began {
            percentDrivenInteractiveTransition = UIPercentDrivenInteractiveTransition()
            popViewController(animated: true)
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

extension NavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        if transitionCoordinator?.viewController(forKey: .from) is SecondViewController {
            transitionCoordinator?.animateAlongsideTransition(in: navigationController.view, animation: { [globalView] (_) in
                globalView.layer.cornerRadius = 0
                globalView.backgroundColor = .red
            }, completion: { context in
                
            })
        } else if transitionCoordinator?.viewController(forKey: .to) is SecondViewController {
            transitionCoordinator?.animateAlongsideTransition(in: navigationController.view, animation: { [globalView] (_) in
                globalView.layer.cornerRadius = 40
                globalView.backgroundColor = .blue
            }, completion: nil)
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return operation == .push ? CustomPushAnimator() : CustomPopAnimator()
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return percentDrivenInteractiveTransition
    }
}











// MARK:- Custom Transition

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
        toVC.view.layer.rasterizationScale = UIScreen.main.scale
        
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
        fromVC.view.layer.rasterizationScale = UIScreen.main.scale
        
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
