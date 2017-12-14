//
//  DataEngine.swift
//  Beer Me! mobile for iOS
//
//  Created by Richard Stueven on 12/13/17.
//  Copyright © 2017 Richard Stueven. All rights reserved.
//
//  See https://github.com/stephencelis/SQLite.swift/issues/760
//  and https://stackoverflow.com/a/44870302/295028
//

import Foundation
import SQLite

class DataEngine {
    
    @discardableResult
    func start() -> Self {
        do {
            let db = try Connection(DataEngine.getPath(fileName: "beerme.sqlite3"))
            debugPrint("db is writeable: \(!db.readonly)")
            //try  db.execute("SELECT * FROM \"users\"")
        } catch {
            debugPrint(error)
        }
        
        return self
    }
    
    class func copyFileIfNeeded(dbFileName fileName: String) {
        let fileManager = FileManager.default
        
        let dbPath = getPath(fileName: fileName)
        guard !fileManager.fileExists(atPath: dbPath) else {return}
        let path = Bundle.main.path(forResource: "beerme", ofType: "sqlite3")
        do {
            try fileManager.copyItem(atPath: path!, toPath: dbPath)
        } catch let error as NSError {
            print("ERROR in copyFileIfNeeded(\(fileName)): \(error.description)")
        }
    }
    
    class func getPath(fileName: String) -> String {
        let doumentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        return doumentDirectoryPath.appendingPathComponent(fileName)
    }
}
