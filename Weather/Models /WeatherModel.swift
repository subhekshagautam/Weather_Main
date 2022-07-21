//
//  WeatherModel.swift
//  Weather
//
//  Created by Subheksha Gautam on 17/7/2022.
//

import Foundation

struct WeatherModel {
    let conditionId: Int
    let cityName: String
    let temperature : Double
    let latitude : Double
    let longitude: Double
    
    var temperatureString : String {
        return String(format: "%.1f", temperature)
    }
    
    var conditionName : String {
        switch conditionId {
        case 200...232:
            return "cloud.bolt"
        case 300...321:
            return "cloud.drizzle"
        case 500...531:
            return "cloud.rain"
        case 600...622:
            return "cloud.snow"
        case 701...781:
            return "cloud.fog"
        case 800:
            return "sun.max"
        case 801...804:
            return "cloud.bolt"
        default:
            return "cloud"
        }
    }
    
    var backgroundName : String {
        switch conditionId {
        case 200...321:
            return "bg_light_cloud"
        case 500...531:
            return "bg_water_drop"
        case 600...781:
            return "bg_light_cloud"
        case 800:
            return "bg_clean_sky"
        default:
            return "bg_light_cloud"
        }
    }
}
