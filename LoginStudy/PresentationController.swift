//
//  PresentationController.swift
//  LoginStudy
//
//  Created by 김도현 on 2024/05/02.
//

import Foundation
import UIKit

final class PresentationController: UIPresentationController {
    
    private var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
    private let size: CGFloat
    private let blurEffect = UIView()
    
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, size: CGFloat) {
        blurEffect.backgroundColor = .black
        self.size = size
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissController))
        self.blurEffect.isUserInteractionEnabled = true
        self.blurEffect.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        let screenSize = UIScreen.main.bounds.size
        return CGRect(origin: CGPoint(x: 0, y: screenSize.height * (1 - size)), size: CGSize(width: screenSize.width, height: screenSize.height * size))
    }
    
    override func presentationTransitionWillBegin() {
        self.blurEffect.alpha = 0
        self.containerView?.addSubview(blurEffect)
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffect.alpha = 0.7
        }, completion: { (UIViewControllerTransitionCoordinatorContext) in })
    }
    
    override func dismissalTransitionWillBegin() {
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffect.alpha = 0
        }, completion: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffect.removeFromSuperview()
        })
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView!.roundCorners([.topLeft, .topRight], radius: 22)
    }

    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
        blurEffect.frame = containerView!.bounds
    }
    
    @objc func dismissController(){
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }
}

extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
