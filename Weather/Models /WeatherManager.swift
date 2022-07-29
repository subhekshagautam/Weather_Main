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
    func didFailWithError(error: Error?, message: String?)
}
struct WeatherManager {
    var  delegate : WeatherManagerDelegate?
    
    let apiKey = "9a7ddade611d6fc3684c02d71471a10c"
    let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    
    
    func fetchweather(cityName: String){
        //URLComponents to the rescue!
        var urlBuilder = URLComponents(string: baseURL)
        //  If you want to pass query in standard way
        
        urlBuilder?.queryItems = [
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "q", value: cityName),
            URLQueryItem(name: "units", value: "metric"),
        ]
        
        guard let cityUrl = urlBuilder?.url else {
            delegate?.didFailWithError(error: nil, message: "Invalid URL")
            print("URL: Invalide")
            return
        }
        
        performRequest(with: cityUrl)
    }
    
    func fetchWeather(latitude:CLLocationDegrees , longitude: CLLocationDegrees){
        //URLComponents to the rescue!
        var urlBuilder = URLComponents(string: baseURL)
        //  If you want to pass query in standard way
        
        urlBuilder?.queryItems = [
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude)),
            URLQueryItem(name: "units", value: "metric"),
        ]
        
        guard let latLongUrl = urlBuilder?.url else {
            delegate?.didFailWithError(error: nil, message: "Invalid URL")
            print("URL: Invalide")
            return
        }
        
        performRequest(with: latLongUrl)
    }
    
    //for networking communicating  app to webserver(openweathermap)
    func performRequest(with requestUrl: URL){
        print("WeatherManager Url ======== \(requestUrl.absoluteURL)")
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 10.0
        sessionConfig.timeoutIntervalForResource = 20.0
        
        let session = URLSession(configuration: sessionConfig)
        
        session.dataTask(with: request) { data, response, error in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("WeatherManager statusCode ======== \(httpResponse.statusCode)")
            }
            
            if error != nil{
                delegate?.didFailWithError(error: error, message: "")
                return
            }
            
            if let safeData = data{
                if let weather = self.parseJSON(safeData){
                    self.delegate? .didUpdateWeather(self, weather: weather)
                }
            }
        }.resume()
        
    }
    
    // Parsing response
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
            delegate?.didFailWithError(error: error, message: "")
            return nil
        }
    }
}
