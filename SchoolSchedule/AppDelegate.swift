//
//  AppDelegate.swift
//  SchoolSchedule
//
//  Created by Addison Hanrattie on 1/25/18.
//  Copyright © 2018 Addison Hanrattie. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        application.setMinimumBackgroundFetchInterval(21600.0)
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
//        self.saveContext()
        CoreDataStack.saveContext()
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let day = Calendar.current.component(.day, from: Date())
        let weekday = Calendar.current.component(.weekday, from: Date())
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notifications) in
//            if !notifications.isEmpty || (UserDefaults.standard.integer(forKey: "lastFetch") == day){
//                completionHandler(.noData)
//            } else {
//                completionHandler(self.generateNewNotifications())
//            }
//            completionHandler(self.generateNewNotifications())
            let i = (UserDefaults.standard.integer(forKey: "lastFetch"))
            if ((UserDefaults.standard.integer(forKey: "lastFetch") == day) && !((weekday == 1) || (weekday == 7))) {
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { (requests) in
                    for request in requests {
                        print(request.trigger as! UNCalendarNotificationTrigger)
                    }
                    print(requests.count)
                    completionHandler(self.generateNewNotifications())
                })
                print("a")
//                completionHandler(self.generateNewNotifications())
            } else {
                print("No Data")
                completionHandler(.noData)
            }
        }
        UserDefaults.standard.set(day, forKey: "lastFetch")
    }
    
    func generateNewNotifications() -> UIBackgroundFetchResult {
        let context = CoreDataStack.managedObjectContext
        let dateRequest = NSFetchRequest<NSManagedObject>(entityName: "DayBaseline")
        let baseline : Date!
        do {
            let baseEnt = try context.fetch(dateRequest)
            baseline = baseEnt.first!.value(forKey: "baseline") as! Date
        } catch {
            print(error)
            return .failed
        }
        let now = Date()
        let calendar = Calendar.current
        //      NOTE: Errors Will Occur Here must be Calibrated
        let interval = now.timeIntervalSince(baseline) / 86400
        let nowComp = Calendar.current.dateComponents(in: TimeZone.current, from: Date())
        let baseComp = Calendar.current.dateComponents(in: TimeZone.current, from: baseline)
        var interval4 = -1
        if nowComp.weekOfYear == baseComp.weekOfYear {
            interval4 = Int(floor(interval))
        } else {
            let bInterval = Int(floor(interval))
            var wkDy1 = 5
            var wkDy2 = 0
            if nowComp.weekday == 7 {
                wkDy1 = 5
            } else if nowComp.weekday != 1 {
                wkDy1 = nowComp.weekday! - 1
            }
            if baseComp.weekday == 7 {
                wkDy2 = 0
            } else if baseComp.weekday != 1 {
                wkDy2 = (7 - baseComp.weekday!) - 1
            }
            if (nowComp.weekOfYear! - baseComp.weekOfYear!) >= 2 {
                interval4 = wkDy1 + wkDy2 + (((nowComp.weekOfYear! - baseComp.weekOfYear!) - 1) * 5)
                if interval4 > 8 {
                    interval4 = interval4 % 8
                }
            } else {
                interval4 = wkDy1 + wkDy2
                if interval4 > 8 {
                    interval4 = interval4 % 8
                }
            }
        }
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        if hour >= 14 && minute > 5 {
            if interval4 == 8 {
                interval4 = 1
            } else {
                interval4 += 1
            }
            
        }
        let interval5 = interval4
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ClassData")
        let dayPredicate = NSPredicate(format: "day = %@", "\(interval5 + 1)")
        let hdescriptor = NSSortDescriptor(key: "hour", ascending: true) //changed
        let mdescriptor = NSSortDescriptor(key: "minute", ascending: true)
        fetchRequest.predicate = dayPredicate
        fetchRequest.sortDescriptors = [hdescriptor, mdescriptor]
        do {
            var results = try context.fetch(fetchRequest)
            for i in 0...results.count - 1 {
                let result = results[i]
                var endResult : NSManagedObject?
                if i != (results.count - 1) {
                    endResult = results[i + 1]
                }
                createNotification(managed: result, endManaged: endResult)
            }
            return .newData
            //            display(managed: results.last, endManaged: endResults[safe: results.count])
        } catch {
            print(error)
            return .failed
        }
    }

    func createNotification(managed: NSManagedObject, endManaged: NSManagedObject?) {
        let context = CoreDataStack.managedObjectContext
        let fixation = (managed.value(forKey: "classnumber") ?? -1) as! Int
        let endFixation = (endManaged?.value(forKey: "classnumber") ?? -1) as! Int
        var resource: NSManagedObject?
        var endResource: NSManagedObject?
        let resourceRequest = NSFetchRequest<NSManagedObject>(entityName: "ClassResources")
        resourceRequest.predicate = NSPredicate(format: "classnumber = %@", "\(fixation + 1)")
        let endResourceRequest = NSFetchRequest<NSManagedObject>(entityName: "ClassResources")
        endResourceRequest.predicate = NSPredicate(format: "classnumber = %@", "\(endFixation + 1)")
        do {
            let resources = try context.fetch(resourceRequest)
            resource = resources.first
            let endResources = try context.fetch(endResourceRequest)
            endResource = endResources.first
        } catch {
            print(error)
        }
        let content = UNMutableNotificationContent()
        let firstClassName = (resource?.value(forKey: "classname") ?? "err") as! String
        var secondClassName = (endResource?.value(forKey: "classname") ?? "err") as! String
        if endResource == nil {
            secondClassName = "done"
        }
        content.title = firstClassName + " -> " + secondClassName
        //        content.userInfo = ["classData" : classData, "classResources" : classResources, "finalResources" : finalResources ?? 0, "finalData" : finalData ?? 0]
        content.body = "\(Date().timeIntervalSinceReferenceDate)"
        content.subtitle = "\(Date().timeIntervalSinceReferenceDate)"
        content.categoryIdentifier = "com.addisonHanrattie.SSClassNoti"
        
        var hour = (endManaged?.value(forKey: "hour") ?? 14) as! Int
        var minute = (endManaged?.value(forKey: "minute") ?? 5) as! Int
        if minute < 15 {
            hour -= 1
            minute = (60 - (15 - abs(minute)))
        } else {
            minute -= 15
        }
//        let triggerDate = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date())
        var triggerDate = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date(), matchingPolicy: Calendar.MatchingPolicy.nextTime, repeatedTimePolicy: Calendar.RepeatedTimePolicy.first, direction: Calendar.SearchDirection.forward)
        if triggerDate! < Date() {
            triggerDate! += 86400.0
        }
        print(triggerDate)
        print(Calendar.current.dateComponents(in: TimeZone.current, from: triggerDate!), "bill")
        let components = Calendar.current.dateComponents([.month, .day, .hour, .minute], from: triggerDate!)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let notification = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        print(trigger.nextTriggerDate())
        print(trigger.dateComponents)
        UNUserNotificationCenter.current().add(notification) { (err) in
            if err != nil {
                print(err!)
            } else {
                print(12)
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.badge)
    }
    
    
    
//    lazy var applicationDocumentsDirectory: URL = {
//        // The directory the application uses to store the Core Data store file. This code uses a directory named "io.developersacademy.Journal" in the application's documents Application Support directory.
////        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
////        return urls[urls.count-1]
//        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.addisonhanrattie.SchoolSchedule") ?? nil
//        }()!
//
//    lazy var managedObjectModel: NSManagedObjectModel = {
//        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
//        let modelURL = Bundle.main.url(forResource: "SchoolSchedule", withExtension: "momd")!
//        return NSManagedObjectModel(contentsOf: modelURL)!
//    }()
//
//    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
//        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
//        // Create the coordinator and store
//        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
//        let url = self.applicationDocumentsDirectory.appendingPathComponent("SchoolSchedule.sqlite")
//        var failureReason = "There was an error creating or loading the application's saved data."
//        do {
//            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
//        } catch {
//            // Report any error we got.
//            var dict = [String: AnyObject]()
//            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
//            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
//
//            dict[NSUnderlyingErrorKey] = error as NSError
//            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
//            // Replace this with code to handle the error appropriately.
//            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
//            abort()
//        }
//
//        return coordinator
//    }()
//
//    lazy var managedObjectContext: NSManagedObjectContext = {
//        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
//        let coordinator = self.persistentStoreCoordinator
//        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
//        managedObjectContext.persistentStoreCoordinator = coordinator
//        return managedObjectContext
//    }()
//
//    // MARK: - Core Data Saving support
//
//    func saveContext () {
//        if managedObjectContext.hasChanges {
//            do {
//                try managedObjectContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nserror = error as NSError
//                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
//                abort()
//            }
//        }
//    }
}

