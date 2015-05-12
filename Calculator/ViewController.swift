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
    
    var userIsInTheMiddleOfTypingANumber = false
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if digit == "." && display.text!.rangeOfString(digit) != nil && userIsInTheMiddleOfTypingANumber {
            return
        }
        if userIsInTheMiddleOfTypingANumber {
            display.text = display.text! + digit
        }
        else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    var operandStack = Array<Double>()
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        operandStack.append(displayValue)
        println("\(operandStack)")
    }
    
    var displayValue: Double {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            display.text = "\(newValue)"
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    @IBAction func operand(sender: UIButton) {
        let operation = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        switch operation {
            case "×":
                performOperation({$0 * $1})
            case "÷":
                performOperation({$1 / $0})
            case "+":
                performOperation({$0 + $1})
            case "−":
                performOperation({$1 - $0})
            case "√":
                performOperationUnary({sqrt($0)})
            case "sin":
                performOperationUnary({sin($0)})
            case "cos":
                performOperationUnary({cos($0)})
            case "π":
                insertConstant(M_PI)
            default:
                break
        }
    }
    
    func performOperation(operation: (Double, Double) -> Double) {
        if (operandStack.count >= 2) {
            displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
            enter()
        }
    }
    
    func performOperationUnary(operation: Double -> Double) {
        if (operandStack.count >= 1) {
            displayValue = operation(operandStack.removeLast())
            enter()
        }
    }
    
    func insertConstant(constant: Double) {
        displayValue = constant
        enter()
    }
}

