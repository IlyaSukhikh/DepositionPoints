//
//  Debouncer.swift
//  DepositionPoints
//
//  Created by Ilya Sukhikh on 19/08/2018.
//  Copyright © 2018 Ilya Sukhikh. All rights reserved.
//

import Foundation

public final class Debouncer {
    
    let limit: TimeInterval
    let queue: DispatchQueue

    private var item: DispatchWorkItem?
    
    public init(limit: TimeInterval, queue: DispatchQueue) {
        self.limit = limit
        self.queue = queue
    }
    
    public func invalidate() {
        item?.cancel()
    }
    
    public func execute(action: @escaping () -> Void) {
        item?.cancel()
        let newItem = DispatchWorkItem {
            action()
        }
        item = newItem
        queue.asyncAfter(deadline: .now() + limit, execute: newItem)
    }
}
