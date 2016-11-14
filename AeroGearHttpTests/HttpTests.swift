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
@testable import AeroGearHttp
import OHHTTPStubs

// workaround do cocoapods central issue
public func stub(condition: @escaping OHHTTPStubsTestBlock, response: @escaping OHHTTPStubsResponseBlock) -> OHHTTPStubsDescriptor {
    return OHHTTPStubs.stubRequests(passingTest: condition, withStubResponse: response)
}

public func isHost(_ host: String) -> OHHTTPStubsTestBlock {
    return { req in req.url?.host == host }
}

class HttpTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        OHHTTPStubs.removeAllStubs()
    }
    
    func testCalculateURLWithoutSlash() {
        let http = Http()
        let finalURL = http.calculateURL(baseURL: "http://whatever.com", url: "/post")
        XCTAssertEqual(finalURL!.absoluteString, "http://whatever.com/post")
    }
    
    func testCalculateURLWithLeadingSlash() {
        let http = Http()
        let finalURL = http.calculateURL(baseURL: "http://whatever.com/", url: "/post")
        XCTAssertEqual(finalURL!.absoluteString, "http://whatever.com/post")
    }
    
    func testCalculateURLWithMalformedURL() {
        let http = Http()
        let finalURL = http.calculateURL(baseURL: "replace me", url: "/box/init")
        XCTAssertNil(finalURL)
    }
    
    func testSucessfulGet() {
        // set up http stub
        _ = stub(condition: isHost("whatever.com")) { _ in
            let obj = ["key":"value"]
            return OHHTTPStubsResponse(jsonObject: obj, statusCode: 200, headers: nil)
        }
        let http = Http(baseURL: "http://whatever.com")
        // async test expectation
        let getExpectation = expectation(description: "GET http method test");
        http.request(method: .get, path: "/get", completionHandler: {(response, error) in
                XCTAssertNil(error, "error should be nil")
                XCTAssertTrue((response as! Dictionary<String, String>)["key"] == "value")
                getExpectation.fulfill()
        })
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSucessfulPost() {
        // set up http stub
        _ = stub(condition: isHost("whatever.com")) { _ in
            let obj = ["key":"value"]
            return OHHTTPStubsResponse(jsonObject: obj, statusCode: 200, headers: nil)
        }
        let http = Http(baseURL: "http://whatever.com")
        // async test expectation
        let getExpectation = expectation(description: "POST http method test");
        http.request(method: .post, path: "/post", completionHandler: {(response, error) in
            XCTAssertNil(error, "error should be nil")
            XCTAssertTrue((response as! Dictionary<String, String>)["key"] == "value")
            getExpectation.fulfill()
        })
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSucessfulPut() {
        // set up http stub
        _ = stub(condition: isHost("whatever.com")) { _ in
            let obj = ["key":"value"]
            return OHHTTPStubsResponse(jsonObject: obj, statusCode: 200, headers: nil)
        }
        let http = Http(baseURL: "http://whatever.com")
        // async test expectation
        let getExpectation = expectation(description: "PUT http method test");
        http.request(method: .put, path: "/put",  completionHandler: {(response, error) in
            XCTAssertNil(error, "error should be nil")
            XCTAssertTrue((response as! Dictionary<String, String>)["key"] == "value")
            getExpectation.fulfill()
        })
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testDelete() {
        // set up http stub
        _ = stub(condition: isHost("whatever.com")) { _ in
            let obj = ["key":"value"]
            return OHHTTPStubsResponse(jsonObject: obj, statusCode: 200, headers: nil)
        }
        let http = Http(baseURL: "http://whatever.com")
        // async test expectation
        let getExpectation = expectation(description: "DELETE http method test");
        http.request(method: .delete, path: "/delete", completionHandler: {(response, error) in
            XCTAssertNil(error, "error should be nil")
            XCTAssertTrue((response as! Dictionary<String, String>)["key"] == "value")
            getExpectation.fulfill()
        })
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testSucessfulMultipartUploadWithPOST() {
        // set up http stub
        _ = stub(condition: isHost("whatever.com")) { _ in
            let obj = ["files" : ["file" : "Lorem ipsum dolor sit amet"], "form" : ["key" : "value"]]
            return OHHTTPStubsResponse(jsonObject: obj, statusCode: 200, headers: nil)
        }
        let http = Http(baseURL: "http://whatever.com")
        let data = "Lorem ipsum dolor sit amet".data(using: String.Encoding.utf8, allowLossyConversion: false)!
        let file = MultiPartData(data: data, name: "lorem", filename: "lorem.txt", mimeType: "plain/text")
        // async test expectation
        let getExpectation = expectation(description: "POST http method test");
        let parameters = ["key": "value", "file": file] as [String : Any]
        http.request(method: .post, path: "/post",  parameters: parameters, completionHandler: {(response, error) in
            XCTAssertNil(error, "error should be nil")
            // should contain form data
            let form = (response as! NSDictionary!)["form"] as! NSDictionary!
            XCTAssertEqual(form?["key"] as? String,  "value", "should be equal")
            // should contain file data
            let files = (response as! NSDictionary!)["files"] as! NSDictionary!
            XCTAssertNotNil(files?["file"], "should contain file")
            getExpectation.fulfill()
        })
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testSucessfulDownloadWithDefaultDestinationDirectory() {
        // set up http stub
        _ = stub(condition: isHost("whatever.com")) { _ in
            let obj = ["key":"value"]
            return OHHTTPStubsResponse(jsonObject: obj, statusCode: 200, headers: nil)
        }
        let http = Http(baseURL: "http://whatever.com")
        // async test expectation
        let getExpectation = expectation(description: "Download");
        let fileManager = FileManager.default
        let path  = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        do {
            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } catch _ {
        }
        http.download(url: "something",
            progress: { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite)  in
            }, completionHandler: { (response, error) in
                XCTAssertNil(error, "error should be nil")
                let result = response as! HTTPURLResponse
                XCTAssertTrue(result.statusCode == 200)
                getExpectation.fulfill()
        })
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testUploadWithMultipart() {
        // async test expectation
        let getExpectation = expectation(description: "Upload multipart");
        
        let http = Http(baseURL: "http://httpbin.org")
        let multiPartData = MultiPartData(data: "contents of a file".data(using: String.Encoding.utf8, allowLossyConversion: false)!, name: "name", filename: "filename.jpg", mimeType: "image/jpg")
        let parameters = ["file": multiPartData]
        
        http.upload(url: "/post", stream: InputStream(data: "contents of a file".data(using: String.Encoding.utf8, allowLossyConversion: false)!), parameters: parameters,
            progress: { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite)  in
                print("bytesWritten: \(bytesWritten), totalBytesWritten: \(totalBytesWritten), totalBytesExpectedToWrite: \(totalBytesExpectedToWrite)")
            }, completionHandler: { (response, error) in
                XCTAssertNil(error, "error should be nil")
                getExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 600, handler: nil)
    }
    
}
