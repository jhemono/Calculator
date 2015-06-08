//
//  GraphView.swift
//  Calculator
//
//  Created by Julien Hémono on 16/05/15.
//  Copyright (c) 2015 Julien Hémono. All rights reserved.
//

import UIKit

protocol GraphViewDataSource: class {
    func yForGraphingAtX(x: Double) -> Double?
}

@IBDesignable
class GraphView: UIView {
    
    lazy var axesDrawer: AxesDrawer = {
        [unowned self] in
        AxesDrawer(contentScaleFactor: self.contentScaleFactor)
    }()
    
    // Origin business
    
    var originOffset = CGPointZero { // Position of the origin with repect to the center of the view
        didSet { setNeedsDisplay() }
    }
    
    var origin: CGPoint { // Position of the origin in the views coordinate system
        get {
            let centre = convertPoint(center, fromView: superview)
            return CGPoint(x: centre.x + originOffset.x, y: centre.y + originOffset.y)
        }
        set (newOrigin) {
            let centre = convertPoint(center, fromView: superview)
            originOffset = CGPoint(x: newOrigin.x - centre.x, y: newOrigin.y - centre.y)
        }
    }
    
    @IBInspectable
    var pannable: Bool = false {
        didSet (oldPannable) {
            if (pannable != oldPannable) { // If changed pannable
                if pannable {
                    addGestureRecognizer(panRecognizer)
                } else {
                    removeGestureRecognizer(panRecognizer)
                }
            }
        }
    }
    private lazy var panRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "pan:")
    
    func pan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Ended, .Changed:
            let translation = gesture.translationInView(self)
            if translation != CGPointZero {
                originOffset.x += translation.x
                originOffset.y += translation.y
                gesture.setTranslation(CGPointZero, inView: self)
            }
        default:
            break
        }
    }
    
    @IBInspectable
    var originDoubletappable: Bool = false {
        didSet (oldOriginDoubletappable) {
            if (originDoubletappable != oldOriginDoubletappable) {
                if originDoubletappable {
                    addGestureRecognizer(doubletapRecognizer)
                } else {
                    removeGestureRecognizer(doubletapRecognizer)
                }
            }
        }
    }
    private lazy var doubletapRecognizer: UITapGestureRecognizer = { [unowned self] in
        let recognizer = UITapGestureRecognizer(target: self, action: "tapOrigin:")
        recognizer.numberOfTapsRequired = 2
        return recognizer
    }()
    
    func tapOrigin(gesture: UITapGestureRecognizer) {
        if gesture.state == .Ended {
            origin = gesture.locationInView(self)
        }
    }
    
    // Scale business
    
    @IBInspectable
    var scale: CGFloat = 100 {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable
    var scalable: Bool = false {
        didSet (oldScalable) {
            if (scalable != oldScalable) {
                addGestureRecognizer(pinchRecognizer)
            } else {
                removeGestureRecognizer(pinchRecognizer)
            }
        }
    }
    private lazy var pinchRecognizer: UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "scale:")
    
    func scale(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed {
            scale *= gesture.scale
            gesture.scale = 1
        }
    }
    
    weak var dataSource: GraphViewDataSource?

    override func drawRect(rect: CGRect) {
        let origin = self.origin
        axesDrawer.drawAxesInRect(rect, origin: origin, pointsPerUnit: scale)
        if let dataSource = dataSource {
            func plotPointforPlotX(x: CGFloat) -> CGPoint? {
                let dx = Double((x - origin.x) / scale)
                if let dy = dataSource.yForGraphingAtX(dx) {
                    if (dy.isNormal || dy.isZero) {
                        let y = (CGFloat(dy) * -scale) + origin.y
                        return CGPoint(x: x, y: y)
                    }
                }
                return nil
            }
            print("Plotting", appendNewline: false)
            UIColor.blackColor().set()
            let path = UIBezierPath()
            var gap = true
            var x = floor(rect.minX)
            let end = floor(rect.maxX) + 1
            print(" from \(x) to \(end)")
            for (; x <= end ; x += 1) {
                if let point = plotPointforPlotX(x) {
                    if gap {
                        path.moveToPoint(point)
                    } else {
                        path.addLineToPoint(point)
                    }
                    gap = false
                } else {
                    gap = true
                }
            }
            path.stroke()
        }
    }

}
