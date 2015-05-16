//
//  GraphViewController.swift
//  Calculator
//
//  Created by Julien Hémono on 15/05/15.
//  Copyright (c) 2015 Julien Hémono. All rights reserved.
//

import UIKit

class FunctionGraphViewController: UIViewController, GraphViewDataSource {

    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
        }
    }
    
    func yForGraphingAtX(x: Double) -> Double {
        return cos(x)
    }

}
