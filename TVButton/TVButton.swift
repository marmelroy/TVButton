//
//  TVButton.swift
//  TVButton
//
//  Created by Roy Marmelstein on 08/11/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

/**
Parallax Layer Object
 
- Image: UIImage to display. It is essential that all images have the same dimensions.
*/
public struct TVButtonLayer {
    public var internalImage: UIImage?
}

public extension TVButtonLayer {
    public init(image: UIImage) {
        self.init(internalImage: image)
    }
}

/**
 TVButton Object
 
 - layers: Provide the layers for the parallax button.
 - shadowColor: Provide the dominant colour of your background for an even better shadow.

 */
public class TVButton: UIButton, UIGestureRecognizerDelegate {
    
    var specularView = UIImageView()
    var containerView = UIView()
    var panGestureRecognizer: UIPanGestureRecognizer?
    var tapGestureRecognizer: UITapGestureRecognizer?
    var longPressGestureRecognizer: UILongPressGestureRecognizer?
    var highlightMode: Bool = false

    let maxRotation: CGFloat = 10
    let maxTranslation: CGFloat = 2
    let specularScale: CGFloat = 2.0
    let highlightedScale: CGFloat = 1.17
    let shadowFactor: CGFloat = 12
    let cornerRadius: CGFloat = 5
    
    public var shadowColor : UIColor? {
        didSet {
            self.layer.shadowColor = shadowColor!.CGColor
        }
    }
    
    public var layers : [TVButtonLayer]? {
        didSet {
            // Remove existing parallax layer views
            for subview in containerView.subviews {
                subview.removeFromSuperview()
            }
            for layer in layers! {
                let imageView = UIImageView(image: layer.internalImage)
                imageView.layer.cornerRadius = cornerRadius
                imageView.clipsToBounds = true
                containerView.addSubview(imageView)
            }
            let frameworkBundle = NSBundle(forClass: TVButton.self)
            let specularViewPath = frameworkBundle.pathForResource("Specular", ofType: "png")
            specularView.image = UIImage(contentsOfFile:specularViewPath!)
            self.containerView.addSubview(specularView)
        }
    }
    
    // MARK: Lifecycle
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        containerView.frame = self.bounds
        // Adjust size for every subview
        for subview in containerView.subviews {
            if subview == specularView {
                subview.frame = CGRect(origin: subview.frame.origin, size: CGSizeMake(specularScale * containerView.frame.size.width, specularScale * containerView.frame.size.height))
            }
            else {
                subview.frame = CGRect(origin: subview.frame.origin, size: containerView.frame.size)
            }
        }
        self.layer.masksToBounds = false;
        let shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius)
        self.layer.shadowPath = shadowPath.CGPath
    }
    
    
    func setup() {
        containerView.userInteractionEnabled = false
        self.addSubview(containerView)
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        specularView.alpha = 0.0
        specularView.contentMode = UIViewContentMode.ScaleAspectFill
        self.shadowColor = UIColor.blackColor()
        self.layer.shadowRadius = self.bounds.size.height/(2*shadowFactor)
        self.layer.shadowOffset = CGSizeMake(0.0, shadowFactor/3)
        self.layer.shadowOpacity = 0.5;
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        panGestureRecognizer?.delegate = self
        self.addGestureRecognizer(panGestureRecognizer!)
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
        self.addGestureRecognizer(tapGestureRecognizer!)
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        longPressGestureRecognizer?.delegate = self
        self.addGestureRecognizer(longPressGestureRecognizer!)
    }
    
    // MARK: UIGestureRecognizer Actions
    
    
    func handlePan(gestureRecognizer: UIGestureRecognizer) {
        if layers == nil {
            return
        }
        if gestureRecognizer.state == .Began {
            self.enterMovement(0.4)
        }
        else if gestureRecognizer.state == .Changed {
            self.processMovement(gestureRecognizer)
        }
        else {
            self.exitMovement()
        }
    }

    
    func handleLongPress(gestureRecognizer: UIGestureRecognizer) {
        if layers == nil {
            return
        }
        if gestureRecognizer.state == .Began {
            self.enterMovement(0.2)
        }
        else {
            self.exitMovement()
        }
    }
    
    func handleTap(gestureRecognizer: UIGestureRecognizer) {
        super.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
        self.animateTap()
    }
    
    
    // MARK: Animations
    
    func enterMovement(duration: Double) {
        if highlightMode == true {
            return
        }
        else {
            highlightMode = true
        }
        let targetScaleTransform = CATransform3DMakeScale(highlightedScale, highlightedScale, highlightedScale)
        let targetShadowOffset = CGSizeMake(0.0, self.bounds.size.height/shadowFactor)
        CATransaction.begin()
        CATransaction.setCompletionBlock({ () -> Void in
            self.layer.transform = targetScaleTransform
            self.layer.shadowOffset = targetShadowOffset
            self.layer.removeAllAnimations()
        })
        let scaleAnimation = CABasicAnimation(keyPath: "transform")
        scaleAnimation.toValue = NSValue(CATransform3D: targetScaleTransform)
        scaleAnimation.duration = duration
        scaleAnimation.removedOnCompletion = false
        scaleAnimation.fillMode = kCAFillModeForwards
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: "easeOut")
        self.layer.addAnimation(scaleAnimation, forKey: "scaleAnimation")
        let shaowOffsetAnimation = CABasicAnimation(keyPath: "shadowOffset")
        shaowOffsetAnimation.toValue = NSValue(CGSize: targetShadowOffset)
        shaowOffsetAnimation.duration = duration
        shaowOffsetAnimation.removedOnCompletion = false
        shaowOffsetAnimation.fillMode = kCAFillModeForwards
        shaowOffsetAnimation.timingFunction = CAMediaTimingFunction(name: "easeOut")
        self.layer.addAnimation(shaowOffsetAnimation, forKey: "shadowOffset")
        CATransaction.commit()
    }
    
    func animateTap() {
        highlightMode = false
        UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.6, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(0.93, 0.93)
            }) { (finished) -> Void in
                UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.6, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                    self.transform = CGAffineTransformMakeScale(1.0, 1.0)
                    }) { (finished) -> Void in
                        
                }
        }
    }
    
    func exitMovement() {
        if highlightMode == false || longPressGestureRecognizer?.state == .Began || longPressGestureRecognizer?.state == .Changed || panGestureRecognizer?.state == .Began || panGestureRecognizer?.state == .Changed  {
            return
        }
        else {
            highlightMode = false
        }
        let targetShadowOffset = CGSizeMake(0.0, shadowFactor/3)
        CATransaction.begin()
        CATransaction.setCompletionBlock({ () -> Void in
            self.layer.shadowOffset = targetShadowOffset
            self.layer.removeAllAnimations()
        })
        let shaowOffsetAnimation = CABasicAnimation(keyPath: "shadowOffset")
        shaowOffsetAnimation.toValue = NSValue(CGSize: targetShadowOffset)
        shaowOffsetAnimation.duration = 0.4
        shaowOffsetAnimation.fillMode = kCAFillModeForwards
        shaowOffsetAnimation.removedOnCompletion = false
        shaowOffsetAnimation.timingFunction = CAMediaTimingFunction(name: "easeOut")
        self.layer.addAnimation(shaowOffsetAnimation, forKey: "shadowOffset")
        CATransaction.commit()
        UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.transform = CGAffineTransformIdentity
            self.specularView.alpha = 0.0
            for var i = 0; i < self.containerView.subviews.count ; i++ {
                let subview = self.containerView.subviews[i]
                subview.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)
            }
        }, completion:nil)
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func processMovement(gestureRecognizer: UIGestureRecognizer){
        let point = gestureRecognizer.locationInView(self)
        if (CGRectContainsPoint(self.bounds, point) == false || highlightMode == false) {
            return
        }
        let xRotationDegrees = (calculateTransform(point.x, dimension: self.bounds.size.width)) * maxRotation
        let yRotationDegrees = (calculateTransform(point.y, dimension: self.bounds.size.height) * -1) * maxRotation
        let xTranslation = (calculateTransform(point.x, dimension: self.bounds.size.width)) * maxTranslation
        let yTranslation = (calculateTransform(point.y, dimension: self.bounds.size.height)) * maxTranslation
        
        let translationAverage = (calculateTransform(point.y, dimension: self.bounds.size.height) + calculateTransform(point.x, dimension: self.bounds.size.width))/2
        print(translationAverage)
        
        let xRotateTransform = CATransform3DMakeRotation(degreesToRadians(xRotationDegrees), 1, 0, 0)
        let yRotateTransform = CATransform3DMakeRotation(degreesToRadians(yRotationDegrees), 0, 1, 0)
        
        var combinedRotateTransform = CATransform3DConcat(xRotateTransform, yRotateTransform)
        combinedRotateTransform.m34 = 1.0 / 1000.0
        
        let translationTransform = CATransform3DMakeTranslation(-xTranslation, yTranslation, 0.0)
        let combinedRotateTranslateTransform = CATransform3DConcat(combinedRotateTransform, translationTransform)
        let targetScaleTransform = CATransform3DMakeScale(highlightedScale, highlightedScale, highlightedScale)
        let combinedTransform = CATransform3DConcat(combinedRotateTranslateTransform, targetScaleTransform)

        UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.layer.transform = combinedTransform
            self.specularView.alpha = 0.3
            self.specularView.center = point
            }, completion: nil)
        for var i = 1; i < containerView.subviews.count ; i++ {
            let subview = containerView.subviews[i]
            if subview != specularView {
                subview.center = CGPointMake(self.bounds.size.width/2 + xTranslation*CGFloat(i)*0.5, self.bounds.size.height/2 + yTranslation*CGFloat(i)*0.5)
            }
        }
    }
    
    func calculateTransform(offset: CGFloat, dimension: CGFloat) -> CGFloat{
        return (-2/dimension)*offset + 1
    }
    
    func degreesToRadians(value:CGFloat) -> CGFloat {
        return value * CGFloat(M_PI) / 180.0
    }
    
}