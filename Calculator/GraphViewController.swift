//
//  GraphViewController.swift
//  Calculator
//
//  Created by 배휘동 on 2015. 12. 30..
//  Copyright © 2015년 배휘동. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource {
    var program: AnyObject? {
        didSet {
            updateUI()
        }
    }
    
    var programDescription: String = ""
    
    func updateUI() {
        graphView?.setNeedsDisplay()
        title = programDescription
    }
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: "scale:"))
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: "moveWholeGraph:"))
            
            let tap = UITapGestureRecognizer()
            tap.numberOfTapsRequired = 2
            tap.addTarget(graphView, action: "moveOrigin:")
            graphView.addGestureRecognizer(tap)
        }
    }
    
    func pointsToDraw(sender: GraphView, scale: Double) -> [(x: Double, y: Double)]? {
        var points = [(x: Double, y: Double)]()

        guard program != nil else { return points }
        
        let brain = CalculatorBrain()
        brain.program = program!
        
        let startPoint = Int(-100 * scale)
        let endPoint = Int(100 * scale)
        
        for x in startPoint...endPoint {
            brain.variableValues["M"] = Double(x)/scale
            if let result = brain.evaluate() {
                if result.isNormal || result.isZero {
                    points.append((x: Double(x)/scale, y: result))
                }
            }
        }

        return points
    }
}
