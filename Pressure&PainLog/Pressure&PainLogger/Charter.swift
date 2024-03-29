//
//  Charter.swift
//  Pressure Tracker App 4 Pain & Migraines
//
//  Created by murph on 7/13/19.
//  Copyright © 2019 k9doghouse. All rights reserved.
//
///  https://github.com/k9doghouse/LineChart-Pressure.git
///

import UIKit

struct PointEntry : Codable {

    var pressureValue: Double =  1234.56
    var pressureTitle: String = "1234.56 mb"
    var dateTimeTitle: String = "11/11/1111 at 11:11"
    var bigTitle:      String = "3/29/19 at 15:37 - 1004 mb"
}

extension PointEntry: Comparable {
    static func <(lhs: PointEntry, rhs: PointEntry) -> Bool
    { return lhs.pressureValue < rhs.pressureValue }

    static func ==(lhs: PointEntry, rhs: PointEntry) -> Bool
    { return lhs.pressureValue == rhs.pressureValue }
}

class Charter: UIView {

    let lineGap: CGFloat = 14
    let topSpace: CGFloat = 40.0
    let bottomSpace: CGFloat = 40.0
    let topHorizontalLine: CGFloat = 110.0 / 100.0

    var dataEntries: [PointEntry]? { didSet { self.setNeedsLayout() } }

    private let dataLayer: CALayer = CALayer()
    private let gradientLayer: CAGradientLayer = CAGradientLayer()
    private let mainLayer: CALayer = CALayer()
    private let scrollView: UIScrollView = UIScrollView()
    private let gridLayer: CALayer = CALayer()
    private var dataPoints: [CGPoint]?

    override init(frame: CGRect) {

        super.init(frame: frame)
        setupView()
    }

    convenience init() {

        self.init(frame: CGRect.zero)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {

        mainLayer.addSublayer(dataLayer)
        scrollView.layer.addSublayer(mainLayer)
        gradientLayer.colors = [#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.7).cgColor, UIColor.clear.cgColor]
        scrollView.layer.addSublayer(gradientLayer)

        self.layer.addSublayer(gridLayer)
        self.addSubview(scrollView)
        self.backgroundColor = #colorLiteral(red: 0.008680125698, green: 0.299654603, blue: 0.304741025, alpha: 1)
    }

    override func layoutSubviews() {

        scrollView.frame = CGRect(x: 0,
                                  y: 0,
                              width: self.frame.size.width,
                             height: self.frame.size.height)

        if let dataEntries = dataEntries {

            scrollView.contentSize = CGSize(width: CGFloat(dataEntries.count) * lineGap,
                                            height: self.frame.size.height)

            mainLayer.frame = CGRect(x: 0,
                                     y: 0, width: CGFloat(dataEntries.count) * lineGap,
                                height: self.frame.size.height)

            dataLayer.frame = CGRect(x: 0,
                                     y: topSpace,
                                 width: mainLayer.frame.width,
                                height: mainLayer.frame.height - topSpace - bottomSpace)

            gradientLayer.frame = dataLayer.frame
            dataPoints = convertDataEntriesToPoints(entries: dataEntries)
            gridLayer.frame = CGRect(x: 0,
                                     y: topSpace,
                                     width: self.frame.width,
                                     height: mainLayer.frame.height - topSpace - bottomSpace)

            //dotsLayer.frame = gridLayer.frame
            clean()
            drawHorizontalLines()
            drawChart()
            maskGradientLayer()
            drawLables()
        }
    }

    /// making some cgPoints (0,0)
    private func convertDataEntriesToPoints(entries: [PointEntry]) -> [CGPoint] {

        if let max = entries.max()?.pressureValue,
            let min = entries.min()?.pressureValue {

            var result: [CGPoint] = []
            let minMaxRange: CGFloat = CGFloat(max - min) * topHorizontalLine

            for i in 0..<entries.count {
                let height = dataLayer.frame.height * (1 - ((CGFloat(entries[i].pressureValue) - CGFloat(min)) / minMaxRange))
                let point = CGPoint(x: CGFloat(i)*lineGap + 8, y: height)
                result.append(point)
            }
            return result
        }
        return []
    }


    private func drawChart() {

        if let dataPoints = dataPoints,
            dataPoints.count > 0,
            let path = createPath() {

            let lineLayer = CAShapeLayer()
            lineLayer.path = path.cgPath
            lineLayer.strokeColor = UIColor.white.cgColor
            lineLayer.fillColor = UIColor.clear.cgColor
            dataLayer.addSublayer(lineLayer)
        }
    }


    private func createPath() -> UIBezierPath? {

        guard let dataPoints = dataPoints,
            dataPoints.count > 0 else { return nil }

        let path = UIBezierPath()
        path.move(to: dataPoints[0])

        for i in 0..<dataPoints.count {
            path.addLine(to: dataPoints[i])

            path.addArc(withCenter: dataPoints[i],
                            radius: 1.00,
                        startAngle: 0.00,
                          endAngle: 359.59,
                         clockwise: true)
        }
        return path
    }


    private func maskGradientLayer() {

        if let dataPoints = dataPoints,
            dataPoints.count > 0 {

            let path = UIBezierPath()
            path.move(to: CGPoint(x: dataPoints[0].x,
                                  y: dataLayer.frame.height))

            path.addLine(to: dataPoints[0])

            let straightPath = createPath()
            path.append(straightPath ?? path)

            path.addLine(to: CGPoint(x: dataPoints[dataPoints.count-1].x,
                                     y: dataLayer.frame.height))

            path.addLine(to: CGPoint(x: dataPoints[0].x,
                                     y: dataLayer.frame.height))

            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            maskLayer.fillColor = UIColor.white.cgColor
            maskLayer.strokeColor = UIColor.clear.cgColor
            maskLayer.lineWidth = 0.5

            gradientLayer.mask = maskLayer
        }
    }


    private func drawLables() {

        if let dataEntries = dataEntries,
            dataEntries.count > 0 {

            //MARK - horizontal (bottom) titles/dates
            for i in 0..<dataEntries.count {

                let textLayer = CATextLayer()

                textLayer.frame = CGRect(x: lineGap*CGFloat(i) - lineGap/2 + 4,
                                         y: mainLayer.frame.size.height - bottomSpace/2,
                                     width: lineGap*7,
                                    height: 24)

                textLayer.foregroundColor = #colorLiteral(red: 0.7813339243, green: 1, blue: 0.8151393496, alpha: 1).cgColor
                textLayer.backgroundColor = UIColor.clear.cgColor
                textLayer.alignmentMode = CATextLayerAlignmentMode.center
                textLayer.contentsScale = UIScreen.main.scale
                textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
                textLayer.fontSize = 10

                //MARK - only display the n'th label.text
                if (i % 10) == 0 {
                    textLayer.string = dataEntries[i].dateTimeTitle
                } else {
                    textLayer.string = ""
                }
                mainLayer.addSublayer(textLayer)
            }
        }
    }


    private func drawHorizontalLines() {
        guard let dataEntries = dataEntries else { return }

        var gridValues: [CGFloat]? = nil

        if dataEntries.count < 4 && dataEntries.count > 0 {

            gridValues = [0, 1]
        } else if dataEntries.count >= 4 {

            gridValues = [0, 0.25, 0.5, 0.75, 1]
        }
        if let gridValues = gridValues {

            for value in gridValues {

                let height = value * gridLayer.frame.size.height

                let path = UIBezierPath()
                path.move(to: CGPoint(x: 0, y: height))
                path.addLine(to: CGPoint(x: gridLayer.frame.size.width, y: height))
                path.addQuadCurve(to: CGPoint(x: 0, y: height), controlPoint: CGPoint(x: 0, y: height))

                let lineLayer = CAShapeLayer()
                lineLayer.path = path.cgPath
                lineLayer.fillColor = UIColor.clear.cgColor
                lineLayer.strokeColor = #colorLiteral(red: 0.8019491013, green: 1, blue: 0.7879793321, alpha: 1).cgColor
                lineLayer.lineWidth = 0.5

                if (value > 0.0 && value < 1.0)
                { lineLayer.lineDashPattern = [4, 4] }

                gridLayer.addSublayer(lineLayer)

                var minMaxGap:CGFloat = 0
                var lineValue:Int = 0

                if let max = dataEntries.max()?.pressureValue,
                    let min = dataEntries.min()?.pressureValue {

                    minMaxGap = CGFloat(max - min) * topHorizontalLine
                    lineValue = Int((1 - value) * minMaxGap) + Int(min)
                }
                
                //MARK - Vertical (left-side) titles/lines
                let textLayer = CATextLayer()
                
                textLayer.frame = CGRect(x: 4,
                                         y: height,
                                     width: 24,
                                    height: 10)

                textLayer.foregroundColor = #colorLiteral(red: 0.7813339243, green: 1, blue: 0.8151393496, alpha: 1).cgColor
                textLayer.backgroundColor = UIColor.clear.cgColor
                textLayer.contentsScale = UIScreen.main.scale
                textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
                textLayer.fontSize = 10
                textLayer.string = "\(lineValue)"

                gridLayer.addSublayer(textLayer)
            }
        }
    }

    private func clean() {
        mainLayer.sublayers?.forEach({
            if $0 is CATextLayer {
                $0.removeFromSuperlayer()
            }
        })
        
        dataLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
        gridLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
    }

    // MARK - IBActions
    @IBAction func refreshButtonTapped(_ sender: UIButton)
        { ChartViewController().getSensorData() }
}

