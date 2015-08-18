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
import OHHTTPStubs

class HttpTests: XCTestCase {

    func httpStubResponseWithInputParams(request: NSURLRequest!, status: Int, params:[String: AnyObject]?) throws -> OHHTTPStubsResponse {
        var data: NSData
        if ((params) != nil) {
            try data = NSJSONSerialization.dataWithJSONObject(params!, options:  NSJSONWritingOptions(rawValue: 0))
        } else {
            data = NSData()
        }
        return OHHTTPStubsResponse(data: data, statusCode: CInt(status), headers: ["Content-Type":"application/json"])
    }
    
    func httpSuccessWithResponse(request: NSURLRequest!) -> OHHTTPStubsResponse {
        return try! httpStubResponseWithInputParams(request, status: 200, params: ["key" : "value"])
    }
    
    func httpMultipartUploadSuccessWithResponse(request: NSURLRequest!) -> OHHTTPStubsResponse {
        return try! httpStubResponseWithInputParams(request, status: 200, params: ["files" : ["file" : "Lorem ipsum dolor sit amet"], "form" : ["key" : "value"] ])
    }
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        OHHTTPStubs.removeAllStubs()
    }

    func testSucessfulGET() {
        // set up http stub
        OHHTTPStubs.stubRequestsPassingTest({ (request: NSURLRequest!) -> ObjCBool in
            return true
            }, withStubResponse: httpSuccessWithResponse)
        let http = Http(baseURL: "http://whatever.com")
        // async test expectation
        let getExpectation = expectationWithDescription("GET http method test");
        http.GET("/get", completionHandler: {(response, error) in
                XCTAssertNil(error, "error should be nil")
                XCTAssertTrue(response!["key"] == "value")
                getExpectation.fulfill()
        })
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testSucessfulPOST() {
        // set up http stub
        OHHTTPStubs.stubRequestsPassingTest({ (request: NSURLRequest!) -> ObjCBool in
            return true
            }, withStubResponse: httpSuccessWithResponse)
        let http = Http(baseURL: "http://whatever.com")
        // async test expectation
        let getExpectation = expectationWithDescription("POST http method test");
        http.POST("/post", completionHandler: {(response, error) in
            XCTAssertNil(error, "error should be nil")
            XCTAssertTrue(response!["key"] == "value")
            getExpectation.fulfill()
        })
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testSucessfulPUT() {
        // set up http stub
        OHHTTPStubs.stubRequestsPassingTest({ (request: NSURLRequest!) -> ObjCBool in
            return true
            }, withStubResponse: httpSuccessWithResponse)
        let http = Http(baseURL: "http://whatever.com")
        // async test expectation
        let getExpectation = expectationWithDescription("PUT http method test");
        http.PUT("/put",  completionHandler: {(response, error) in
            XCTAssertNil(error, "error should be nil")
            XCTAssertTrue(response!["key"] == "value")
            getExpectation.fulfill()
        })
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testDELETE() {
        // set up http stub
        OHHTTPStubs.stubRequestsPassingTest({ (request: NSURLRequest!) -> ObjCBool in
            return true
            }, withStubResponse: httpSuccessWithResponse)
        let http = Http(baseURL: "http://whatever.com")
        // async test expectation
        let getExpectation = expectationWithDescription("DELETE http method test");
        http.DELETE("/delete", completionHandler: {(response, error) in
            XCTAssertNil(error, "error should be nil")
            XCTAssertTrue(response!["key"] == "value")
            getExpectation.fulfill()
        })
        waitForExpectationsWithTimeout(10, handler: nil)
    }

    func testSucessfulMultipartUploadWithPOST() {
        // set up http stub
        OHHTTPStubs.stubRequestsPassingTest({ (request: NSURLRequest!) -> ObjCBool in
            return true
            }, withStubResponse: httpMultipartUploadSuccessWithResponse)
        let http = Http(baseURL: "http://whatever.com")
        let data = "Lorem ipsum dolor sit amet".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let file = MultiPartData(data: data, name: "lorem", filename: "lorem.txt", mimeType: "plain/text")
        // async test expectation
        let getExpectation = expectationWithDescription("POST http method test");
        http.POST("/post",  parameters: ["key": "value", "file": file], completionHandler: {(response, error) in
            XCTAssertNil(error, "error should be nil")
            // should contain form data
            let form = (response as! NSDictionary!)["form"] as! NSDictionary!
            XCTAssertEqual(form["key"] as? String,  "value", "should be equal")
            // should contain file data
            let files = (response as! NSDictionary!)["files"] as! NSDictionary!
            XCTAssertNotNil(files["file"], "should contain file")
            getExpectation.fulfill()
        })
        waitForExpectationsWithTimeout(10, handler: nil)
    }

    func testSucessfulDownloadWithDefaultDestinationDirectory() {
        // set up http stub
        OHHTTPStubs.stubRequestsPassingTest({ (request: NSURLRequest!) -> ObjCBool in
            return true
            }, withStubResponse: httpSuccessWithResponse)
        let http = Http(baseURL: "http://whatever.com")
        // async test expectation
        let getExpectation = expectationWithDescription("Download");
        let fileManager = NSFileManager.defaultManager()
        let path  = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        do {
            try fileManager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
        } catch _ {
        }
        http.download("something",
            progress: { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite)  in
            }, completionHandler: { (response, error) in
                XCTAssertNil(error, "error should be nil")
                let result = response as! NSHTTPURLResponse
                XCTAssertTrue(result.statusCode == 200)
                getExpectation.fulfill()
        })
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testUploadWithMultipart() {
        // async test expectation
        let getExpectation = expectationWithDescription("Upload multipart");
        
        let http = Http(baseURL: "http://httpbin.org")
        let multiPartData = MultiPartData(data: "contents of a file".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "name", filename: "filename.jpg", mimeType: "image/jpg")
        let parameters = ["file": multiPartData]
        
        http.upload("/post", stream: NSInputStream(data: "contents of a file".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!), parameters: parameters,
            progress: { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite)  in
                print("bytesWritten: \(bytesWritten), totalBytesWritten: \(totalBytesWritten), totalBytesExpectedToWrite: \(totalBytesExpectedToWrite)")
            }, completionHandler: { (response, error) in
                XCTAssertNil(error, "error should be nil")
                getExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(600, handler: nil)
    }
}
