//
//  GraphView.swift
//  Calculator
//
//  Created by Julien Hémono on 16/05/15.
//  Copyright (c) 2015 Julien Hémono. All rights reserved.
//

import UIKit

protocol GraphViewDataSource: class {
    func yForGraphingAtX(x: Double) -> Double
}

@IBDesignable
class GraphView: UIView {
    
    lazy var axesDrawer: AxesDrawer = {
        [unowned self] in
        AxesDrawer(contentScaleFactor: self.contentScaleFactor)
    }()
    
    // Origin business
    
    var originOffset = CGPointZero { // Position of the origin with repect to the center of the view
        didSet { self.setNeedsDisplay() }
    }
    
    var origin: CGPoint { // Position of the origin in the views coordinate system
        let centre = convertPoint(center, fromView: superview)
        return CGPoint(x: centre.x + originOffset.x, y: centre.y + originOffset.y)
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
    
    var scale: CGFloat = 100
    
    weak var dataSource: GraphViewDataSource?

    override func drawRect(rect: CGRect) {
        let origin = self.origin
        axesDrawer.drawAxesInRect(rect, origin: origin, pointsPerUnit: scale)
        if let dataSource = dataSource {
            func plotPointforPlotX(x: CGFloat) -> CGPoint {
                let dx = Double((x - origin.x) / scale)
                let dy = dataSource.yForGraphingAtX(dx)
                let y = (CGFloat(dy) * -scale) + origin.y
                return CGPoint(x: x, y: y)
            }
            print("Plotting")
            UIColor.blackColor().set()
            let path = UIBezierPath()
            var x = floor(rect.minX)
            let end = floor(rect.maxX) + 1
            path.moveToPoint(plotPointforPlotX(x))
            println(" from \(x) to \(end)")
            for (; x <= end ; x += 1) {
                path.addLineToPoint(plotPointforPlotX(x))
            }
            path.stroke()
        }
    }

}
