//
//  WeeklyViewController.swift
//  SchoolSchedule
//
//  Created by Addison Hanrattie on 2/1/18.
//  Copyright © 2018 Addison Hanrattie. All rights reserved.
//

import UIKit
import CoreData

class WeeklyViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    //NOTE: - Get rid of the status bar on this view
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 50
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row + 1)"
    }

    var context: NSManagedObjectContext!
    var results: [NSManagedObject] = []
    @IBOutlet weak var DatePicker: UIDatePicker!
    @IBOutlet weak var DayPicker: UIPickerView!
    @IBAction func AddButton(_ sender: Any) {
        let entity = NSEntityDescription.entity(forEntityName: "ClassResources", in: context)
        let object = NSManagedObject(entity: entity!, insertInto: context)
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "ClassResources")
        do {
            let cResults = try context.count(for: fetch) + 1
            object.setValue(cResults, forKey: "classnumber")
            print(cResults)
            //NOTE: - we must search for through deleted classes for renumbering
            try context.save()
        } catch {
            print(error)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func SetDaysButton(_ sender: Any) {
        do {
            results.first?.setValue((DayPicker.selectedRow(inComponent: 0) + 1), forKey: "days")
            print(DayPicker.selectedRow(inComponent: 0))
            print(try context.save())
        } catch {
            print(error)
        }
        print(context.hasChanges)
    }
    @IBAction func SetDateButton(_ sender: Any) {
        do {
            results.first?.setValue(DatePicker.date, forKey: "baseline")
            try context.save()
        } catch {
            print(error)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        context = CoreDataStack.managedObjectContext
        DayPicker.dataSource = self
        DayPicker.delegate = self
        DatePicker.timeZone = TimeZone.autoupdatingCurrent
        DatePicker.calendar = Calendar(identifier: .gregorian)
        DatePicker.maximumDate = Date()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DayBaseline")
        do {
            results = try context.fetch(fetchRequest)
        } catch {
            print(error)
        }
        if results != [] {
            let dat = results.first?.value(forKey: "baseline") as! Date
            DatePicker.setDate(dat, animated: true)
            let rw = results.first?.value(forKey: "days") as! Int
            DayPicker.selectRow(rw - 1, inComponent: 0, animated: true)
        } else {
            DatePicker.date = Date()
            let entity = NSEntityDescription.entity(forEntityName: "DayBaseline", in: context)
            let object = NSManagedObject(entity: entity!, insertInto: context)
            object.setValue(1, forKey: "days")
            object.setValue(Date(), forKey: "baseline")
            do {
                try context.save()
            } catch {
                print(error)
            }
        }
        self.setNeedsStatusBarAppearanceUpdate()
        print(self.prefersStatusBarHidden)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
