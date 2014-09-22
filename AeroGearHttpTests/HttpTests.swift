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

    func http_200(request: NSURLRequest!, params:[String: String]?) -> StubResponse {
        var data: NSData
        if ((params) != nil) {
            data = NSJSONSerialization.dataWithJSONObject(params!, options: nil, error: nil)!
        } else {
            data = NSData.data()
        }
        return StubResponse(data:data, statusCode: 200, headers: ["Content-Type" : "text/json"])
    }
    
    func http_200_response(request: NSURLRequest!) -> StubResponse {
        return http_200(request, params: ["key1":"value1"])
    }
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        StubsManager.removeAllStubs()
    }
    
    func testGETWithoutParametersStub() {
        // set up http stub
        StubsManager.stubRequestsPassingTest({ (request: NSURLRequest!) -> Bool in
            return true
            }, withStubResponse:( http_200_response ))
        
        // async test expectation
        let getExpectation = expectationWithDescription("Retrieve data with GET without parameters");
        
        var url = "http://whatever.com"
        var http = Http(url: url, sessionConfig: NSURLSessionConfiguration.defaultSessionConfiguration())
        http.GET(completionHandler: {(response, error) in
            if (response != nil) {
                XCTAssertTrue(response!["key1"] as NSString == "value1")
                getExpectation.fulfill()
            }
        })
        
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testGETWithoutParameters() {
        // set up http stub
        StubsManager.stubRequestsPassingTest({ (request: NSURLRequest!) -> Bool in
            return true
            }, withStubResponse:( http_200_response ))
        // async test expectation
        let getExpectation = expectationWithDescription("Retrieve list of jokes");
        
        var url = "http://api.icndb.com/jokes"
        var http = Http(url: url, sessionConfig: NSURLSessionConfiguration.defaultSessionConfiguration())
        http.GET(completionHandler: {(response, error) in
                if (response != nil) {
                    getExpectation.fulfill()
                }
        })

        waitForExpectationsWithTimeout(10, handler:nil)

    }
    
    func testGETWithoutParametersWithspecificId() {
        // set up http stub
        StubsManager.stubRequestsPassingTest({ (request: NSURLRequest!) -> Bool in
            return true
            }, withStubResponse:( http_200_response ))
        // async test expectation
        let getExpectation = expectationWithDescription("Retrieve list of jokes");
        
        var url = "http://api.icndb.com/jokes/12"
        var http = Http(url: url, sessionConfig: NSURLSessionConfiguration.defaultSessionConfiguration())
        http.GET(completionHandler: {(response, error) in
            if (response != nil) {
                getExpectation.fulfill()
            }
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
