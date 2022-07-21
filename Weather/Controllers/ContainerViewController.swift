//
//  ContainerViewController.swift
//  Weather
//
//  Created by Subheksha Gautam on 15/7/2022.
//

import Foundation
import UIKit
class ContainterViewController:UIViewController {
    
    @IBOutlet weak var SideMenuConstraints: NSLayoutConstraint!
    var sideMenuOpen = false
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(toggleSideMenu),
                                               name: NSNotification.Name("ToggleSideMenu"),
                                               object: nil)
        
    }
    @objc func toggleSideMenu() {
        if sideMenuOpen {
            sideMenuOpen = false
            SideMenuConstraints.constant = -240
            
        } else {
            sideMenuOpen = true
            SideMenuConstraints.constant = 0
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    
}
