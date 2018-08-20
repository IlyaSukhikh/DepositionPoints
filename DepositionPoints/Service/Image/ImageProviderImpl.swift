//
//  ImageProviderImpl.swift
//  DepositionPoints
//
//  Created by Ilya Sukhikh on 16/08/2018.
//  Copyright © 2018 Ilya Sukhikh. All rights reserved.
//

import UIKit

final class ImageProviderImpl: ImageProvider {
    
    private let session: URLSession
    private let cache: Cache
    private var memoryCache: [String: Observable<UIImage?>] = [:]
    private var tasks: [String: URLSessionDownloadTask] = [:]
    private var checked: Set<String> = []

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "EEE, dd LLL yyyy HH:mm:ss zzz"
        return formatter
    }()
    
    init(session: URLSession, cache: Cache) {
        self.session = session
        self.cache = cache
    }
    
    func fetchImage(_ name: String, dpi: UIScreen.DPI, targetSize: CGSize) -> Observable<UIImage?> {
        
        let observable = self.observable(for: name)
        
        guard !checked.contains(name)
            else { return observable }
        
        cache.fetch(dataForKey: name) { [weak self] cachedData in
            if let cachedData = cachedData, let image = UIImage(data: cachedData.data)?.scaled() {
                DispatchQueue.main.async { observable.value = image }
            }
            self?.downloadImageIfNeeded(name,
                                        dpi: dpi,
                                        modifiedDate: cachedData?.modified,
                                        targetSize: targetSize)
        }
        
        return observable
    }
    
    private func downloadImageIfNeeded(_ name: String,
                                       dpi: UIScreen.DPI,
                                       modifiedDate: Date?,
                                       targetSize: CGSize) {
        
        guard tasks[name] == nil
            else { return }
        
        guard var request = URLRequest(endpoint: .image(name: name, dpi: dpi), method: .get)
            else { return }
        
        if let date = modifiedDate {
            let dateString = dateFormatter.string(from: date)
            request.addValue(dateString, forHTTPHeaderField: "If-Modified-Since")
        }
        
        let task = session.downloadTask(with: request) { [weak self] url, response, error in
            
            guard let strongSelf = self
                else { return }
            
            defer {
                DispatchQueue.main.async { strongSelf.tasks[name] = nil }
            }
            
            guard error == nil else {
                print("Fail to download image \(name): \(error?.localizedDescription ?? "")")
                return
            }
            
            let date: Date = {
                guard let httpResponse = response as? HTTPURLResponse,
                      let dateString = httpResponse.allHeaderFields["Last-Modified"] as? String,
                      let date = strongSelf.dateFormatter.date(from: dateString)
                    else { return Date() }
                return date
            }()
            
            guard let url = url,
                let data = try? Data(contentsOf: url)
                else { return }
            guard data.count != 0 else {
                DispatchQueue.main.async { strongSelf.checked.insert(name) }
                return
            }
            
            guard let image = UIImage(data: data)?.circled(targetSize: targetSize) else {
                print("fail to init image named: \(name)")
                return
            }
            DispatchQueue.main.async {
                strongSelf.checked.insert(name)
                strongSelf.cache.save(data: UIImagePNGRepresentation(image)!, forKey: name, modified: date)
                strongSelf.memoryCache[name]?.value = image
            }
        }
        tasks[name] = task
        task.resume()
    }
    
    private func observable(for name: String) -> Observable<UIImage?> {
        if let observable = self.memoryCache[name] {
            return observable
        }
        let observable: Observable<UIImage?> = Observable(nil)
        self.memoryCache[name] = observable
        return observable
    }
}
