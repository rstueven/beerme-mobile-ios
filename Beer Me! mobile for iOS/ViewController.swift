//
//  ViewController.swift
//  Beer Me! mobile for iOS
//
//  Created by Richard Stueven on 12/7/17.
//  Copyright © 2017 Richard Stueven. All rights reserved.
//

import UIKit
import SQLite

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let db = checkAndInitDatabase() {
            print("INFO: db initialized")
            print("DESC: \(db.description)")
            let breweries = Table("brewery")
            let breweryId = Expression<Int64>("_id")
            let breweryName = Expression<String>("name")
            do {
                for brewery in try db.prepare(breweries) {
                    print("\(brewery[breweryId]) \(brewery[breweryName])")
                }
            } catch let error as NSError {
                print("ERROR: \(error.description)")
            }
        } else {
            print("ERROR: failed to initialize db")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkAndInitDatabase() -> Connection? {
        let fileManager = FileManager.default
        let dbFilename = "beerme.sqlite3"
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)

        guard documentsURL.count != 0 else {
            // TODO: Actual error handling
            print("ERROR: Could not find documents URL")
            return nil
        }

        let dbURL = documentsURL.first!.appendingPathComponent(dbFilename)

        if !((try? dbURL.checkResourceIsReachable()) ?? false) {
            print("INFO: Database does not exist in documents folder")
            let bundleURL = Bundle.main.resourceURL?.appendingPathComponent(dbFilename)
            print("atPath: \(bundleURL?.path ?? "N/A")")
            print("toPath: \(dbURL.path)")
            do {
                try fileManager.copyItem(atPath: (bundleURL?.path)!, toPath: dbURL.path)
            } catch let error as NSError {
                print("ERROR: Can't copy file: \(error.description)")
            }
        } else {
            print("INFO: Database exists in documents folder")
        }

        do {
            return try Connection(dbURL.path, readonly: true)
        } catch let error as NSError {
            print("ERROR: DB connection failed: \(error.description)")
            return nil
        }
    }
}
