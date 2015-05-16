//
//  GraphView.swift
//  Calculator
//
//  Created by Julien Hémono on 16/05/15.
//  Copyright (c) 2015 Julien Hémono. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView {
    
    lazy var axesDrawer: AxesDrawer = {
        [unowned self] in
        AxesDrawer(contentScaleFactor: self.contentScaleFactor)
    }()
    
    var originOffset = CGPointZero // Position of the origin with repect to the center of the view
    
    var origin: CGPoint { // Position of the origin in the views coordinate system
        let centre = convertPoint(center, fromView: superview)
        return CGPoint(x: centre.x + originOffset.x, y: centre.y + originOffset.y)
    }
    
    var scale: CGFloat = 1

    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        axesDrawer.drawAxesInRect(rect, origin: origin, pointsPerUnit: scale)
    }

}
