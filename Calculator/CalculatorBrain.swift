//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by 배휘동 on 2015. 12. 8..
//  Copyright (c) 2015년 배휘동. All rights reserved.
//

import Foundation

class CalculatorBrain {
    private enum Op: CustomStringConvertible {
        case Operand(Double)
        case Variable(String)
        case ClearOperation
        case SelfOperation(String, Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .Variable(let variable):
                    return variable
                case .ClearOperation:
                    return "C"
                case .SelfOperation(let symbol, _):
                    return symbol
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = [Op]()
    
    private var knownOps = [String:Op]()
    
    var variableValues = [String:Double]()
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        
        learnOp(Op.BinaryOperation("✕", *))
        learnOp(Op.BinaryOperation("÷") {$1 / $0})
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("−") {$1 - $0})
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.UnaryOperation("+/-", -))
        learnOp(Op.SelfOperation("π", M_PI))
        learnOp(Op.ClearOperation)
    }
    
    var description: String {
        get {
            var val = describe(opStack)
            var resultString = val.result!
            while(!val.remainingOps.isEmpty) {
                val = describe(val.remainingOps)
                resultString = val.result! + ", " + resultString
            }
            return resultString
        }
    }
    
    private func describe(ops: [Op], parenthesisRequired: Bool = false) -> (result: String?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return ("\(operand)", remainingOps)
            case .Variable(let variable):
                return (variable, remainingOps)
            case .ClearOperation:
                return (nil, remainingOps)
            case .SelfOperation(let symbol, _):
                return (symbol, remainingOps)
            case .UnaryOperation(let symbol, _):
                let operandDescription = describe(remainingOps)
                if let operand = operandDescription.result {
                    return ("\(symbol)(\(operand))", operandDescription.remainingOps)
                }
            case .BinaryOperation(let symbol, _):
                let op1Description = describe(remainingOps, parenthesisRequired: true)
                if let op1 = op1Description.result {
                    let op2Description = describe(op1Description.remainingOps, parenthesisRequired: true)
                    if let op2 = op2Description.result {
                        if parenthesisRequired {
                            return ("(\(op2)\(symbol)\(op1))", op2Description.remainingOps)
                        } else {
                            return ("\(op2)\(symbol)\(op1)", op2Description.remainingOps)
                        }
                    }
                }
            }
        }
        
        return ("?", ops)
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .Variable(let variable):
                if let value = variableValues[variable] {
                    return (value, remainingOps)
                } else {
                    return (nil, remainingOps)
                }
            case .ClearOperation:
                opStack.removeAll()
                return (0, [])
            case .SelfOperation(_, let value):
                return (value, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let op1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let op2 = op2Evaluation.result {
                        return (operation(op1, op2), op2Evaluation.remainingOps)
                    }
                }
            }

        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        print("\(description) = \(result) with \(remainder) left over")
        return result
    } 
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)        
        }
        return evaluate()
    }
}