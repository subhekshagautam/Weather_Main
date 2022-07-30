//
//  WeatherTests.swift
//  WeatherTests
//
//  Created by Subheksha Gautam on 30/7/2022.
//

import XCTest
@testable import Weather

class WeatherTests: XCTestCase {
    let weatherUtil = WeatherDateFormatter()
    
    func testWeatherDateFormatter_Sucess(){
        XCTAssertEqual(weatherUtil.getFormattedDate(dateInSec: 1659146400), "Sat, 30 Jul")
    }
    
    func testWeatherDateFormatter_Fail(){
        XCTAssertNotEqual(weatherUtil.getFormattedDate(dateInSec: 1659146400), "Sun, 3 Jul")
    }
    
}
