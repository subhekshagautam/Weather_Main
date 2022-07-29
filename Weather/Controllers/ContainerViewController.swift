//
//  ContainerViewController.swift
//  Weather
//
//  Created by Subheksha Gautam on 15/7/2022.
//

import Foundation
import UIKit
class ContainterViewController:UIViewController {
    
    
    @IBOutlet weak var sideContainerView: UIView!
    @IBOutlet weak var mainCointainerView: UIView!
    @IBOutlet weak var SideMenuConstraints: NSLayoutConstraint!
    
    var sideMenuOpen = false
    var mainVC : MainViewController!
    var sideVC : SidebarViewController!
    var gesture : UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(toggleSideMenu),
                                               name: NSNotification.Name("ToggleSideMenu"),
                                               object: nil)
        
        
        self.mainVC = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController
        self.addContainerView(content: self.mainVC, backgroundView: self.mainCointainerView)
        
        self.sideVC = self.storyboard?.instantiateViewController(withIdentifier: "SidebarViewController") as? SidebarViewController
        self.sideVC.didSelectInMenuCallBack = { [weak self]  selectedCity in
            guard let `self` = self else { return }
            
          self.mainVC.didSelectInMenuCallBack?(selectedCity)
        }
        self.addContainerView(content: self.sideVC, backgroundView: self.sideContainerView)
        
      //  gesture = UITapGestureRecognizer(target: self, action: #selector(ContainterViewController.toggleSideMenu))

    }
    @objc func toggleSideMenu() {
        if sideMenuOpen {
            sideMenuOpen = false
            SideMenuConstraints.constant = -240
         //   self.view.removeGestureRecognizer(gesture!)
            
        } else {
            sideMenuOpen = true
            SideMenuConstraints.constant = 0
           // self.view.addGestureRecognizer(gesture!)
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
// MARK:-add viewcontroller to container
    fileprivate func addContainerView(content:UIViewController, backgroundView : UIView){
        
        self.addChild(content)
        backgroundView.addSubview(content.view)
        
        content.view.frame.origin = backgroundView.bounds.origin
        content.view.frame.size = backgroundView.bounds.size
        content.didMove(toParent: self)
    }
    
}
