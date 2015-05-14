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
    
    private func evaluate (ops: [Op]) -> (result: Double?, remainingOps: [Op])
    {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .ConstantOperand(_, let operand):
                return (operand, remainingOps)
            case .VariableOperand(let symbol):
                if let value = variableValues[symbol] {
                    return (value, remainingOps)
                }
            case .UnaryOperation(_, let operation):
                let operandEvalutation = evaluate(remainingOps)
                if let operand = operandEvalutation.result {
                    return (operation(operand), operandEvalutation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op2Evalutation = evaluate(remainingOps)
                if let operand2 = op2Evalutation.result {
                    let op1Evalutation = evaluate(op2Evalutation.remainingOps)
                    if let operand1 = op1Evalutation.result {
                        return (operation(operand1, operand2), op2Evalutation.remainingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    func evaluate () -> Double?
    {
        let (result, remainder) = evaluate(opStack)
        println("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    func clear () {
        opStack = []
    }
}