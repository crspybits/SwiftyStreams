//
//  UniqueIdPoolTests.swift
//  SwiftyStream
//
//  Created by Christopher Prince on 12/28/16.
//
//

import XCTest
@testable import SwiftyStreams

class UniqueIdPoolTests: XCTestCase {
    var idPool:UniqueIdPool<Int32>!

    override func setUp() {
        super.setUp()
        idPool = UniqueIdPool<Int32>()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testThatSuccessiveIdsHaveDifferentNumbers() {
        let id1 = idPool.get()
        let id2 = idPool.get()
        XCTAssert(id1.number != id2.number)
    }
    
    func testThatReturningAnIdSucceeds() {
        let id1 = idPool.get()
        try! idPool.put(noLongerNeeded: id1)
        let id2 = idPool.get()
        XCTAssert(id1.number == id2.number)
    }
    
    func testThatSettingAnIdToNilReturnsTheId() {
        var id1:Id<Int32>? = idPool.get()
        let id1Number = id1!.number
        id1 = nil
        let id2 = idPool.get()
        XCTAssert(id1Number == id2.number)
    }
    
    func testThatCallingPutWithANonUsedIdThrows() {
        // Forcably create an id for a number never obtained by `get`
        let id = Id<Int32>(number: 0, owner: idPool)
        do {
            try idPool.put(noLongerNeeded: id)
            XCTFail()
        } catch (let error) {
            print(error)
        }
    }
    
    func testThatCallingPutWithAPreviouslyUsedIdThrows() {
        let id1 = idPool.get()
        let id1Number = id1.number
        try! idPool.put(noLongerNeeded: id1)
        
        // Forcably create an id for a number previously obtained by `get`
        let id2 = Id<Int32>(number: id1Number, owner: idPool)
        do {
            try idPool.put(noLongerNeeded: id2)
            XCTFail()
        } catch (let error) {
            print(error)
        }
    }
}
