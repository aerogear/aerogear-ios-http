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
    
    func httpStubResponseWithInputParams(request: NSURLRequest!, status: Int, params:[String: AnyObject]?) -> OHHTTPStubsResponse {
        var data: NSData
        if params != nil {
            data = NSJSONSerialization.dataWithJSONObject(params!, options: nil, error: nil)!
        } else {
            data = "invalid json".dataUsingEncoding(NSUTF8StringEncoding)!
        }
        return OHHTTPStubsResponse(data:data, statusCode: CInt(status), headers: ["Content-Type" : "application/json"])
    }
    
    func httpSuccessWithResponse(request: NSURLRequest!) -> OHHTTPStubsResponse {
        return httpStubResponseWithInputParams(request, status: 200, params: ["key" : "value"])
    }
    
    func httpSuccessWithInvalidJson(request: NSURLRequest!) -> OHHTTPStubsResponse {
        return httpStubResponseWithInputParams(request, status: 200, params: nil)
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
            XCTAssertTrue(response!["key"] as NSString == "value")
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
        var http = Http(baseURL: "http://whatever.com")
        // async test expectation
        let getExpectation = expectationWithDescription("request with valid JSON data")
        http.GET("/get", completionHandler: {(response, error) in
            XCTAssertNil(error, "error should be nil")
            XCTAssertTrue(response!["key"] as NSString == "value")
            getExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testJSONSerializerWithInvalidRequest() {
        // set up http stub
        OHHTTPStubs.stubRequestsPassingTest({ (request: NSURLRequest!) -> Bool in
            return true
            }, withStubResponse: httpSuccessWithInvalidJson)
        var http = Http(baseURL: "http://whatever.com")
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
        var url = "http://api.icndb.com/jokes/12"
        var serialiser = JsonRequestSerializer()
        var result = serialiser.request(NSURL(string: url)!, method:.PUT, parameters: ["param1": "value1"], headers: ["CUSTOM_HEADER": "a value"])
        // header should be contained on the returned request
        var header = result.allHTTPHeaderFields!["CUSTOM_HEADER"] as String
        
        XCTAssertNotNil(header)
        XCTAssertTrue(header == "a value", "header should match")
    }
    
    func testHeadersShouldExistOnRequestWhenPOST() {
        var url = "http://api.icndb.com/jokes/12"
        var serialiser = JsonRequestSerializer()
        var result = serialiser.request(NSURL(string: url)!, method:.POST, parameters: ["param1": "value1"], headers: ["CUSTOM_HEADER": "a value"])
        // header should be contained on the returned request
        var header = result.allHTTPHeaderFields!["CUSTOM_HEADER"] as String
        
        XCTAssertNotNil(header)
        XCTAssertTrue(header == "a value", "header should match")
    }
}

