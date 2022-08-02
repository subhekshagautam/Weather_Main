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
    @IBOutlet weak var favoriteIcon: HeartButton!
    
    var allDaysData = [Daily]()
    var dailyWeatherManager = DailyWeatherManager()
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    var gesture : UITapGestureRecognizer?
    
    let defaults = UserDefaults.standard
    
    let dropDown = DropDown()
    var searching = false
    var dropDownArray = ["Sydney", "Melbourne", "Perth"]
    var filteredArray = [String]()
    var favouriteArray = [String]()
    
    public var didSelectInMenuCallBack : ((String) -> ())?
    
    public var didFavoriteAddedCallBack : (([String]) -> ())?
    
    public var didDeletedCityInMenuCallBack : ((String) -> ())?
    
    let sideBarVC = SidebarViewController()
    
    var isClickedDropDown = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        
        searchField.setLeftImage(imageName: "magnifyingglass")
        let nib = UINib(nibName: "MainViewTableCell", bundle: nil)
        predictionTable.register(nib, forCellReuseIdentifier: "MainViewTableCell")
        self.predictionTable.dataSource = self
        
        //dtextfield with help od deligate notify weather view controller whats going on with textfield
        weatherManager.delegate = self
        searchField.delegate = self
        dailyWeatherManager.delegate = self
        
        //setting previous data to array so that we get all saved data when run app again
        favouriteArray = defaults.array(forKey: Constants.favouriteUserDefaultKey) as? [String] ?? favouriteArray
        dropDownArray = defaults.array(forKey: Constants.dropdownUserDefaultKey) as? [String] ?? dropDownArray
        
        filteredArray = dropDownArray
        print("dropDownArray ======== \(dropDownArray.count)")
        
        
        
        // dropdown part
        dropDown.anchorView = searchField
        dropDown.dataSource = dropDownArray
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.topOffset = CGPoint(x: 0, y:-(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.direction = .bottom
        DropDown.appearance().cornerRadius = 16
        DropDown.appearance().backgroundColor = UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 0.70)
        DropDown.appearance().selectionBackgroundColor = UIColor.lightGray.withAlphaComponent(0.60)
        dropDown.reloadAllComponents()
        
        // Action triggered on dropdown item selection
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            isClickedDropDown = true
            hideKeyword()
            // API calling using city name
            apiCallByCityName(city: filteredArray[index])
            //dropDownArray = searchedArray
        }
        // filter string in user pressed text field
        searchField.addTarget(self, action: #selector(searchRecords(_:)), for: .editingChanged)
        
        self.didSelectInMenuCallBack = { [weak self] selectedCity in
            guard self != nil else { return }
            
            print(selectedCity)
            
            NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
            
            // Hit api here
            self!.apiCallByCityName(city: selectedCity)
        }
        // heart button
        favoriteIcon.addTarget(self, action: #selector(favouriteIconPressed(_:)), for: .touchUpInside)
        
        self.didDeletedCityInMenuCallBack = { [weak self] deletedCity in
            guard self != nil else { return }
            
            if(self!.favouriteArray.contains(deletedCity)){
                // City is already listed as favorite. Remove from favorite and update icon
                self!.favouriteArray.remove(at: self!.favouriteArray.firstIndex(of: deletedCity)!)
                if (deletedCity == self!.cityLabel.text){
                self!.favoriteIcon.flipLikedState(liked: false)
                }
            }
            
        }
        //Hiding keyword when user taps on main screen
        hideKeyboardWhenTappedAround()
    }
    @objc func searchRecords(_ textField: UITextField){
        self.filteredArray.removeAll()
        if textField.text?.count != 0 {
            for city in dropDownArray{
                if let cityTosearch = textField.text{
                    let range = city.lowercased().range(of: cityTosearch, options: .caseInsensitive, range: nil , locale: nil)
                    if range != nil {
                        self.filteredArray.append(city)
                    }
                }
            }
        } else {
            filteredArray = dropDownArray
        }
        
        dropDown.dataSource = filteredArray
        if dropDown.isHidden{
            dropDown.show()
        } else {
            dropDown.reloadAllComponents()
        }
    }
    
    @IBAction func sideMenuPressed(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
    }
    
    @objc private func favouriteIconPressed(_ sender: UIButton) {
        
        guard let button = sender as? HeartButton else { return }
        
        // Check if the city is already on favourite list of not
        let cityName = cityLabel.text
        if(cityName != nil && !favouriteArray.contains(cityName ?? "-")){
            // If city is not listed on favorite list then add to favourite and update icon
            favouriteArray.append(cityName!)
            defaults.set(self.favouriteArray,forKey: Constants.favouriteUserDefaultKey)
            button.flipLikedState(liked: true)
        } else if(cityName != nil && favouriteArray.contains(cityName ?? "-")){
            // City is already listed as favorite. Remove from favorite and update icon
            favouriteArray.remove(at: favouriteArray.firstIndex(of: cityName!)!)
            defaults.set(self.favouriteArray,forKey: Constants.favouriteUserDefaultKey)
            button.flipLikedState(liked: false)
        }
        
        self.didFavoriteAddedCallBack?(favouriteArray)
    }
    
}
//MARK: - UI TextField Delegate
extension MainViewController: UITextFieldDelegate {
    
    //calling for the first time when user clicks on UITextField
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // if dropdown is showing update else show
        dropDownArray = defaults.array(forKey: Constants.dropdownUserDefaultKey) as? [String] ?? dropDownArray
        filteredArray = dropDownArray
        dropDown.dataSource = dropDownArray
        dropDown.show()
    }
    
    // return when user press return keyword in the keyword
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        isClickedDropDown = false
        searchField.endEditing(true)
        dropDown.hide()
        hideKeyword()
        return true
    }
    //delete text fiels contents after user types search or return keyword
    func textFieldDidEndEditing(_ textField: UITextField) {
        //textfiled.text data passed by user need to be hold
        if let city = searchField.text?.trimmingCharacters(in: .whitespacesAndNewlines){
            if(!city.isEmpty && !isShowingSpinner() && !isClickedDropDown) {
                apiCallByCityName(city: city)
            }
        }
        
        //delete text fiels contents after user types search or return keyword
        searchField.text = ""
    }
    
    func apiCallByCityName(city: String){
        
        // Hide location icon here
        self.locationImage.isHidden = true
        
        // API calling using city name input by user
        self.showSpinner(onView: self.view)
        weatherManager.fetchweather(cityName: city)
    }
    
}


