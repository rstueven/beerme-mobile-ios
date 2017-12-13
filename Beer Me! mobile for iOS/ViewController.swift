//
//  ViewController.swift
//  Beer Me! mobile for iOS
//
//  Created by Richard Stueven on 12/7/17.
//  Copyright © 2017 Richard Stueven. All rights reserved.
//

import UIKit
import SQLite
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var map: MKMapView!
    
    var tables: [String: Table] = ["brewery": Table("brewery"), "beer": Table("beer"), "style": Table("style")]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        guard let db = checkAndInitDatabase() else {
            print("ERROR in viewDidLoad(): failed to initialize db")
            // throw instead of return?
            return
        }
        
        print("DATABASE FILE: \(db.description)")
        DispatchQueue.main.async {
            self.updateDatabase(db: db)
        }
        
        setupMap()
        loadBreweries(db)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // TODO: Refactor database stuff into its own class(es)
    func checkAndInitDatabase() -> Connection? {
        let dbFilename = "beerme.sqlite3"
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            )[0] as String
        let dbURL = URL(fileURLWithPath: path)
        let filePath = dbURL.appendingPathComponent(dbFilename).path
        let fileManager = FileManager.default
        
        if !fileManager.fileExists(atPath: filePath) {
            // Database doesn't exist
            let finalDatabaseURL = dbURL.appendingPathComponent(dbFilename)
            let documentsURL = Bundle.main.resourceURL?.appendingPathComponent(dbFilename)
            
            do {
                try fileManager.copyItem(at: documentsURL!, to: finalDatabaseURL)
            } catch let error as NSError {
                print("ERROR in checkAndInitDatabase(): Can't copy file: \(error.description)")
            }
        }
        
        do {
            return try Connection(dbURL.appendingPathComponent(dbFilename).path, readonly: true)
        } catch let error as NSError {
            print("ERROR in checkAndInitDatabase(): DB connection failed: \(error.description)")
            return nil
        }
    }
    
    func updateDatabase(db: Connection) {
//        for table in tables.keys {
//            updateTable(db, table: table)
//        }
        
        let updated = Expression<String>("updated")
        let tableObj = tables["brewery"]
        do {
            let maxUpdated = try db.scalar(tableObj!.select(updated.max))
            print(maxUpdated!)
            
            if let url = URL(string: "http://beerme.com/mobile/v3/dbUpdate.php?t=\(maxUpdated!)") {
                let request = NSMutableURLRequest(url: url)
                let task = URLSession.shared.dataTask(with: request as URLRequest) {
                    data, response, error in
                    if error != nil {
                        print("ERROR in updateDatabase.dataTask(): \(error!)")
                    } else {
                        if let unwrappedData = data {
                            let dataString = NSString(data: unwrappedData, encoding: String.Encoding.utf8.rawValue)
                            let stringSeparator = "#####"
                            if let contentArray = dataString?.components(separatedBy: stringSeparator) {
                                if contentArray.count >= 1 && contentArray[0].count > 1 {
//                                    print("Brewery")
                                    self.updateBreweryData(db, contentArray[0])
                                }
                                if contentArray.count >= 2 && contentArray[1].count > 1 {
//                                    print("Beer")
                                    self.updateBeerData(db, contentArray[1])
                                }
                                if contentArray.count >= 3 && contentArray[2].count > 1 {
//                                    print("Style")
                                    self.updateStyleData(db, contentArray[2])
                                }
                            }
                        } else {
                            print("ERROR in updateDatabase: unwrappedData failed")
                        }
                    }
                }
                task.resume()
            } else {
                print("ERROR in updateDatabase(): URL failed")
            }
        } catch let error as NSError {
            print("ERROR in updateDatabase() : DB connection failed: \(error.description)")
        }
    }
    
//    func updateTable(_ db: Connection, table: String) {
//        let updated = Expression<String>("updated")
//        let tableObj = tables[table]
//        do {
//            let maxUpdated = try db.scalar(tableObj!.select(updated.max))
//            print("\(table): \(maxUpdated!)")
//            // TODO: Download updates
//        } catch let error as NSError {
//            print("ERROR in updateTable(\(table) : DB connection failed: \(error.description)")
//        }
//    }
    
    func updateBreweryData(_ db:Connection, _ data: String) {
//        print(data)
//        var brewery:Brewery
//
//        let recordStrings = data.components(separatedBy: "\n")
//        for recordString in recordStrings {
//            brewery = Brewery(fromCSV: recordString)
//            print(brewery.description)
//            brewery.save(db)
//        }
    }
    
    func updateBeerData(_ db:Connection, _ data: String) {
//        print(data)
    }
    
    func updateStyleData(_ db:Connection, _ data: String) {
//        print(data)
    }
    
    func setupMap() {
        let latDelta:CLLocationDegrees = 0.05
        let lngDelta:CLLocationDegrees = 0.05
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        
        let lat:CLLocationDegrees = 41.287407
        let lng:CLLocationDegrees = -96.097846
        let location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        
        let region = MKCoordinateRegion(center: location, span: span)
        
        map.setRegion(region, animated: true)
    }
    
    func loadBreweries(_ db:Connection) {
        let farnamHouseID:Int64 = 14599
        let farnamHouse = Brewery(database: db, byID: farnamHouseID)
        print(farnamHouse.description)
        let location = CLLocationCoordinate2D(latitude: farnamHouse.lat, longitude: farnamHouse.lng)
        let annotation = MKPointAnnotation()
        annotation.title = farnamHouse.name
        annotation.subtitle = farnamHouse.address
        annotation.coordinate = location
        map.addAnnotation(annotation)
    }
}
