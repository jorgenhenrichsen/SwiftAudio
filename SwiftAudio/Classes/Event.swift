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
        
        private let eventQueue: DispatchQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.utility)
        private let actionQueue: DispatchQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated)
        private var invokers: [Invoker<EventData>] = []
        private let invokersSemaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
        
        public func addListener<Listener: AnyObject>(_ listener: Listener, _ handler: @escaping EventHandler<Listener, EventData>) {
            actionQueue.async {
                self.invokersSemaphore.wait()
                self.invokers.append(Invoker(listener: listener, handler: handler))
                self.invokersSemaphore.signal()
            }
        }
        
        public func removeListener(_ listener: AnyObject) {
            actionQueue.async {
                self.invokersSemaphore.wait()
                self.invokers = self.invokers.filter({ (invoker) -> Bool in
                    if let listenerToCheck = invoker.listener {
                        return listenerToCheck !== listener
                    }
                    return true
                })
                self.invokersSemaphore.signal()
            }
        }
        
        func emit(data: EventData) {
            eventQueue.async {
                self.invokersSemaphore.wait()
                self.invokers = self.invokers.filter({ (invoker) -> Bool in
                    return invoker.invoke(data)
                })
                self.invokersSemaphore.signal()
            }
        }
    }
    
}
