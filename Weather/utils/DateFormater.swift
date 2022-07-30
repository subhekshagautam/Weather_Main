//
//  DateFormater.swift
//  Weather
//
//  Created by Subheksha Gautam on 30/7/2022.
//

import UIKit
 
func getFormattedDate(date: Int) -> String {
    let date = Date(timeIntervalSince1970: (Double(date)))
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "E, d MMM"
    return String((dateFormatter.string(from: date)))
}
