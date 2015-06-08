//
//  GraphViewController.swift
//  Calculator
//
//  Created by Julien Hémono on 15/05/15.
//  Copyright (c) 2015 Julien Hémono. All rights reserved.
//

import UIKit

class FunctionGraphViewController: UIViewController, GraphViewDataSource {

    private let brain = CalculatorBrain()
    
    var program: AnyObject? {
        set {
            if let program:AnyObject = newValue {
                brain.program = program
                graphView?.setNeedsDisplay()
                title = brain.description.last
            }
        }
        get {
            return brain.program
        }
    }
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
        }
    }
    
    func yForGraphingAtX(x: Double) -> Double? {
        brain.variableValues["M"] = x
        return brain.evaluate()
    }

}
