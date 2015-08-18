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

import UIKit
import XCTest
import AeroGearHttp
import OHHTTPStubs

class JSONRequestSerializer: XCTestCase {
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
    
    func httpSuccessWithInvalidJson(request: NSURLRequest!) -> OHHTTPStubsResponse {
        return try! httpStubResponseWithInputParams(request, status: 200, params: nil)
    }
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        OHHTTPStubs.removeAllStubs()
    }


    func testHttpDeinitShouldHappenAfterAllTasksAreCompleted() {
        // set up http stub
        OHHTTPStubs.stubRequestsPassingTest({ (request: NSURLRequest!) -> Bool in
            return true
            }, withStubResponse: httpSuccessWithResponse)
        // async test expectation
        let getExpectation = expectationWithDescription("request with valid JSON data");
        var http: Http?
        http = Http(baseURL: "http://whatever.com")
        
        http?.GET("/get", completionHandler: {(response, error) in
            XCTAssertNil(error, "error should be nil")
            XCTAssertTrue(response!["key"] == "value")
            getExpectation.fulfill()
        })
        // set http to nil to trigger deinit
        http = nil
        waitForExpectationsWithTimeout(10, handler: nil)
    }

    
    func testJSONSerializerWithValidRequest() {
        // set up http stub
        OHHTTPStubs.stubRequestsPassingTest({ (request: NSURLRequest!) -> Bool in
            return true
            }, withStubResponse: httpSuccessWithResponse)
        let http = Http(baseURL: "http://whatever.com")
        // async test expectation
        let getExpectation = expectationWithDescription("request with valid JSON data")
        http.GET("/get", completionHandler: {(response, error) in
            XCTAssertNil(error, "error should be nil")
            XCTAssertTrue(response!["key"] == "value")
            getExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testJSONSerializerWithInvalidRequest() {
        // set up http stub
        OHHTTPStubs.stubRequestsPassingTest({ (request: NSURLRequest!) -> Bool in
            return true
            }, withStubResponse: httpSuccessWithInvalidJson)
        let http = Http(baseURL: "http://whatever.com")
        // async test expectation
        let getExpectation = expectationWithDescription("request with invalid JSON data");
        // request html data although json serializer is setup
        http.GET("/html",  parameters: ["key": "value"], completionHandler: {(response, error) in
            XCTAssertNil(response, "response is nil")
            XCTAssertNotNil(error, "error should be not nil")
            XCTAssertEqual(error!.code, NSURLErrorBadServerResponse)
            
            getExpectation.fulfill()
        })
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testHeadersShouldExistOnRequestWhenPUT() {
        let url = "http://api.icndb.com/jokes/12"
        let serialiser = JsonRequestSerializer()
        let result = serialiser.request(NSURL(string: url)!, method:.PUT, parameters: ["param1": "value1"], headers: ["CUSTOM_HEADER": "a value"])
        // header should be contained on the returned request
        let header = result.allHTTPHeaderFields!["CUSTOM_HEADER"]
        
        XCTAssertNotNil(header)
        XCTAssertTrue(header == "a value", "header should match")
    }
    
    func testHeadersShouldExistOnRequestWhenPOST() {
        let url = "http://api.icndb.com/jokes/12"
        let serialiser = JsonRequestSerializer()
        let result = serialiser.request(NSURL(string: url)!, method:.POST, parameters: ["param1": "value1"], headers: ["CUSTOM_HEADER": "a value"])
        // header should be contained on the returned request
        let header = result.allHTTPHeaderFields!["CUSTOM_HEADER"]
        
        XCTAssertNotNil(header)
        XCTAssertTrue(header == "a value", "header should match")
    }
}

