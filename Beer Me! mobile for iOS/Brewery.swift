//
//  Brewery.swift
//  Beer Me! mobile for iOS
//
//  Created by Richard Stueven on 12/12/17.
//  Copyright © 2017 Richard Stueven. All rights reserved.
//

import Foundation
import SQLite

class Brewery {
    let table = Table("brewery")
    let idField = Expression<Int64>("_id")
    let nameField = Expression<String>("name")
    let addressField = Expression<String>("address")
    let latField = Expression<Double>("latitude")
    let lngField = Expression<Double>("longitude")
    let statusField = Expression<Int64>("status")
    let hoursField = Expression<String?>("hours")
    let phoneField = Expression<String?>("phone")
    let webField = Expression<String?>("web")
    let servicesField = Expression<Int64>("services")
    let imageField = Expression<String?>("image")
    let updatedField = Expression<String>("updated")
    
    var id:Int64! = 0
    var name:String! = ""
    var address:String! = ""
    var lat:Double! = 0
    var lng:Double! = 0
    var status:Int64! = 0
    var hours:String? = ""
    var phone:String? = ""
    var web:String? = ""
    var services:Int64! = 0
    var image:String? = ""
    var updated:String! = ""

    func initFromCSV(_ csv:String) {
        print(csv)
        let record = csv.components(separatedBy: "|")
        if record.count == 12 {
            id = Int64(record[0])
            name = record[1]
            address = record[2]
            lat = Double(record[3])
            lng = Double(record[4])
            status = Int64(record[5])
            hours = record[6]
            phone = record[7]
            web = record[8]
            services = Int64(record[9])
            image = record[10]
            updated = record[11]
        } else {
            print("WARNING in Brewery.initFromCSV(\(csv)): Field count \(record.count)")
        }
    }
    
    func save(_ db:Connection) {
        if id <= 0 {
            print("WARNING in save(): Invalid ID <\(id!)>")
        } else {
//            let query = table.filter(idField == id).limit(1)
            do {
//                var found:Int64 = 0
//                for tempRow in try db.prepare(query) {
//                    found = tempRow[idField]
//                }
//
//                if found > 0 {
//                    print("UPDATE \(found)")
//                } else {
//                    print("INSERT \(id)")
//                }
                try db.run(table.insert(or: .replace,
                                        idField <- id,
                                        nameField <- name,
                                        addressField <- address,
                                        latField <- lat,
                                        lngField <- lng,
                                        statusField <- status,
                                        hoursField <- hours,
                                        phoneField <- phone,
                                        webField <- web,
                                        servicesField <- services,
                                        imageField <- image,
                                        updatedField <- updated
                ))
            } catch let Result.error(message, code, statement) {
                print("ERROR in Brewery.save(): \(message) (\(code)) in \(statement)")
            } catch let error {
                print("ERROR in Brewery.save(): \(error)")
            }
        }
    }
    
    var description:String {
        get {
            return "Brewery \(id!)\n\tname: \(name!)\n\taddress: \(address!)\n\tlat,lng: \(lat!),\(lng!)\n\tstatus: \(status!)\n\thours: \(hours ?? "")\n\tphone: \(phone ?? "")\n\tweb: \(web ?? "")\n\tservices: \(services!)\n\timage: \(image ?? "")\n\tupdated: \(updated!)"
        }
    }
}
