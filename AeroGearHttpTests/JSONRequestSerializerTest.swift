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

class JSONRequestSerializer: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testHttpDeinitShouldHappenAfterAllTasksAreCompleted() {
        // async test expectation
        let getExpectation = expectationWithDescription("request with valid JSON data");
        var http: Http?
        http = Http(baseURL: "http://httpbin.org")
        
        http?.GET("/get",  parameters: ["key": "value"], completionHandler: {(response, error) in
            XCTAssertNil(error, "error should be nil")
            
            var resp = (response as NSDictionary!)["args"] as NSDictionary!
            XCTAssertEqual(resp["key"] as String,  "value", "should be equal")
            
            getExpectation.fulfill()
        })
        // set http to nil to trigger deinit
        http = nil
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testJSONSerializerWithValidRequest() {
        // async test expectation
        let getExpectation = expectationWithDescription("request with valid JSON data");
        
        var http = Http(baseURL: "http://httpbin.org")
        
        http.GET("/get",  parameters: ["key": "value"], completionHandler: {(response, error) in
            XCTAssertNil(error, "error should be nil")
            
            var resp = (response as NSDictionary!)["args"] as NSDictionary!
            XCTAssertEqual(resp["key"] as String,  "value", "should be equal")
            
            getExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testJSONSerializerWithInvalidRequest() {
        // async test expectation
        let getExpectation = expectationWithDescription("request with invalid JSON data");
        
        var http = Http(baseURL: "http://httpbin.org")
        
        // request html data although json serializer is setup
        http.GET("/html",  parameters: ["key": "value"], completionHandler: {(response, error) in
            XCTAssertNotNil(error, "error should be not nil")
            // should be bad server response
            XCTAssertEqual(error!.code, NSURLErrorBadServerResponse)
            
            getExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(10, handler: nil)
    }
}