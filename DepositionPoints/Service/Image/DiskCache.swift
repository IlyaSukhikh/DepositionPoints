//
//  DiskCache.swift
//  DepositionPoints
//
//  Created by Ilya Sukhikh on 16/08/2018.
//  Copyright © 2018 Ilya Sukhikh. All rights reserved.
//

import Foundation

final class DiskCache: Cache {
    
    private let fileManager: FileManager
    private let ioQueue = DispatchQueue(label: "com.depositionPoints.cache", qos: .utility)
    
    init(fileManager: FileManager) {
        self.fileManager = fileManager
    }
    
    private var path: String {
        guard let path = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first?.path
            else { fatalError("no cache directory?!") }
        return path
    }
    
    func save(data: Data, forKey key: String, modified: Date) {
        let filepath = (path as NSString).appendingPathComponent(key)
        ioQueue.async {
            let attributes: [FileAttributeKey: Any] = [.modificationDate: modified]
            self.fileManager.createFile(atPath: filepath, contents: data, attributes: attributes)
        }
    }
    
    func fetch(dataForKey key: String, completion: @escaping ((data: Data, modified: Date)?) -> Void) {
        
        let filepath = (path as NSString).appendingPathComponent(key)
        
        ioQueue.async {
            guard self.fileManager.fileExists(atPath: filepath)
                else { completion(nil); return }
            
            guard let data = self.fileManager.contents(atPath: filepath)
                else { completion(nil); return }
            
            guard let date = (try? self.fileManager.attributesOfItem(atPath: filepath)[.modificationDate]) as? Date
                else { completion(nil); return }
            let result = (data, date)
            completion(result)
        }
    }
}
