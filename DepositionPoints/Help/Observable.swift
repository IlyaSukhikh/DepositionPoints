//
//  Observable.swift
//  DepositionPoints
//
//  Created by Ilya Sukhikh on 18/08/2018.
//  Copyright © 2018 Ilya Sukhikh. All rights reserved.
//

import Foundation

final class Observable<T> {
    
    final class Token {
        
        private let disposeAction: () -> Void
        
        fileprivate init(_ disposeAction: @escaping () -> Void) {
            self.disposeAction = disposeAction
        }
        
        func dispose() {
            disposeAction()
        }
        
        deinit {
            disposeAction()
        }
    }
    
    typealias ObserveAction = (_ oldValue: T, _ newValue: T) -> Void

    private var observers = [UUID: ObserveAction]()
    
    var value: T {
        didSet {
            observers.values.forEach { (action) in
                action(oldValue, value)
            }
        }
    }
    
    func observe(_ observeAction: @escaping ObserveAction) -> Observable.Token {
        let uuid = UUID()
        observers[uuid] = observeAction
        let token = Token { [weak self] in
            self?.observers[uuid] = nil
        }
        return token
    }
    
    init(_ value: T) {
        self.value = value
    }
}
