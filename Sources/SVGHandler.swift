//
//  SVGHandler.swift
//  Porygon-Demo
//
//  Created by Pavel Kozlov on 17/04/2018.
//  Copyright © 2018 DevinShine. All rights reserved.
//

import Foundation
import PocketSVG

class SVGHandler: NSObject {
    let width = "width"
    let height = "height"
    
    override init() {
        super.init()
        
        let filePath = URL.init(fileURLWithPath: NSTemporaryDirectory().appending("parrot.svg"))
        let svgString = try! String.init(contentsOf: filePath)
        
        let porygon = DVSPorygon()
        porygon.minSquare = 0.00005
        porygon.maxSquare = 0.0005
        porygon.colorTolerance = 0.01
        
        svgString.enumerateLines { (line, stop) in
            if line.contains(self.width) && line.contains(self.height) {
                let components = line.components(separatedBy: " ")
                for component in components {
                    if component.contains(self.width) {
                        porygon.imageWidth = Float(component.replacingOccurrences(of: "\(self.width)=\"", with: "").replacingOccurrences(of: "px\"", with: ""))!
                    }
                    if component.contains(self.height) {
                        porygon.imageHeight = Float(component.replacingOccurrences(of: "\(self.height)=\"", with: "").replacingOccurrences(of: "px\"", with: ""))!
                    }
                }
            }
        }
        
        let paths = SVGBezierPath.pathsFromSVG(at: filePath)
        
        var svgPolylines = [SVGPolyline]()
        
        for (_, svgPath) in paths.enumerated() {
            let points = svgPath.cgPath.points()
            let identifier = svgPath.svgAttributes["id"] as! String
            let color = UIColor(cgColor: svgPath.svgAttributes["fill"] as! CGColor)
            let hexColor = color.hexStringForColor()!
            var valuePoints = [NSValue]()
            for point in points {
                valuePoints.append(NSValue.init(cgPoint: CGPoint.init(x: round(Double(point.x)), y: round(Double(point.y)))))
            }
            let orderedSet = NSOrderedSet(array: valuePoints)
            
            let svgPolyline = SVGPolyline(identifier: identifier, withHexColor: hexColor, withPoints: orderedSet.array as! [NSValue])
            svgPolylines.append(svgPolyline)
        }
        
        print("before svgPolylines", svgPolylines.count)
        
        porygon.currentPolylines = NSMutableArray(array: svgPolylines)
        porygon.generateSVG({ (progress) in
//            print(progress)
        }) { (svgString, result) in
            
            print("result", result!)
            
            let svgData = svgString!.data(using: String.Encoding.utf8)
            let filePathResult = URL.init(fileURLWithPath: NSTemporaryDirectory().appending("parrot_result.svg"))
            try? FileManager.default.removeItem(at: filePathResult)
            try! svgData?.write(to: filePathResult)
        }
    }
}


