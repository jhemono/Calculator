//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Julien Hémono on 13/05/15.
//  Copyright (c) 2015 Julien Hémono. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    private enum Op: Printable
    {
        case Operand(Double)
        case VariableOperand(String)
        case ConstantOperand(String, Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return operand.description
                case .VariableOperand(let symbol):
                    return symbol
                case .ConstantOperand(let symbol, _):
                    return symbol
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    var variableValues = [String:Double]()
    
    private var knownOps = [String:Op]()
    
    private var opStack = [Op]()
    
    private func describe (stack: [Op]) -> (description: String, remainder: [Op])? {
        if let top = last(stack) {
            var remainder = [Op](dropLast(stack))
            switch top {
            case .Operand(_), .VariableOperand(_), .ConstantOperand(_, _):
                return (top.description, remainder)
            case .UnaryOperation(_, _):
                var part1 = "?"
                if let (op1, remainder1) = describe(remainder) {
                    part1 = op1
                    remainder = remainder1
                }
                return ("\(top.description)(\(part1))", remainder)
            case .BinaryOperation(_, _):
                var part1 = "?", part2 = "?"
                if let (op2, remainder2) = describe (remainder) {
                    part2 = op2
                    remainder = remainder2
                }
                if let (op1, remainder1) = describe (remainder) {
                    part1 = op1
                    remainder = remainder1
                }
                return ("\(part1) \(top.description) \(part2)", remainder)
            }
        } else {
            return nil
        }
    }

    
    var description: String? {
        var parts = [String]()
        var stack = opStack
        while let (part, remainder) = describe(stack) {
            parts.append(part)
            stack = remainder
        }
        return ", ".join(reverse(parts))
    }
    
    init()
    {
        func addBinaryOp (op: String, fun: (Double, Double) -> Double)
        {
            knownOps[op] = Op.BinaryOperation(op, fun)
        }
        func addUnaryOp (op: String, fun: Double -> Double)
        {
            knownOps[op] = Op.UnaryOperation(op, fun)
        }
        
        addBinaryOp("×", *)
        addBinaryOp("÷", /)
        addBinaryOp("+", +)
        addBinaryOp("−", -)
        addUnaryOp("√", sqrt)
        addUnaryOp("sin", sin)
        addUnaryOp("cos", cos)
        addUnaryOp("±", -)
        knownOps["π"] = .ConstantOperand("π", M_PI)
    }
    
    func pushOperand(operand: Double) -> Double?
    {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.VariableOperand(symbol))
        return evaluate()
    }
    
    func performOperation (symbol: String) -> Double?
    {
        if let operation = knownOps[symbol]
        {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    private func evaluate (ops: [Op]) -> (result: Double, remainingOps: [Op])?
    {
        if !ops.isEmpty {
            var remainder = ops
            let op = remainder.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainder)
            case .ConstantOperand(_, let operand):
                return (operand, remainder)
            case .VariableOperand(let symbol):
                if let value = variableValues[symbol] {
                    return (value, remainder)
                }
            case .UnaryOperation(_, let operation):
                if let (operand, remainder) = evaluate(remainder) {
                    return (operation(operand), remainder)
                }
            case .BinaryOperation(_, let operation):
                if let (operand2, remainder) = evaluate(remainder) {
                    if let (operand1, remainder) = evaluate(remainder) {
                        return (operation(operand1, operand2), remainder)
                    }
                }
            }
        }
        return nil
    }
    
    func evaluate () -> Double?
    {
        if let (result, remainder) = evaluate(opStack) {
            println("\(opStack) = \(result) with \(remainder) left over")
            return result
        } else {
            println("invalid computation for stack \(opStack)")
            return nil
        }
    }
    
    func clear () {
        opStack = []
    }
}