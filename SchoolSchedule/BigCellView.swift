//
//  BigCellView.swift
//  SchoolSchedule
//
//  Created by Addison Hanrattie on 3/4/18.
//  Copyright © 2018 Addison Hanrattie. All rights reserved.
//

import UIKit
import CoreData

class BigCellView: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var classPicker: UIPickerView!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBAction func setButton(_ sender: Any) {
        do {
            object!.setValue(classPicker.selectedRow(inComponent: 0) + 1, forKey: "classnumber")
            print(classPicker.selectedRow(inComponent: 0))
            let cal = Calendar.current
            let h = cal.component(.hour, from: timePicker.date)
            let m = cal.component(.minute, from: timePicker.date)
            object!.setValue(h, forKey: "hour")
            object!.setValue(m, forKey: "minute")
            do {
                try context.save()
            } catch {
                print(error)
            }
            let tb = self.superview as! UITableView
            tb.reloadData()
        }
    }
    @IBAction func duplicateButton(_ sender: Any) {
        do {
            let entity = NSEntityDescription.entity(forEntityName: "ClassData", in: context)
            let dObject = NSManagedObject(entity: entity!, insertInto: context)
            dObject.setValue((object?.value(forKey: "day") ?? 0), forKey: "day")
            dObject.setValue(object?.value(forKey: "minute"), forKey: "minute")
            dObject.setValue((object?.value(forKey: "hour") ?? 0), forKey: "hour")
            dObject.setValue(object?.value(forKey: "classnumber"), forKey: "classnumber")
            try context.save()
            let tb = self.superview as! UITableView
            tb.reloadData()
        } catch {
            print(error)
        }
    }
    var object: NSManagedObject? = nil
    var context: NSManagedObjectContext!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        context = CoreDataStack.managedObjectContext
        print("joes")
        classPicker.dataSource = self
        classPicker.delegate = self
        classPicker.reloadAllComponents()
        let h = (object?.value(forKey: "hour") ?? 12) as! Int
        let m = (object?.value(forKey: "minute") ?? 0) as! Int
        let dat = Calendar.current.date(bySettingHour: h, minute: m, second: 0, of: Date())
        timePicker.setDate(dat!, animated: true)
        let r = (object?.value(forKey: "classnumber") ?? 0) as! Int
        classPicker.selectRow(r - 1, inComponent: 0, animated: true)
//        let v = object?.value(forKey: "classnumber") ?? 0
//        classPicker.selectRow(v as! Int, inComponent: 1, animated: true)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        awakeFromNib()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "ClassResources")
        do {
            let vals = try context.fetch(fetch)
            let val = vals[row]
            return val.value(forKey: "classname") as! String?
        } catch {
            print(error)
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "ClassResources")
        do {
            print("rean")
            return try context.count(for: fetch)
        } catch {
            print(error)
        }
        return 0
    }

}
