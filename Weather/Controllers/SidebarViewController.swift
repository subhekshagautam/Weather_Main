//
//  SidebarViewController.swift
//  Weather
//
//  Created by Subheksha Gautam on 13/7/2022.
//

import Foundation
import UIKit

class SidebarViewController: UIViewController {

    
    var sideMenu = ["Sydney","Perth", "Melbourne"]
  
    
  //  defaults.object(forKey: "SavedArray") as? [String] ?? [String]()

    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "TableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cellidentity")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }
    
}
//MARK: - Tableview Delegate
extension SidebarViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let city = sideMenu[indexPath.row]
        print("City selected : \(city)")
        
        
        // close slide menu
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
        
        
    }
}

//MARK: - TableView Datasource
extension SidebarViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sideMenu.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellidentity", for: indexPath) as! TableViewCell
        cell.titleLabel.text = sideMenu[indexPath.row]
        return cell
    }
}
