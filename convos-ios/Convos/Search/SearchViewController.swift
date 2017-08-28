//
//  SearcViewController.swift
//  Convos
//
//  Created by Rahul Madduluri on 8/27/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    var searchTextField: SearchTextField = SearchTextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSearchTextField()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchTextField.frame = CGRect(x: 50, y: 50, width: 200, height: 100)
        self.view.addSubview(searchTextField)
    }
    
    fileprivate func configureSearchTextField() {
        searchTextField.startVisibleWithoutInteraction = true
        searchTextField.filterStrings(["Rahul", "Reia", "Prafulla", "Paneer"])
    }
    
}
