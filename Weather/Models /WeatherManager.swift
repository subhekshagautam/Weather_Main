//
//  WeatherManager.swift
//  Weather
//
//  Created by Subheksha Gautam on 17/7/2022.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather (_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}
struct WeatherManager {
    var  delegate : WeatherManagerDelegate?
    
    let weatherURL =
    //dosent worry about the order of parameter
    "https://api.openweathermap.org/data/2.5/weather?appid=9a7ddade611d6fc3684c02d71471a10c&units=metric"
    
    func fetchweather(cityName: String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude:CLLocationDegrees , longitude: CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    //for networking communicating  app to webserver(openweathermap)
    func performRequest(with urlString: String){
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
            
                if error != nil{
                    delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data{
                    if let weather = self.parseJSON(safeData){
                        self.delegate? .didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do{
            let decodeData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodeData.weather[0].id
            let temp = decodeData.main.temp
            let name = decodeData.name
            let latitude = decodeData.coord.lat
            let longitude = decodeData.coord.lon
            
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp, latitude: latitude, longitude: longitude)
            return weather
        }
        catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}






