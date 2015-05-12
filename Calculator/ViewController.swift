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
    
    func log(line: String) {
        if history.text! == "Empty History" {
            history.text = line
        } else {
            history.text! += " | " + line
        }
    }
    
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
        if userIsInTheMiddleOfTypingANumber {
            log(display.text!)
        }
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
    
    typealias action = () -> ()
    
    @IBAction func operand(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        let operation = sender.currentTitle!
        var fun: action? = nil
        switch operation {
            case "×":
                fun = performOperation({$0 * $1})
            case "÷":
                fun = performOperation({$1 / $0})
            case "+":
                fun = performOperation({$0 + $1})
            case "−":
                fun = performOperation({$1 - $0})
            case "√":
                fun = performOperationUnary({sqrt($0)})
            case "sin":
                fun = performOperationUnary({sin($0)})
            case "cos":
                fun = performOperationUnary({cos($0)})
            case "π":
                fun = insertConstant(M_PI)
            default:
                fun = nil
        }
        if let fun = fun {
            fun()
            log(operation)
            enter()
        }
    }
    
    func performOperation(operation: (Double, Double) -> Double) -> action? {
        if (operandStack.count >= 2) {
            return { self.displayValue = operation(self.operandStack.removeLast(), self.operandStack.removeLast()) }
        } else {
            return nil
        }
    }
    
    func performOperationUnary(operation: Double -> Double) -> action? {
        if (operandStack.count >= 1) {
            return { self.displayValue = operation(self.operandStack.removeLast()) }
        } else {
            return nil
        }
    }
    
    func insertConstant(constant: Double) -> action? {
        return { self.displayValue = constant }
    }
    
    @IBAction func clear() {
        userIsInTheMiddleOfTypingANumber = false
        operandStack = []
        display.text = "0"
        history.text = "Empty History"
    }
}

