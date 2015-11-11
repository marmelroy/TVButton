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
*/
public struct TVButtonLayer {
    /// UIImage to display. It is essential that all images have the same dimensions.
    var internalImage: UIImage?
}

public extension TVButtonLayer {
    /**
     Initialise the TVButton layer by passing a UIImage
     - Parameter image: UIImage to display. It is essential that all images have the same dimensions.
     */
    public init(image: UIImage) {
        self.init(internalImage: image)
    }
}

/**
 TVButton Object
 */
public class TVButton: UIButton, UIGestureRecognizerDelegate {
    
    // MARK: Internal variables
    internal var containerView = UIView()
    internal var specularView = UIImageView()
    internal var tvButtonAnimation: TVButtonAnimation?
    
    internal var longPressGestureRecognizer: UILongPressGestureRecognizer?
    internal var panGestureRecognizer: UIPanGestureRecognizer?
    internal var tapGestureRecognizer: UITapGestureRecognizer?
    
    // MARK: Public variables
    
    /// Stack of TVButtonLayers inside the button
    public var layers: [TVButtonLayer]? {
        didSet {
            // Remove existing parallax layer views
            for subview in containerView.subviews {
                subview.removeFromSuperview()
            }
            // Instantiate an imageview with corners for every layer
            for layer in layers! {
                let imageView = UIImageView(image: layer.internalImage)
                imageView.layer.cornerRadius = cornerRadius
                imageView.clipsToBounds = true
                imageView.layer.needsDisplayOnBoundsChange = true
                containerView.addSubview(imageView)
            }
            // Add specular shine effect
            let frameworkBundle = NSBundle(forClass: TVButton.self)
            let specularViewPath = frameworkBundle.pathForResource("Specular", ofType: "png")
            specularView.image = UIImage(contentsOfFile:specularViewPath!)
            self.containerView.addSubview(specularView)
        }
    }

    /// Determines the intensity of the parallax depth effect. Default is 1.0.
    public var parallaxIntensity: CGFloat = defaultParallaxIntensity

    /// Shadow color for the TVButton. Default is black.
    public var shadowColor: UIColor = UIColor.blackColor() {
        didSet {
            self.layer.shadowColor = shadowColor.CGColor
        }
    }
    
    // MARK: Lifecycle
    
    /**
    Default init for TVObject with coder.
    */
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    /**
     Default init for TVObject with frame.
     */
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    /**
     Lays out subviews.
     */
    override public func layoutSubviews() {
        super.layoutSubviews()
        containerView.frame = self.bounds
        self.layer.masksToBounds = false;
        let shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius)
        self.layer.shadowPath = shadowPath.CGPath

        // Stop here if animation is on
        if let animation = tvButtonAnimation {
            if animation.highlightMode == true {
                return
            }
        }
        
        // Adjust size for every subview
        for subview in containerView.subviews {
            if subview == specularView {
                subview.frame = CGRect(origin: subview.frame.origin, size: CGSizeMake(specularScale * containerView.frame.size.width, specularScale * containerView.frame.size.height))
            }
            else {
                subview.frame = CGRect(origin: subview.frame.origin, size: containerView.frame.size)
            }
        }
    }
    
    /**
     Button setup. Conducted on init.
    */
    func setup() {
        containerView.userInteractionEnabled = false
        self.addSubview(containerView)
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        specularView.alpha = 0.0
        specularView.contentMode = UIViewContentMode.ScaleAspectFill
        self.layer.shadowRadius = self.bounds.size.height/(2*shadowFactor)
        self.layer.shadowOffset = CGSizeMake(0.0, shadowFactor/3)
        self.layer.shadowOpacity = 0.5;
        tvButtonAnimation = TVButtonAnimation(button: self)
        self.addGestureRecognizers()
    }
    
    
    // MARK: UIGestureRecognizer actions and delegate
    
    /**
    Adds the gesture recognizers to the button.
    */
    func addGestureRecognizers(){
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        panGestureRecognizer?.delegate = self
        self.addGestureRecognizer(panGestureRecognizer!)
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
        self.addGestureRecognizer(tapGestureRecognizer!)
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        longPressGestureRecognizer?.delegate = self
        self.addGestureRecognizer(longPressGestureRecognizer!)
    }
    
    /**
     Pan gesture recognizer handler.
     - Parameter gestureRecognizer: TVButton's UIPanGestureRecognizer.
     */
    func handlePan(gestureRecognizer: UIGestureRecognizer) {
        self.gestureRecognizerDidUpdate(gestureRecognizer)
    }
    
    /**
     Long press gesture recognizer handler.
     - Parameter gestureRecognizer: TVButton's UILongPressGestureRecognizer.
     */
    func handleLongPress(gestureRecognizer: UIGestureRecognizer) {
        self.gestureRecognizerDidUpdate(gestureRecognizer)
    }
    
    /**
     Tap gesture recognizer handler. Sends TouchUpInside to super.
     - Parameter gestureRecognizer: TVButton's UITapGestureRecognizer.
     */
    func handleTap(gestureRecognizer: UIGestureRecognizer) {
        super.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
    }
    
    /**
     Determines button's reaction to gesturerecognizer.
     - Parameter gestureRecognizer: either UITapGestureRecognizer or UILongPressGestureRecognizer.
     */
    func gestureRecognizerDidUpdate(gestureRecognizer: UIGestureRecognizer){
        if layers == nil {
            return
        }
        let point = gestureRecognizer.locationInView(self)
        if let animation = tvButtonAnimation {
            if gestureRecognizer.state == .Began {
                animation.enterMovement()
                animation.processMovement(point)
            }
            else if gestureRecognizer.state == .Changed {
                animation.processMovement(point)
            }
            else {
                if gestureRecognizer.state == .Began || gestureRecognizer.state == .Changed {
                    return
                }
                animation.exitMovement()
            }
        }
    }
    
    // MARK: UIGestureRecognizerDelegate
    
    /**
    UIGestureRecognizerDelegate function to allow two UIGestureRecognizers to be recognized simultaneously.
    - Parameter gestureRecognizer: First gestureRecognizer.
    - Parameter otherGestureRecognizer: Second gestureRecognizer.
    */
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}