//
//  MainControllerExtension.swift
//  Weather
//
//  Created by Subheksha Gautam on 27/7/2022.
//

import CoreLocation
import UIKit


//MARK: - UItextfield padding and image adjustment
extension  UITextField{
    func setLeftImage(imageName: String) {
        self.leftView = UIView(frame: CGRect(x: 10, y: 0, width: 30, height: 40))
        self.leftViewMode = .always
        let leftViewItSelf = UIImageView(frame: CGRect(x: 10, y: 10, width: 20, height: 20))
        leftViewItSelf.image = UIImage(systemName: imageName)
        self.tintColor = .white
        
        leftView?.addSubview(leftViewItSelf)
    }
}

//MARK: - cllocationmanager delegate

extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationManager.stopUpdatingLocation()
            
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            print("lat: \(lat), long: \(lon)")
            
            // show location icon here
            self.locationImage.isHidden = false
            
            // API call using user current location ie. lat/long
            self.showSpinner(onView: self.view)
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

//MARK: - weather manager delegeate, Get and show todays weather

extension MainViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        
        //Here you get API response from first API call ie from WeatherManager
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.temperatureString
            self.conditionImage.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
            
            // Make main backgroud dynamic
            self.mainBackground.image = UIImage(named: weather.backgroundName)
            
            // We make second API call to get 7 days of weatehr report
            // using DailyWeatherManager to fetch 7 days of weather.
            self.dailyWeatherManager.performRequestFor7DaysWeather(latitude: weather.latitude,longitude: weather.longitude)
        }
        //Saving only from sucess cities response on user defaults
        // if dropDownArray count >=10 remove 0 position city and append new city
        if !dropDownArray.contains(weather.cityName){
            if dropDownArray.count >= 10{
                dropDownArray.remove(at: 0)
            }
            dropDownArray.append (weather.cityName.capitalized)
        }
        
        defaults.set(self.dropDownArray,forKey: userDefaultKey)
        for items in dropDownArray{
            print("default: \(items)")
        }
    }
    func didFailWithError(error: Error) {
        print("Got error response")
        self.removeSpinner()
    }
}

//MARK: - TableView Datasource
extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allDaysData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainViewTableCell", for: indexPath)
        as! MainViewTableCell
        
        let data = allDaysData[indexPath.row]
        let weatherModel = WeatherModel(
            conditionId: data.weather[0].id,
            cityName: "",
            temperature : 0,
            latitude : 0,
            longitude: 0)
        cell.conditionImage.image = UIImage(systemName: weatherModel.conditionName)
        
        // convert miliseconds into date fromat
        let date = Date(timeIntervalSince1970: (Double(data.dt)))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM"
        cell.dateLabel.text = String((dateFormatter.string(from: date)))
        
        cell.minTempLabel.text = String (format: "%.0f", data.temp.min)
        cell.maxTempLabel.text = String (format: "%.0f", data.temp.max)
        
        cell.isUserInteractionEnabled = false
        tableView.alwaysBounceVertical = false
        return cell
    }
}

//MARK: - Get daily response 8days
extension MainViewController: DailyWeatherManagerDelegate{
    func didFailWithError(error: Error?, message: String?) {
        print("Something is wrong: Error:\(error.debugDescription) ||| Message:\(message ?? "")")
        self.removeSpinner()
        
        // Show error dialog box with generic message
        DispatchQueue.main.async {
            UIAlertController.alert(title:"Error", msg:"Please type correct city name", target: self)
        }
    }
    
    func didGetAllResponse(dailyData: DailyWeatherData) {
        allDaysData = dailyData.daily
        allDaysData.removeFirst()
        
        DispatchQueue.main.async {
            self.predictionTable.reloadData()
            self.removeSpinner()
        }
    }
}

//MARK: - To hide keyword when user tab on the views
extension UIViewController {
    func hideKeyboardWhenTappedAround(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyword))
        view.addGestureRecognizer(tapGesture)
    }
    @objc func hideKeyword(){
        view.endEditing(true)
        
        // Hide slide menu if it's open after touching main screen.
        NotificationCenter.default.post(name: NSNotification.Name("HideSideMenu"), object: nil)
    }
}
