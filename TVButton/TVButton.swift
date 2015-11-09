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
 - parallaxIntensity: A value between 0 and 2 (the subtle default is 0.6). Change for a more pronounced parallax effect.
 */
public class TVButton: UIButton, UIGestureRecognizerDelegate {
    
    var specularView = UIImageView()
    var containerView = UIView()
    var panGestureRecognizer: UIPanGestureRecognizer?
    var tapGestureRecognizer: UITapGestureRecognizer?
    var longPressGestureRecognizer: UILongPressGestureRecognizer?
    var highlightMode: Bool = false
    
    let animationDuration: Double = 0.4
    let rotateYFactor: CGFloat = 16
    let rotateXFactor: CGFloat = 20
    let rotateZFactor: CGFloat = 9
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
    
    public var parallaxIntensity : CGFloat = 0.6
    
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
            self.enterMovement()
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
            self.enterMovement()
            self.processMovement(gestureRecognizer)
        }
        else {
            self.exitMovement()
        }
    }
    
    func handleTap(gestureRecognizer: UIGestureRecognizer) {
        super.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
    }
    
    
    // MARK: Animations
    
    func enterMovement() {
        if highlightMode == true {
            return
        }
        self.highlightMode = true
        let targetShadowOffset = CGSizeMake(0.0, self.bounds.size.height/shadowFactor)
        self.layer.removeAllAnimations()
        CATransaction.begin()
        CATransaction.setCompletionBlock({ () -> Void in
            self.layer.shadowOffset = targetShadowOffset
        })
        let shaowOffsetAnimation = CABasicAnimation(keyPath: "shadowOffset")
        shaowOffsetAnimation.toValue = NSValue(CGSize: targetShadowOffset)
        shaowOffsetAnimation.duration = animationDuration
        shaowOffsetAnimation.removedOnCompletion = false
        shaowOffsetAnimation.fillMode = kCAFillModeForwards
        shaowOffsetAnimation.timingFunction = CAMediaTimingFunction(name: "easeOut")
        self.layer.addAnimation(shaowOffsetAnimation, forKey: "shadowOffset")
        CATransaction.commit()
    }
    
    func processMovement(gestureRecognizer: UIGestureRecognizer){
        let point = gestureRecognizer.locationInView(self)
        if (highlightMode == false) {
            return
        }
        let offsetX = point.x / self.bounds.size.width
        let offsetY = point.y / self.bounds.size.height
        let dx = point.x - self.bounds.size.width/2
        let dy = point.y - self.bounds.size.height/2
        let xRotation = (dy - offsetY)*(rotateXFactor/self.bounds.size.width)
        let yRotation = (offsetX - dx)*(rotateYFactor/self.bounds.size.width)
        let zRotation = (xRotation + yRotation)/rotateZFactor
        
        let xTranslation = (-2*point.x/self.bounds.size.width)*maxTranslation
        let yTranslation = (-2*point.y/self.bounds.size.height)*maxTranslation
        
        let xRotateTransform = CATransform3DMakeRotation(degreesToRadians(xRotation), 1, 0, 0)
        let yRotateTransform = CATransform3DMakeRotation(degreesToRadians(yRotation), 0, 1, 0)
        let zRotateTransform = CATransform3DMakeRotation(degreesToRadians(zRotation), 0, 0, 1)
        
        let combinedRotateTransformXY = CATransform3DConcat(xRotateTransform, yRotateTransform)
        let combinedRotateTransformZ = CATransform3DConcat(combinedRotateTransformXY, zRotateTransform)
        let translationTransform = CATransform3DMakeTranslation(-xTranslation, yTranslation, 0.0)
        let combinedRotateTranslateTransform = CATransform3DConcat(combinedRotateTransformZ, translationTransform)
        let targetScaleTransform = CATransform3DMakeScale(highlightedScale, highlightedScale, highlightedScale)
        let combinedTransform = CATransform3DConcat(combinedRotateTranslateTransform, targetScaleTransform)
        
        UIView.animateWithDuration(animationDuration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.layer.transform = combinedTransform
            self.specularView.alpha = 0.3
            self.specularView.center = point
            }, completion: nil)
        for var i = 1; i < self.containerView.subviews.count ; i++ {
            let subview = self.containerView.subviews[i]
            if subview != self.specularView {
                subview.center = CGPointMake(self.bounds.size.width/2 + xTranslation*CGFloat(i)*self.parallaxIntensity, self.bounds.size.height/2 + yTranslation*CGFloat(i)*self.parallaxIntensity)
            }
        }
    }
    
    func exitMovement() {
        if highlightMode == false || longPressGestureRecognizer?.state == .Began || longPressGestureRecognizer?.state == .Changed || panGestureRecognizer?.state == .Began || panGestureRecognizer?.state == .Changed  {
            return
        }
        let targetShadowOffset = CGSizeMake(0.0, shadowFactor/3)
        let targetScaleTransform = CATransform3DMakeScale(1.0, 1.0, 1.0)
        self.specularView.layer.removeAllAnimations()
        CATransaction.begin()
        CATransaction.setCompletionBlock({ () -> Void in
            self.layer.transform = targetScaleTransform
            self.layer.shadowOffset = targetShadowOffset
            self.highlightMode = false
        })
        let shaowOffsetAnimation = CABasicAnimation(keyPath: "shadowOffset")
        shaowOffsetAnimation.toValue = NSValue(CGSize: targetShadowOffset)
        shaowOffsetAnimation.duration = animationDuration
        shaowOffsetAnimation.fillMode = kCAFillModeForwards
        shaowOffsetAnimation.removedOnCompletion = false
        shaowOffsetAnimation.timingFunction = CAMediaTimingFunction(name: "easeOut")
        self.layer.addAnimation(shaowOffsetAnimation, forKey: "shadowOffset")
        let scaleAnimation = CABasicAnimation(keyPath: "transform")
        scaleAnimation.toValue = NSValue(CATransform3D: targetScaleTransform)
        scaleAnimation.duration = animationDuration
        scaleAnimation.removedOnCompletion = false
        scaleAnimation.fillMode = kCAFillModeForwards
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: "easeOut")
        self.layer.addAnimation(scaleAnimation, forKey: "scaleAnimation")
        CATransaction.commit()
        UIView.animateWithDuration(animationDuration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
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
    
    // MARK: Convenience
    
    func degreesToRadians(value:CGFloat) -> CGFloat {
        return value * CGFloat(M_PI) / 180.0
    }
    
}