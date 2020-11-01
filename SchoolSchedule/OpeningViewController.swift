//
//  OpeningViewController.swift
//  SchoolSchedule
//
//  Created by Addison Hanrattie on 2/1/18.
//  Copyright © 2018 Addison Hanrattie. All rights reserved.
//

import UIKit
import UserNotifications

class OpeningViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .provisional])
        { (granted, error) in
            // Enable or disable features based on authorization.
            if error != nil {
                print(error!)
            } else {
                print("notification access ", granted)
                let catergory = UNNotificationCategory(identifier: "com.addisonHanrattie.SSClassNoti", actions: [], intentIdentifiers: [], options: .hiddenPreviewsShowTitle)
                UNUserNotificationCenter.current().setNotificationCategories([catergory])
                UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
                    print(settings)
                })
            }
        }
    } // need to incorperate as provisionals at a later date

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
