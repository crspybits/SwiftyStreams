//
//  ReadableStream.swift
//  SwiftyStream
//
//  Created by Christopher Prince on 12/28/16.
//
//

// Patterned after https://nodejs.org/api/stream.html#stream_readable_pipe_destination_options

import Foundation

enum ReadableStreamEvent : String {
    case readable
    case data
}

// Abstract class.

class ReadableStream : EventEmitter<ReadableStreamEvent> {
    
    /* ReadableStream's can be in one of two modes:
        a) paused: You must call the read() method yourself.
        b) flowing: the read() method is called is called automatically until the internal buffer is fully drained.
    */

    func pipe(destination:WritableStream) -> ReadableStream? {
        return nil
    }
    
    // Up to size bytes are read from the stream if in paused mode.
    func readBytes(size:UInt32) throws -> [UInt8]? {
        return nil
    }
}
