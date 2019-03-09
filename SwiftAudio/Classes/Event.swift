//
//  Event.swift
//  SwiftAudio
//
//  Created by Jørgen Henrichsen on 09/03/2019.
//

import Foundation

extension AudioPlayer {
    
    public typealias EventHandler<Listener, EventData> = (Listener) -> (EventData) -> Void
    
    private class Invoker<EventData> {
        
        // Signals false if the listener object is nil
        let invoke: (EventData) -> Bool
        weak var listener: AnyObject?
        
        init<Listener: AnyObject>(listener: Listener, handler: @escaping EventHandler<Listener, EventData>) {
            self.listener = listener
            self.invoke = { [weak listener] (data: EventData) in
                guard let listener = listener else {
                    return false
                }
                handler(listener)(data)
                return true
            }
        }
    }
    
    public class Event<EventData> {
        
        private var invokers: [Invoker<EventData>] = []
        
        public func addListener<Listener: AnyObject>(_ listener: Listener, _ handler: @escaping EventHandler<Listener, EventData>) {
            invokers.append(Invoker(listener: listener, handler: handler))
        }
        
        public func removeListener(_ listener: AnyObject) {
            invokers = invokers.filter({ (invoker) -> Bool in
                if let listenerToCheck = invoker.listener {
                    return listenerToCheck !== listener
                }
                return true
            })
        }
        
        func emit(data: EventData) {
            invokers = invokers.filter({ (invoker) -> Bool in
                return invoker.invoke(data)
            })
        }
        
    }
    
}
