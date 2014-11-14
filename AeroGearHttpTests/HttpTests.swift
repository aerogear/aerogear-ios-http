/*
* JBoss, Home of Professional Open Source.
* Copyright Red Hat, Inc., and individual contributors
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/


import XCTest
import AeroGearHttp
import AGURLSessionStubs

class HttpTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        StubsManager.removeAllStubs()
    }
    
    func testGET() {
        // async test expectation
        let getExpectation = expectationWithDescription("'GET' http method test");

        var http = Http(baseURL: "http://httpbin.org")
        
        http.GET("/get",  parameters: ["key": "value"], completionHandler: {(response, error) in
            XCTAssertNil(error, "error should be nil")
            
            var resp = (response as NSDictionary!)["args"] as NSDictionary!
            XCTAssertEqual(resp["key"] as String,  "value", "should be equal")
            
            getExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testPOST() {
        // async test expectation
        let getExpectation = expectationWithDescription("'POST' http method test");
        
        var http = Http(baseURL: "http://httpbin.org")
        
        http.POST("/post",  parameters: ["key": "value"], completionHandler: {(response, error) in
            XCTAssertNil(error, "error should be nil")
            
            var resp = (response as NSDictionary!)["data"] as String!
            XCTAssertEqual("{\"key\":\"value\"}", resp, "should be equal")

            getExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testPUT() {
        // async test expectation
        let getExpectation = expectationWithDescription("'PUT' http method test");
        
        var http = Http(baseURL: "http://httpbin.org")
        
        http.PUT("/put",  parameters: ["key": "value"], completionHandler: {(response, error) in
            XCTAssertNil(error, "error should be nil")
            
            var resp = (response as NSDictionary!)["data"] as String!
            XCTAssertEqual("{\"key\":\"value\"}", resp, "should be equal")

            getExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testDELETE() {
        // async test expectation
        let getExpectation = expectationWithDescription("'DELETE' http method test");
        
        var http = Http(baseURL: "http://httpbin.org")
        
        http.DELETE("/delete",  parameters: ["key": "value"], completionHandler: {(response, error) in
            XCTAssertNil(error, "error should be nil")
            
            var resp = (response as NSDictionary!)["args"] as NSDictionary!
            XCTAssertEqual(resp["key"] as String,  "value", "should be equal")
            
            getExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testMultipart() {
        var data = "Lorem ipsum dolor sit amet".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        
        let file = MultiPartData(data: data, name: "lorem", filename: "lorem.txt", mimeType: "plain/text")
        
        // async test expectation
        let getExpectation = expectationWithDescription("'POST' http method test");
        
        var http = Http(baseURL: "http://httpbin.org")
        
        http.POST("/post",  parameters: ["key": "value", "file": file], completionHandler: {(response, error) in
            XCTAssertNil(error, "error should be nil")
            
            // should contain form data
            var form = (response as NSDictionary!)["form"] as NSDictionary!
            XCTAssertEqual(form["key"] as String,  "value", "should be equal")

            // should contain file data
            var files = (response as NSDictionary!)["files"] as NSDictionary!
            XCTAssertNotNil(files["file"], "should contain file")
            
            getExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(10, handler: nil)
    }

    func testDownloadWithDefaultDestinationDirectory() {
        // async test expectation
        let getExpectation = expectationWithDescription("Download");

        var http = Http()
        
        var FILENAME = "aerogear_icon_64px.png"
        var fileManager = NSFileManager.defaultManager()
        
        var path  = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        fileManager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil, error: nil)
        
        var finalDestination = path.stringByAppendingPathComponent(FILENAME)

        http.download("http://design.jboss.org/aerogear/logo/final/\(FILENAME)",
            progress: { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite)  in
                println("bytesWritten: \(bytesWritten), totalBytesWritten: \(totalBytesWritten), totalBytesExpectedToWrite: \(totalBytesExpectedToWrite)")
            }, completionHandler: { (response, error) in
                XCTAssertNil(error, "error should be nil")
                
               // assert file exists
                XCTAssertTrue(NSFileManager.defaultManager().fileExistsAtPath(finalDestination), "should have been downloaded")
                
                // remove file
                fileManager.removeItemAtPath(finalDestination, error:nil)
                
                getExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(600, handler: nil)
    }
    
    func testDownloadWithUserProvidedDestinationDirectory() {
        // async test expectation
        let getExpectation = expectationWithDescription("Download");
        
        var http = Http()

        var fileManager = NSFileManager.defaultManager()
        // create destination directory
        var path  = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        var tempDir = path.stringByAppendingPathComponent("Temporary")
        fileManager.createDirectoryAtPath(tempDir, withIntermediateDirectories: true, attributes: nil, error: nil)

        var FILENAME = "aerogear_icon_64px.png"
        http.download("http://design.jboss.org/aerogear/logo/final/\(FILENAME)",
            destinationDirectory: tempDir,
            progress: { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite)  in
                println("bytesWritten: \(bytesWritten), totalBytesWritten: \(totalBytesWritten), totalBytesExpectedToWrite: \(totalBytesExpectedToWrite)")
            }, completionHandler: { (response, error) in
                XCTAssertNil(error, "error should be nil")

                var finalDestination = tempDir.stringByAppendingPathComponent(FILENAME)
                XCTAssertTrue(NSFileManager.defaultManager().fileExistsAtPath(finalDestination), "should have been downloaded")
                
                // delete test directory (recursive
                fileManager.removeItemAtPath(tempDir, error:nil)
                getExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(600, handler: nil)
    }
    
    func testUpload() {
        // async test expectation
        let getExpectation = expectationWithDescription("Download");
        
        var http = Http(baseURL: "http://httpbin.org")
        http.upload("/post",  data: "contents of a file".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!,
            progress: { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite)  in
                println("bytesWritten: \(bytesWritten), totalBytesWritten: \(totalBytesWritten), totalBytesExpectedToWrite: \(totalBytesExpectedToWrite)")
            }, completionHandler: { (response, error) in
                XCTAssertNil(error, "error should be nil")
                getExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(600, handler: nil)
    }
}
