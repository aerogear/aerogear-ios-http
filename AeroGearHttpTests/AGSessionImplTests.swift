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

class AGSessionImplTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    // TODO
    func testGETWithWrongUrlFormat() {

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
