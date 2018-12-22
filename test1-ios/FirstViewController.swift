//
//  FirstViewController.swift
//  test1-ios
//
//  Created by diego on 20/12/2018.
//  Copyright © 2018 Diego. All rights reserved.
//

import UIKit
import Clocket

class FirstViewController: UIViewController {
    
    @IBOutlet weak var userName: UITextField!
    
    @IBOutlet weak var currentDateDisplay: UILabel!
    @IBOutlet weak var clock: Clocket!
    @IBOutlet weak var lastSelectedFeedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clock.displayRealTime = true
        clock.startClock()
        
        let date = Date()
        let formattedDate = DateFormatter.localizedString(from: date, dateStyle: .full, timeStyle: .none)
        currentDateDisplay.text = formattedDate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.lastSelectedFeedLabel.text = SecondViewController.getLastSelection()
    }
}

