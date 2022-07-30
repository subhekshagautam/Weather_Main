//
//  DailyWeatherManager.swift
//  Weather
//
//  Created by Subheksha Gautam on 18/7/2022.
//

import Foundation

protocol DailyWeatherManagerDelegate {
    func didGetAllResponse(dailyData: DailyWeatherData)
    func didFailWithError(error: Error?, message: String?)
}

struct DailyWeatherManager {
    
    let apiKey = "9a7ddade611d6fc3684c02d71471a10c"
    let baseURL = "https://api.openweathermap.org/data/2.5/onecall"
    
    var delegate : DailyWeatherManagerDelegate?
    
    // Network call to fetch 7 days of weather
    func performRequestFor7DaysWeather(latitude: Double, longitude:Double){
        //URLComponents to the rescue!
        var urlBuilder = URLComponents(string: baseURL)
        
        
        //  If you want to pass query in standard way
        
        urlBuilder?.queryItems = [
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude)),
            URLQueryItem(name: "exclude", value: "alerts,hourly,minutely,current"),
            URLQueryItem(name: "units", value: "metric"),
        ]
        
        guard let url = urlBuilder?.url else {
            delegate?.didFailWithError(error: nil, message: "Invalid URL")
            print("URL: Invalide")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 10.0
        sessionConfig.timeoutIntervalForResource = 20.0
        
        let session = URLSession(configuration: sessionConfig)
        
        session.dataTask(with: request) { (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("DailyWeatherManager statusCode ======== \(httpResponse.statusCode)")
            }
            
            if error != nil {
                self.delegate?.didFailWithError(error: error, message: "")
                return
            }
            
            if let safeData = data {
                if let dailyData = self.parseJSON(safeData) {
                    self.delegate?.didGetAllResponse(dailyData: dailyData)
                }
            }
        }.resume()
    }
    
    func parseJSON(_ dailyData: Data) -> DailyWeatherData? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(DailyWeatherData.self, from: dailyData)
            return decodedData
            
        } catch {
            print("Something is wrong")
            delegate?.didFailWithError(error: error, message: "")
            return nil
        }
    }
    
}






