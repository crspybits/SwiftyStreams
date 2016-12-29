//
//  FileReadableStream.swift
//  SwiftyStream
//
//  Created by Christopher Prince on 12/28/16.
//
//

import Foundation

// Mostly just a test case for Readable streams. For now.

class FileReadableStream : ReadableStream {
    let fd:Int32
    
    init?(localFile: URL) {
        fd = open(localFile.path, O_RDONLY);
        
        if fd < 0 {
            return nil
        }
        
        super.init()
    }
    
    deinit {
        close(fd)
    }
    
    enum FileReadableStreamError : Error {
    case failedOnRead
    }
    
    // Some help from: http://stackoverflow.com/questions/38983277/how-to-get-bytes-out-of-an-unsafemutablerawpointer
    // and https://gist.github.com/kirsteins/6d6e96380db677169831
    override func readBytes(size:UInt32) throws -> [UInt8]? {
        guard let unsafeMutableRawPointer = malloc(Int(size)) else {
            return nil
        }
        
        let numberBytesRead = read(fd, unsafeMutableRawPointer, Int(size))

        if numberBytesRead < 0 {
            free(unsafeMutableRawPointer)
            throw FileReadableStreamError.failedOnRead
        }
        
        if numberBytesRead == 0 {
            free(unsafeMutableRawPointer)
            return nil
        }

        let unsafeBufferPointer = UnsafeBufferPointer(start: unsafeMutableRawPointer.assumingMemoryBound(to: UInt8.self), count: numberBytesRead)

        let results = Array<UInt8>(unsafeBufferPointer)
        free(unsafeMutableRawPointer)
        
        emit(e: .data, eventData: results)

        return results
    }
}
