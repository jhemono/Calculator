//
//  ViewController.swift
//  Calculator
//
//  Created by Julien Hémono on 11/05/15.
//  Copyright (c) 2015 Julien Hémono. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    private let brain = CalculatorBrain()
    
    private func log(line: String) {
        if history.text! == "Empty History" {
            history.text = line
        } else {
            history.text! += " " + line
        }
    }
    
    private var userIsInTheMiddleOfTypingANumber = false
    
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
        let nbElements = count(display.text!)
        if nbElements == 1 {
            initializeEditor()
        } else {
            display.text = dropLast(display.text!)
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    @IBAction func enter() {
        if let value = displayValue,
               result = brain.pushOperand(value) {
            log(display.text!)
            log("⏎")
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
            if let newValue = newValue {
                display.text = "\(newValue)"
            } else {
                display.text = "???"
            }
        }
    }
    
    private func performOperation (symbol: String) {
        if let result = brain.performOperation(symbol) {
            displayValue = result
            log(symbol)
            
        } else {
            displayValue = nil
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        performOperation(sender.currentTitle!)
    }
    
    private func initializeEditor () {
        userIsInTheMiddleOfTypingANumber = false
        display.text = "0"
    }
    
    @IBAction func clear() {
        brain.clear()
        initializeEditor()
        history.text = "Empty History"
    }
}

