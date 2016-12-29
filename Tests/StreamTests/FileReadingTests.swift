import XCTest
@testable import SwiftyStreams

class FileReadingTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testReadingFromFile() {
        // TODO: Use FileManager to write some data into the file.
        
        let url = URL(string: "/Users/chris/Desktop/tmp.txt")!
        if let fileStream = FileReadableStream(localFile: url) {
            let result = try! fileStream.readBytes(size: 1)
            let length = result?.count
            print(length)
        }
    }
    
    func testDataEventWhileReadingFromFile() {
    }
}
