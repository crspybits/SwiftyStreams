//
//  EventEmitter.swift
//  Stream
//
//  Created by Christopher Prince on 12/28/16.
//
//

import Foundation

// Patterned after https://nodejs.org/api/events.html#events_class_eventemitter

// For the rationale for the class declaration, see http://stackoverflow.com/questions/24031646/how-in-swift-specify-type-constraint-to-be-enum

fileprivate enum EventEmitterErrors : Error {
    case couldNotFindListenerToRemove
    case badIdPool
    case badEventInUserData
}

open class EventEmitter<Event: RawRepresentable> where Event: Hashable {
    public typealias Callback = (Any?)->()
    public typealias ListenerId = Int32
    
    private typealias EventDatum = (callback:Callback, id:ListenerId)
    private var callbacks = [Event:[EventDatum]]()
    
    // Internal rather than private, for testing purposes.
    var idPool = UniqueIdPool<ListenerId>()
    
    public init() {
    }
    
    // Register an event listener
    @discardableResult
    open func on(e: Event, callback:@escaping Callback) -> Id<ListenerId> {
        if callbacks[e] == nil {
            callbacks[e] = [EventDatum]()
        }
        
        let id = idPool.get()
        id.userData = e
        let datum = (callback: callback, id: id.number)
        callbacks[e]!.append(datum)
        
        return id
    }
    
    // Synchronously calls each of the listeners registered for the given event, in the order they were registered.
    open func emit(e:Event, eventData:Any? = nil) {
        if callbacks[e] != nil {
            for (callback: callback, id: _) in callbacks[e]! {
                callback(eventData)
            }
        }
    }
    
    // Deregister a listener.
    open func remove(id: Id<ListenerId>) throws {
        if id.owner == nil || id.owner!.selfId != idPool.selfId {
            throw EventEmitterErrors.badIdPool
        }
        
        guard let e = id.userData as? Event else {
            throw EventEmitterErrors.badEventInUserData
        }

        if let callbacksForEvent = callbacks[e] {
            var found = false
            var index = 0
            for (callback: _, id: idNumber) in callbacksForEvent {
                if idNumber == id.number {
                    found = true
                    break
                }
                index += 1
            }
            
            if found {
                callbacks[e]!.remove(at: index)
                return
            }
        }
        
        throw EventEmitterErrors.couldNotFindListenerToRemove
    }
}
