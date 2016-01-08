//
//  GraphView.swift
//  Calculator
//
//  Created by 배휘동 on 2015. 12. 30..
//  Copyright © 2015년 배휘동. All rights reserved.
//

import UIKit

protocol GraphViewDataSource: class {
    func pointsToDraw(sender: GraphView, scale: Double) -> [(x: Double, y:Double)]?
}

@IBDesignable
class GraphView: UIView {    
    @IBInspectable
    var color: UIColor = UIColor.blueColor() { didSet { setNeedsDisplay() } }
    
    private let defaults = NSUserDefaults.standardUserDefaults()

    @IBInspectable
    var scale: CGFloat {
        get {
            return defaults.objectForKey(Constants.ScaleKey) as? CGFloat ?? 1.0
        }
        set {
            defaults.setObject(newValue, forKey: Constants.ScaleKey)
            setNeedsDisplay()
        }
    }

    private var originTranslation: CGPoint {
        get {
            return CGPointFromString(defaults.objectForKey(Constants.OriginKey) as? String ?? "(0, 0)")
        }
        set {
            defaults.setObject(NSStringFromCGPoint(newValue), forKey: Constants.OriginKey)
        }
    }
    
    private struct Constants {
        static let ScaleKey = "GraphView.Scale"
        static let OriginKey = "GraphView.Origin"
    }
    
    private var graphCenter: CGPoint {
        return convertPoint(center, fromView: superview)
    }
    
    func scale(gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .Changed:
            scale *= gesture.scale
            gesture.scale = 1
        default: break
        }
    }
    
    func moveWholeGraph(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Changed:
            let translation = gesture.translationInView(self)
            center.x += translation.x
            center.y += translation.y
            gesture.setTranslation(CGPointZero, inView: self)
        default: break
        }
    }
    
    func moveOrigin(gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.locationInView(self)
        originTranslation = CGPointMake(tapLocation.x - graphCenter.x, tapLocation.y - graphCenter.y)
        setNeedsDisplay()
    }
    
    weak var dataSource: GraphViewDataSource?
    
    private func newPoint(point: (x:Double, y:Double)) -> CGPoint {
        let pointX = CGFloat(point.x) * scale + graphCenter.x + originTranslation.x
        let pointY = CGFloat(-point.y) * scale + graphCenter.y + originTranslation.y
        return CGPoint(x: pointX, y: pointY)
    }
    
    override func drawRect(rect: CGRect) {
        let axes = AxesDrawer(color: UIColor.blackColor(), contentScaleFactor: contentScaleFactor)
        axes.drawAxesInRect(bounds, origin: graphCenter, pointsPerUnit: scale)
        
        let path = UIBezierPath()
        
        if var points = dataSource?.pointsToDraw(self, scale: Double(scale)) {
            if let start = points.first {
                path.moveToPoint(newPoint(start))
                points.removeFirst()
                for point in points {
                    path.addLineToPoint(newPoint(point))
                }
            }
        }
        
        color.set()
        path.stroke()
    }
}
