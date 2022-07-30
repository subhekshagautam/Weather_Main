//
//  DailyWeatherData.swift
//  Weather
//
//  Created by Subheksha Gautam on 17/7/2022.
//

import Foundation

struct DailyWeatherData:Codable {
        let daily: [Daily]
    }

    // MARK: - Daily
struct Daily : Codable{
        let dt: Int
        let temp: Temp
        let weather: [Weather]
    }

    // MARK: - Temp
struct Temp: Codable {
        let min, max: Double
    }
