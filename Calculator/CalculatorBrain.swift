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
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return operand.description
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    private var knownOps = [String:Op]()
    
    private var opStack = [Op]()
    
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
        addBinaryOp("÷") { $1 / $0 }
        addBinaryOp("+", +)
        addBinaryOp("−") { $1 - $0 }
        addUnaryOp("√", sqrt)
        addUnaryOp("sin", sin)
        addUnaryOp("cos", cos)
        addUnaryOp("±", -)
        knownOps["π"] = Op.Operand(M_PI)
    }
    
    func pushOperand(operand: Double) -> Double?
    {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func performOperation (symbol: String) -> Double?
    {
        if let operation = knownOps[symbol]
        {
            opStack.append(operation)        }
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
            case .UnaryOperation(_, let operation):
                let operandEvalutation = evaluate(remainingOps)
                if let operand = operandEvalutation.result {
                    return (operation(operand), operandEvalutation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evalutation = evaluate(remainingOps)
                if let operand1 = op1Evalutation.result {
                    let op2Evalutation = evaluate(op1Evalutation.remainingOps)
                    if let operand2 = op2Evalutation.result {
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