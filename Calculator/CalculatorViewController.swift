//
//  ViewController.swift
//  Calculator
//
//  Created by Julien Hémono on 11/05/15.
//  Copyright (c) 2015 Julien Hémono. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    private let brain = CalculatorBrain()

    private var userIsInTheMiddleOfTypingANumber = false {
        didSet {
            if oldValue != userIsInTheMiddleOfTypingANumber {
                if userIsInTheMiddleOfTypingANumber {
                    if let rangeOfEqual = history.text!.rangeOfString(" =") {
                        history.text!.removeRange(rangeOfEqual)
                    }
                }
            }
        }
    }
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            if digit == "." && display.text!.rangeOfString(digit) != nil {
                return
            }
            display.text = display.text! + digit
        }
        else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    @IBAction func plusMinus() {
        if userIsInTheMiddleOfTypingANumber {
            var text = display.text!
            if first(text) == "-" {
                text = dropFirst(text)
            } else {
                text.insert("-", atIndex: text.startIndex)
            }
            display.text = text
        } else {
            performOperation("±")
        }
    }
    
    @IBAction func backspace() {
        if userIsInTheMiddleOfTypingANumber {
            let nbElements = count(display.text!)
            if nbElements == 1 {
                initializeEditor()
            } else {
                display.text = dropLast(display.text!)
            }
        } else {
            displayValue = brain.pop()
        }
    }
    
    @IBAction func enter() {
        if let value = displayValue,
               result = brain.pushOperand(value) {
            userIsInTheMiddleOfTypingANumber = false
            displayValue = result
        } else {
            displayValue = nil
        }
    }
    
    private var displayValue: Double? {
        get {
            return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
        }
        set {
            let description = brain.description
            history.text = description.isEmpty ? " " : ", ".join(description)
            if let newValue = newValue {
                display.text = "\(newValue)"
                history.text! += " ="
            } else {
                display.text = " "
            }
        }
    }
    
    private func performOperation (symbol: String) {
        displayValue = brain.performOperation(symbol)
    }
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        performOperation(sender.currentTitle!)
    }
    
    @IBAction func insertVariable(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        let variable = sender.currentTitle!
        displayValue = brain.pushOperand(variable)
    }
    
    @IBAction func setVariable(sender: UIButton) {
        let variable = String(dropFirst(sender.currentTitle!))
        brain.variableValues[variable] = displayValue
        displayValue = brain.evaluate()
        userIsInTheMiddleOfTypingANumber = false
    }
    
    private func initializeEditor () {
        userIsInTheMiddleOfTypingANumber = false
        display.text = "0"
    }
    
    @IBAction func clear() {
        brain.clear()
        initializeEditor()
        brain.variableValues.removeAll(keepCapacity: true)
        history.text = " "
    }
}

