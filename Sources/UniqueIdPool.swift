//
//  UniqueIdPool.swift
//  SwiftyStream
//
//  Created by Christopher Prince on 12/28/16.
//
//

import Foundation

public class Id<IntType: Integer> {
    public let number:IntType
    public var userData:Any?
    weak var owner:UniqueIdPool<IntType>?
    
    init(number:IntType, owner:UniqueIdPool<IntType>, userData:Any? = nil) {
        self.number = number
        self.owner = owner
        self.userData = userData
    }
    
    deinit {
        try? self.owner?.put(noLongerNeeded: self)
    }
}

fileprivate enum UniqueIdPoolErrors : Error {
    case inUsePoolDidNotContainId(id:String)
    case recyclePoolContainedId(id:String)
    case badPoolId
}

class UniqueIdPool<IntType: Integer> {
    private var recycle = Set<IntType>()
    private var nextNew:IntType = 0
    private var inUse = Set<IntType>()

    // Not private, for testing
    let selfId = UUID()

    // Use up a unique Id from the pool
    func get() -> Id<IntType> {
        var numberToUse:IntType?

        for num in recycle {
            numberToUse = num
            break
        }
        
        if numberToUse == nil {
            numberToUse = nextNew
            nextNew = nextNew + 1
        }
        else {
            recycle.remove(numberToUse!)
        }
        
        inUse.insert(numberToUse!)
        
        return Id<IntType>(number: numberToUse!, owner: self)
    }
    
    func put(noLongerNeeded id:Id<IntType>) throws {
        if id.owner == nil || self.selfId != id.owner!.selfId {
            throw UniqueIdPoolErrors.badPoolId
        }
        
        if recycle.contains(id.number) {
            throw UniqueIdPoolErrors.recyclePoolContainedId(id: "\(id.number)")
        }
        
        if !inUse.contains(id.number) {
            throw UniqueIdPoolErrors.inUsePoolDidNotContainId(id: "\(id.number)")
        }
        
        recycle.insert(id.number)
        inUse.remove(id.number)
        id.owner = nil
    }
}
