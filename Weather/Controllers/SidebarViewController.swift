//
//  SidebarViewController.swift
//  Weather
//
//  Created by Subheksha Gautam on 13/7/2022.
//

import Foundation
import UIKit


class SidebarViewController: UIViewController {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    let defaults = UserDefaults.standard
    public var didSelectInMenuCallBack : ((String) -> ())?
    var sideMenu = ["Sydney","Perth", "Melbourne"]
    
    
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
        let selectedCity = sideMenu[indexPath.row]
        print("City selected : \(selectedCity)")
        self.didSelectInMenuCallBack?(selectedCity)
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // remove the item from the data model
            sideMenu.remove(at: indexPath.row)
            
            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // Not used in our example, but if you were adding a new row, this is where you would do it.
        }
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



