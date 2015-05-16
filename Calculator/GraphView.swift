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
    
    let axesDrawer = AxesDrawer()
    
    var originOffset = CGPointZero
    
    var origin: CGPoint {
        let centre = convertPoint(center, fromView: superview)
        return CGPoint(x: centre.x + originOffset.x, y: centre.y + originOffset.y)
    }

    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        axesDrawer.drawAxesInRect(rect, origin: origin, pointsPerUnit: 1)
    }

}
