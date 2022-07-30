//
//  WeatherData.swift
//  Weather
//
//  Created by Subheksha Gautam on 17/7/2022.
//

import Foundation
struct WeatherData:Codable {
    let coord: Coord
    let main: Main
    let weather: [Weather]
    let name: String
}

// MARK: - Main
struct Main: Codable {
    let temp: Double
    let pressure, humidity: Int
}

// MARK: - Weather
struct Weather: Codable {
    let id: Int
}
// MARK: - Coord
struct Coord: Codable {
    let lon, lat: Double
}




