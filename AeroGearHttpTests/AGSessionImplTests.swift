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

class AGSessionImplTests: XCTestCase {

    func ok_http_200(request: NSURLRequest!) -> StubResponse {
        return StubResponse(data:"{\"key1\":\"value1\"}".dataUsingEncoding(NSUTF8StringEncoding), statusCode: 200, headers: ["Content-Type" : "text/json"])
    }
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        StubsManager.removeAllStubs()
    }
    // TODO
    func testGETWithWrongUrlFormat() {

    }

    func testGETWithoutParametersStub() {
        // set up http stub
        StubsManager.stubRequestsPassingTest({ (request: NSURLRequest!) -> Bool in
            return true
            }, withStubResponse:( ok_http_200 ))
        
        // async test expectation
        let getExpectation = expectationWithDescription("Retrieve data with GET without parameters");
        
        var url = "http://whatever.com"
        var http = AGSessionImpl(url: url, sessionConfig: NSURLSessionConfiguration.defaultSessionConfiguration())
        http.GET(nil, success: {(response: AnyObject?) -> Void in
            if response {
                XCTAssertTrue(response!["key1"] as NSString == "value1")
                getExpectation.fulfill()
            }
            }, failure: {(error: NSError) -> Void in
                XCTAssertTrue(false, "should have retrieved jokes")
                getExpectation.fulfill()
            })
        
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testGETWithoutParameters() {
        // async test expectation
        let getExpectation = expectationWithDescription("Retrieve list of jokes");
        
        var url = "http://api.icndb.com/jokes"
        var http = AGSessionImpl(url: url)
        http.GET(nil, success: {(response: AnyObject?) -> Void in
                if response {
                    getExpectation.fulfill()
                }
            }, failure: {(error: NSError) -> Void in
                XCTAssertTrue(false, "should have retrieved jokes")
                getExpectation.fulfill()
            })
        waitForExpectationsWithTimeout(10, handler: {(error: NSError!) -> () in })

    }
    
    func testGETWithoutParametersWithspecificId() {
        // async test expectation
        let getExpectation = expectationWithDescription("Retrieve list of jokes");
        
        var url = "http://api.icndb.com/jokes/12"
        var http = AGSessionImpl(url: url)
        http.GET(nil, success: {(response: AnyObject?) -> Void in
            if response {
                // to do with json response
                getExpectation.fulfill()
            }
            }, failure: {(error: NSError) -> Void in
                XCTAssertTrue(false, "should have retrieved jokes")
                getExpectation.fulfill()
            })
        waitForExpectationsWithTimeout(10, handler: {(error: NSError!) -> () in })
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
