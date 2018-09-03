//
//  EnumFiles.swift
//  SpectroDevice
//
//  Created by Ming-En Liu on 25/07/18.
//  Copyright © 2018 Vedas labs. All rights reserved.
//

import Foundation


enum ClockDirection:Int {
    case clockWise = 0
    case counterClockwise = 1
}


enum LEDControlType : String {
    case uv = "Ultra violet LED"
    case whiteLED =  "White LED"
    case reflectionLED = "Reflection LED"
}


enum SignalProcssType : String {
    case exposure = "Exposure"
    case analogGain =  "Analog Gain"
    case digitalGain = "Digital Gain"
    case noOfAvg = "No.of Averaging"
}




