// Regenerates the vector layers for Metrics/AppIcon.icon.
//
// Icon Composer renders every SVG path as a filled shape, even when the path
// says fill="none", so the strokes below are expanded into filled outlines with
// CoreGraphics before they are written out. Run it after changing the geometry:
//
//     swift Scripts/make_app_icon_layers.swift Metrics/AppIcon.icon/Assets

import Foundation
import CoreGraphics

let canvas: CGFloat = 1024
let strokeWidth: CGFloat = 72

/// The L-shaped chart axis.
let axisPoints = [CGPoint(x: 248, y: 300), CGPoint(x: 248, y: 724), CGPoint(x: 776, y: 724)]

/// The rising trend line, which ends at the base of the arrowhead.
let trendPoints = [CGPoint(x: 356, y: 612), CGPoint(x: 462, y: 506), CGPoint(x: 568, y: 612), CGPoint(x: 700, y: 480)]

/// The arrowhead, pointing 45° up and to the right. Its corners are rounded by
/// growing the triangle with a round-joined stroke.
let arrowheadPoints = [CGPoint(x: 629.3, y: 409.3), CGPoint(x: 806, y: 374), CGPoint(x: 770.7, y: 550.7)]
let arrowheadCornerStroke: CGFloat = 24

func polyline(_ points: [CGPoint], closed: Bool) -> CGPath {
    let path = CGMutablePath()
    path.addLines(between: points)
    if closed { path.closeSubpath() }
    return path
}

func outline(_ path: CGPath, width: CGFloat) -> CGPath {
    path.copy(strokingWithWidth: width, lineCap: .round, lineJoin: .round, miterLimit: 10)
}

func svgPathData(_ path: CGPath) -> String {
    var data = ""
    func f(_ v: CGFloat) -> String { String(format: "%.2f", v) }
    path.applyWithBlock { element in
        let p = element.pointee.points
        switch element.pointee.type {
        case .moveToPoint: data += "M\(f(p[0].x)) \(f(p[0].y)) "
        case .addLineToPoint: data += "L\(f(p[0].x)) \(f(p[0].y)) "
        case .addQuadCurveToPoint: data += "Q\(f(p[0].x)) \(f(p[0].y)) \(f(p[1].x)) \(f(p[1].y)) "
        case .addCurveToPoint: data += "C\(f(p[0].x)) \(f(p[0].y)) \(f(p[1].x)) \(f(p[1].y)) \(f(p[2].x)) \(f(p[2].y)) "
        case .closeSubpath: data += "Z "
        @unknown default: break
        }
    }
    return data.trimmingCharacters(in: .whitespaces)
}

func svgDocument(_ path: CGPath) -> String {
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <svg xmlns="http://www.w3.org/2000/svg" width="\(Int(canvas))" height="\(Int(canvas))" viewBox="0 0 \(Int(canvas)) \(Int(canvas))">
      <path fill="#FFFFFF" fill-rule="nonzero" d="\(svgPathData(path))"/>
    </svg>

    """
}

let outputDirectory = URL(fileURLWithPath: CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "Metrics/AppIcon.icon/Assets")
try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

let axis = outline(polyline(axisPoints, closed: false), width: strokeWidth).normalized(using: .winding)

let arrowhead = polyline(arrowheadPoints, closed: true)
let roundedArrowhead = arrowhead.union(outline(arrowhead, width: arrowheadCornerStroke))
let trend = outline(polyline(trendPoints, closed: false), width: strokeWidth).union(roundedArrowhead).normalized(using: .winding)

for (name, path) in [("Axis", axis), ("Trend", trend)] {
    let url = outputDirectory.appendingPathComponent("\(name).svg")
    try svgDocument(path).write(to: url, atomically: true, encoding: .utf8)
    let box = path.boundingBoxOfPath
    print("Wrote \(url.path) (bounds \(Int(box.minX)),\(Int(box.minY)) – \(Int(box.maxX)),\(Int(box.maxY)))")
}
