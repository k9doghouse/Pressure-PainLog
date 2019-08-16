//
//  RoundedButton.swift
//  MMWW2
//
//  Created by murph on 9/21/18. 
//

import UIKit

@IBDesignable
public class RoundedButton : UIButton
{
    override public func layoutSubviews()
    {
        super.layoutSubviews()
        updateCornerRadiusAndBorder()
    }

    var rounded : Bool = true
        { didSet { updateCornerRadiusAndBorder() } }

    func updateCornerRadiusAndBorder()
    { layer.cornerRadius = rounded ? frame.size.height / 7 : 0
        layer.borderWidth = 0.5
        layer.borderColor = #colorLiteral(red: 0.00734347105, green: 0.2150577009, blue: 0.2202971578, alpha: 1)
        layer.backgroundColor = #colorLiteral(red: 0.008680125698, green: 0.299654603, blue: 0.304741025, alpha: 1)
    } }
