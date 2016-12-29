//
//  EventEmitterTests.swift
//  Stream
//
//  Created by Christopher Prince on 12/28/16.
//
//

import Foundation
import XCTest
@testable import SwiftyStreams

class EventEmitterTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    enum Event : String {
    case event1
    case event2
    case event3
    }
    
    func testSingleCallbackWhenEmitCalled() {
        var event1Occurred = 0

        let emitter = EventEmitter<Event>()
        emitter.on(e: .event1) { _ in
            event1Occurred += 1
        }
        
        emitter.emit(e: .event1)

        XCTAssert(event1Occurred == 1)
    }
    
    func testMultipleCallbacksForMultipleEventsWhenEmitCalled() {
        var event1Occurred = 0
        var event2Occurred = 0

        let emitter = EventEmitter<Event>()
        emitter.on(e: .event1) {  _ in
            event1Occurred += 1
        }
 
        emitter.on(e: .event2) {  _ in
            event2Occurred += 1
        }
        
        emitter.emit(e: .event1)
        emitter.emit(e: .event2)

        XCTAssert(event1Occurred == 1 && event2Occurred == 1)
    }
    
    func testMultipleCallbacksForSingleEventWhenEmitCalled() {
        var event1aOccurred = 0
        var event1bOccurred = 0

        let emitter = EventEmitter<Event>()
        emitter.on(e: .event1) { _ in
            event1aOccurred += 1
        }
 
        emitter.on(e: .event1) {  _ in
            event1bOccurred += 1
        }
        
        emitter.emit(e: .event1)

        XCTAssert(event1aOccurred == 1 && event1bOccurred == 1)
    }
    
    
    func testThatAnEventEmittedWithNoListenerDoesNotFail() {
        let emitter = EventEmitter<Event>()
        emitter.emit(e: .event1)
    }
    
    func testThatRemovingAListenerWorks() {
        let emitter = EventEmitter<Event>()
        var event1Occurred = 0

        let id = emitter.on(e: .event1) {  _ in
            event1Occurred += 1
        }
        
        emitter.emit(e: .event1)
        XCTAssert(event1Occurred == 1)
        
        event1Occurred = 0
        try! emitter.remove(id: id)
        XCTAssert(event1Occurred == 0)
    }
    
    func testThatRemovingANonPresentListenerThrows() {
        let emitter = EventEmitter<Event>()

        // Forcably create an id
        let id = Id<Int32>(number: 0, owner: emitter.idPool, userData: Event.event1)
        
        do {
            try emitter.remove(id: id)
            XCTFail()
        } catch (let error) {
            print(error)
        }
    }
    
    // TODO: Test usage of parameter passed on some events.
}
