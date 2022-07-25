//
//  ViewController.swift
//  Weather
//
//  Created by Subheksha Gautam on 12/7/2022.
//

import UIKit
import CoreLocation
import DropDown

class MainViewController: UIViewController {
    
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var mainBackground: UIImageView!
    @IBOutlet weak var sideMenuButton: UIButton!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var conditionImage: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var predictionTable: UITableView!
    
    
    private var allData = [Daily]()
    var dailyWeatherManager = DailyWeatherManager()
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    
    let defaults = UserDefaults.standard
    
    let dropDown = DropDown()
    var searching = false
    var dropDownArray = ["sydney", "Melbourne", "Perth", "Greater Sydney", "North Sydney"]
    var filterData = [String]()
    
    public var didSelectInMenuCallBack : ((String) -> ())?
    
    // user defaults declaratoon
    // var searchedData = [String]()
   
    
    let sideBarVC = SidebarViewController()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        filterData = dropDownArray
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        searchField.setLeftImage(imageName: "magnifyingglass")
        
        let nib = UINib(nibName: "MainViewTableCell", bundle: nil)
        predictionTable.register(nib, forCellReuseIdentifier: "MainViewTableCell")
        self.predictionTable.dataSource = self
        
        //dtextfield with help od deligate notify weather view controller whats going on with textfield
        weatherManager.delegate = self
        searchField.delegate = self
        dailyWeatherManager.delegate = self
                
        // user defaults

        if let value = defaults.value(forKey: "dropdown") as? String
        {
            print("Addvaluee========= \(value)")
            dropDownArray.append(value)
            print(dropDownArray.count)
        }
        // dropdown part
        dropDown.anchorView = searchField
        dropDown.dataSource = filterData
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.topOffset = CGPoint(x: 0, y:-(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.direction = .bottom
        DropDown.appearance().backgroundColor = UIColor(red: 0.00, green: 0.42, blue: 0.46, alpha: 0.50)
        DropDown.appearance().selectionBackgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
        dropDown.reloadAllComponents()
        //dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
          //  self.searchField.text = filterData[index]
            
         //   searchField.addTarget(self, action: #selector(searchData), for: .editingChanged)
            
           
        //}
      
        
        self.didSelectInMenuCallBack = { [weak self] selectedCity
            in
            guard self != nil else { return }
            
            print(selectedCity)
            
            NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
            
            // Hit api here
            // API calling using city name input by user
            self!.showSpinner(onView: self!.view)
            self!.weatherManager.fetchweather(cityName: selectedCity)
        }
    }
    
//    @objc func searchData(sender: UITextField) {
//        print ("TextField is changing === \(searchField.text ?? "")")
//        self.filterData.removeAll()
//        let searchedData: Int = searchField.text!.count
//        if searchedData != 0 {
//            searching = true
//            for items in dropDownArray{
//                if let dataToSearch = searchField.text {
//                    let range = items.lowercased().range(of: dataToSearch, options: .caseInsensitive, range: nil, locale: nil)
//                    if  range != nil   {
//                        self.filterData.append(contentsOf: dropDownArray)
//                    }
//                }
//            }
//        }
//        else  {
//            self.filterData = self.dropDownArray
//            self.searching = false
//        }
//
//        dropDown.reloadAllComponents()
//    }
    
    @IBAction func sideMenuPressed(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
    }
}

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

//MARK: - UI TextField Delegate

extension MainViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        dropDown.show()
    }
    // return when user press return keyword in the keyword
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //delegate part
        
        defaults.set(searchField.text, forKey: "dropdown")
        
        searchField.endEditing(true)
        dropDown.hide()
        return true
        
    }
    // useful for validation on what user types
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        }
        else {
            textField.placeholder = "Type Something Here"
            return false
        }
    }
    
    //delete text fiels contents after user types search or return keyword
    func textFieldDidEndEditing(_ textField: UITextField) {
        //textfiled.text data passed by user need to be hold
        if let city = searchField.text{
            
            // Hide location icon here
            self.locationImage.isHidden = true
            
            // API calling using city name input by user
            self.showSpinner(onView: self.view)
            weatherManager.fetchweather(cityName: city)
            
            // Add city name on user default
            //            searchedData.append (city)
            //            defaults.set(self.searchedData,forKey: "UserSearched")
            //            for items in searchedData{
            //                print("default ======== \(items)")
            //
            //            }
        }
       
        searchField.text = ""
    }
    // filter data in search field
//
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//
//        return true
//    }
//
    
    
}

//MARK: - weather manager delegeate

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
    }
    func didFailWithError(error: Error) {
        print("Got error response")
        self.removeSpinner()
    }
}

//MARK: - cllocationmanager delegate

extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
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

//MARK: - Tableview Delegate
extension MainViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
}

//MARK: - TableView Datasource
extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainViewTableCell", for: indexPath)
        as! MainViewTableCell
        
        let data = allData[indexPath.row]
        let weatherModel = WeatherModel(
            conditionId: data.weather[0].id,
            cityName: "",
            temperature : 0,
            latitude : 0,
            longitude: 0)
        cell.conditionImage.image = UIImage(systemName: weatherModel.conditionName)
        
        // convert miliseconds into date fromat
        let date = Date(timeIntervalSince1970: (Double(allData[indexPath.row].dt)))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM"
        cell.dateLabel.text = String((dateFormatter.string(from: date)))
        
        cell.minTempLabel.text = String (format: "%.0f", allData[indexPath.row].temp.min)
        cell.maxTempLabel.text = String (format: "%.0f", allData[indexPath.row].temp.max)
        
        cell.isUserInteractionEnabled = false
        tableView.alwaysBounceVertical = false
        return cell
    }
    
}
extension MainViewController: DailyWeatherManagerDelegate{
    func didGetAllResponse(dailyData: DailyWeatherData) {
        allData = dailyData.daily
        allData.removeFirst()
        
        DispatchQueue.main.async {
            self.predictionTable.reloadData()
            self.removeSpinner()
        }
    }
    func failWithError(error: Error) {
        print("Got error response")
        self.removeSpinner()
    }
}

