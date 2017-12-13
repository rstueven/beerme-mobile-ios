//
//  DataEngine.swift
//  Beer Me! mobile for iOS
//
//  Created by Richard Stueven on 12/13/17.
//  Copyright © 2017 Richard Stueven. All rights reserved.
//
//  See https://github.com/stephencelis/SQLite.swift/issues/760
//

import Foundation
import SQLite

class DataEngine {
    
    @discardableResult
    func start() -> Self {
        do {
            //where FireModel.projectRoot = "mysqlitedatabase"
//            let db = try Connection(DataEngine.getPath(fileName: FireModel.projectRoot.appending(".sqlite")))
            let db = try Connection(DataEngine.getPath(fileName: "beerme".appending(".sqlite3")))
            debugPrint("db is writeable: \(!db.readonly)")
            //try  db.execute("SELECT * FROM \"users\"")
        } catch {
            debugPrint(error)
        }
        return self
        
    }
    class func copyFileIfNeeded(dbFileName fileName: String) {
        let destinationPath = getPath(fileName: fileName)
        let fileManager = FileManager.default
        //if active db not found then continue otherwise exit
        guard !fileManager.fileExists(atPath: destinationPath) else { return }
        //form a valid URL to resource or exit
        guard let fromURL = Bundle.main.resourceURL?.appendingPathComponent(fileName) else { return }
        //if reference db exists continue otherwise exit
        guard fileManager.fileExists(atPath: fromURL.path) else { return }
        //try to copy item or exit with error
        do {
            try fileManager.copyItem(atPath: fromURL.path, toPath: destinationPath)
            debugPrint("file copied?: \(fileManager.fileExists(atPath: destinationPath))")
        } catch {
            debugPrint(error)
        }
    }
    
    class func getPath(fileName: String) -> String {
        let documentsPathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsPathURL.appendingPathComponent(fileName).path
    }
}
