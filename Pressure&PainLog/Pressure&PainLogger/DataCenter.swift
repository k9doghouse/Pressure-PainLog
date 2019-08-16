//
//  DataCenter.swift
// Pressure Tracker App 4 Pain & Migraines
//
//  Created by murph on 7/11/19.
//  Copyright © 2019 k9doghouse. All rights reserved.
//

import UIKit

struct DataCenter: Codable
{
    let pressureValue:  Double?
    let height:         Double?
    let pressureTitle:  String?
    let dateTitle:      String?
    let bigTitle:       String?
    let painTitle:      Float?
    let presentsAs:     String?


    init(
        pressureValue:  Double,
        height:         Double,
        pressureTitle:  String,
        dateTitle:      String,
        bigTitle:       String,
        painTitle:      Float,
        presentsAs:     String
        )
    {

        self.pressureValue  =    pressureValue
        self.height         =    pressureValue
        self.pressureTitle  =    pressureTitle
        self.dateTitle      =    dateTitle
        self.bigTitle       =    bigTitle
        self.painTitle      =    painTitle
        self.presentsAs     =    presentsAs
    }

}



