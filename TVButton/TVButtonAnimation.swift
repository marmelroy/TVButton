//
//  TVButtonAnimation.swift
//  TVButton
//
//  Created by Roy Marmelstein on 10/11/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

/**
TVButtonAnimation class
 */
internal class TVButtonAnimation {
    
    var highlightMode: Bool = false {
        didSet {
        
        }
    }
    var button: TVButton?

    init(button: TVButton) {
        self.button = button
    }
    
    // Movement begins
    func enterMovement() {
        if highlightMode == true {
            return
        }
        if let tvButton = button {
            self.highlightMode = true
            let targetShadowOffset = CGSizeMake(0.0, tvButton.bounds.size.height/shadowFactor)
            tvButton.layer.removeAllAnimations()
            CATransaction.begin()
            CATransaction.setCompletionBlock({ () -> Void in
                tvButton.layer.shadowOffset = targetShadowOffset
            })
            let shaowOffsetAnimation = CABasicAnimation(keyPath: "shadowOffset")
            shaowOffsetAnimation.toValue = NSValue(CGSize: targetShadowOffset)
            shaowOffsetAnimation.duration = animationDuration
            shaowOffsetAnimation.removedOnCompletion = false
            shaowOffsetAnimation.fillMode = kCAFillModeForwards
            shaowOffsetAnimation.timingFunction = CAMediaTimingFunction(name: "easeOut")
            tvButton.layer.addAnimation(shaowOffsetAnimation, forKey: "shadowOffset")
            CATransaction.commit()
            let shadowOpacityAnimation = CABasicAnimation(keyPath: "shadowOpacity")
            shadowOpacityAnimation.toValue = 0.6
            shadowOpacityAnimation.duration = animationDuration
            shadowOpacityAnimation.removedOnCompletion = false
            shadowOpacityAnimation.fillMode = kCAFillModeForwards
            shadowOpacityAnimation.timingFunction = CAMediaTimingFunction(name: "easeOut")
            tvButton.layer.addAnimation(shadowOpacityAnimation, forKey: "shadowOpacityAnimation")
            CATransaction.commit()
        }
    }
    
    // Movement continues
    func processMovement(point: CGPoint){
        if (highlightMode == false) {
            return
        }
        if let tvButton = button {
            let offsetX = point.x / tvButton.bounds.size.width
            let offsetY = point.y / tvButton.bounds.size.height
            let dx = point.x - tvButton.bounds.size.width/2
            let dy = point.y - tvButton.bounds.size.height/2
            let xRotation = (dy - offsetY)*(rotateXFactor/tvButton.bounds.size.width)
            let yRotation = (offsetX - dx)*(rotateYFactor/tvButton.bounds.size.width)
            let zRotation = (xRotation + yRotation)/rotateZFactor
            
            let xTranslation = (-2*point.x/tvButton.bounds.size.width)*maxTranslationX
            let yTranslation = (-2*point.y/tvButton.bounds.size.height)*maxTranslationY
            
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
                tvButton.layer.transform = combinedTransform
                tvButton.specularView.alpha = specularAlpha
                tvButton.specularView.center = point
                for var i = 1; i < tvButton.containerView.subviews.count ; i++ {
                    let adjusted = i/2
                    let scale = 1 + maxScaleDelta*CGFloat(adjusted/tvButton.containerView.subviews.count)
                    let subview = tvButton.containerView.subviews[i]
                    if subview != tvButton.specularView {
                        subview.contentMode = UIViewContentMode.Redraw
                        subview.frame.size = CGSizeMake(tvButton.bounds.size.width*scale, tvButton.bounds.size.height*scale)
                    }
                }

                }, completion: nil)
            UIView.animateWithDuration(0.16, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                for var i = 1; i < tvButton.containerView.subviews.count ; i++ {
                    let subview = tvButton.containerView.subviews[i]
                    let xParallax = tvButton.parallaxIntensity*parallaxIntensityXFactor
                    let yParallax = tvButton.parallaxIntensity*parallaxIntensityYFactor
                    if subview != tvButton.specularView {
                        subview.center = CGPointMake(tvButton.bounds.size.width/2 + xTranslation*CGFloat(i)*xParallax, tvButton.bounds.size.height/2 + yTranslation*CGFloat(i)*0.3*yParallax)
                    }
                }
            }, completion: nil)

        }
    }
    
    // Movement ends
    func exitMovement() {
        if highlightMode == false {
            return
        }
        if let tvButton = button {
            let targetShadowOffset = CGSizeMake(0.0, shadowFactor/3)
            let targetScaleTransform = CATransform3DMakeScale(1.0, 1.0, 1.0)
            tvButton.specularView.layer.removeAllAnimations()
            CATransaction.begin()
            CATransaction.setCompletionBlock({ () -> Void in
                tvButton.layer.transform = targetScaleTransform
                tvButton.layer.shadowOffset = targetShadowOffset
                self.highlightMode = false
            })
            let shaowOffsetAnimation = CABasicAnimation(keyPath: "shadowOffset")
            shaowOffsetAnimation.toValue = NSValue(CGSize: targetShadowOffset)
            shaowOffsetAnimation.duration = animationDuration
            shaowOffsetAnimation.fillMode = kCAFillModeForwards
            shaowOffsetAnimation.removedOnCompletion = false
            shaowOffsetAnimation.timingFunction = CAMediaTimingFunction(name: "easeOut")
            tvButton.layer.addAnimation(shaowOffsetAnimation, forKey: "shadowOffset")
            let scaleAnimation = CABasicAnimation(keyPath: "transform")
            scaleAnimation.toValue = NSValue(CATransform3D: targetScaleTransform)
            scaleAnimation.duration = animationDuration
            scaleAnimation.removedOnCompletion = false
            scaleAnimation.fillMode = kCAFillModeForwards
            scaleAnimation.timingFunction = CAMediaTimingFunction(name: "easeOut")
            tvButton.layer.addAnimation(scaleAnimation, forKey: "scaleAnimation")
            CATransaction.commit()
            UIView.animateWithDuration(animationDuration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                tvButton.transform = CGAffineTransformIdentity
                tvButton.specularView.alpha = 0.0
                for var i = 0; i < tvButton.containerView.subviews.count ; i++ {
                    let subview = tvButton.containerView.subviews[i]
                    subview.frame.size = CGSizeMake(tvButton.bounds.size.width, tvButton.bounds.size.height)
                    subview.center = CGPointMake(tvButton.bounds.size.width/2, tvButton.bounds.size.height/2)
                }
                }, completion:nil)
        }
    }
    
    // MARK: Convenience
    
    func degreesToRadians(value:CGFloat) -> CGFloat {
        return value * CGFloat(M_PI) / 180.0
    }

}