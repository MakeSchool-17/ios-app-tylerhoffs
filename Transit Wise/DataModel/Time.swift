//
//  Time.swift
//  Transit Wise
//
//  Created by Unathi Chonco on 11/25/15.
//  Copyright © 2015 Transit Wise. All rights reserved.
//

import Foundation
/**
 *  Class representing all time deatils for legs and trips
 */
class Time {
    var start: Int?
    var end: Int?
    var duration: Int?
    var format_start: String?
    var format_end: String?
    var format_duration: String?
    var format_wait: String?
    
    /**
     Initializer

     - parameter start:           time in minutes from monday 00:00 -- 1440 minutes daily
     - parameter end:             time in minutes
     - parameter duration:        duartion in minutes   (len)
     - parameter format_start:    formatted start time  (s)
     - parameter format_end:      formatted end time    (e)
     - parameter format_duration: formatted duaration   (d)
     - parameter format_wait:     wait time             (w)
     
     */
    init(start: Int, end: Int, duration: Int, format_start: String, format_end: String, format_duration: String, format_wait: String){
        self.start = start
        self.end = end
        self.duration = duration
        self.format_start = format_start
        self.format_end = format_end
        self.format_duration = format_duration
        self.format_wait = format_wait
    }
}