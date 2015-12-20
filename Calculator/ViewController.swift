//
//  ViewController.swift
//  Calculator
//
//  Created by 배휘동 on 2015. 12. 4..
//  Copyright (c) 2015년 배휘동. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    var userIsInMiddleOfTypingANumber: Bool = false
    
    var brain = CalculatorBrain()
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInMiddleOfTypingANumber {
            if digit == "." && (display.text!).characters.contains(".") {
                return
            }
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsInMiddleOfTypingANumber = true
        }
    }
    
    @IBAction func specialOperation(sender: UIButton) {
        let op = sender.currentTitle!
        
        if op == "BACK" {
            if userIsInMiddleOfTypingANumber {
                if display.text!.characters.count > 1 {                    
                    display.text = String((display.text!).characters.dropLast())
                } else {
                    display.text = "0"
                    userIsInMiddleOfTypingANumber = false
                }
            }
        } else if op == "+/-" {
            if userIsInMiddleOfTypingANumber {
                if (display.text!).characters.contains("-") {
                    display.text = String((display.text!).characters.dropFirst())
                } else {
                    display.text = "-" + display.text!
                }
            } else {
                operate(sender)
            }
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        if userIsInMiddleOfTypingANumber {
            enter()
        }

        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
                historyValue = brain.description
            } else {
                displayValue = nil
            }
        }
    }
    
    @IBAction func enter() {
        userIsInMiddleOfTypingANumber = false
        if let result = brain.pushOperand(displayValue!) {
            displayValue = result
        } else {
            displayValue = nil
        }
    }
    
    var displayValue: Double? {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            if newValue == nil {
                display.text = ""
            } else {
                display.text = "\(newValue!)"
            }

            userIsInMiddleOfTypingANumber = false
        }
    }
    
    var historyValue: String {
        get {
            return history.text!
        }
        set {
            if newValue == "C" {
                history.text = ""
            } else {
                history.text = newValue + " ="
            }
        }
    }
}
