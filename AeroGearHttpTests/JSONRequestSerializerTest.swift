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

    func testHeadersShouldExistOnRequestWhenPUT() {
        let url = "http://api.icndb.com/jokes/12"
        let serialiser = JsonRequestSerializer()
        let result = serialiser.request(url: URL(string: url)!, method:.put, parameters: ["param1": "value1"], headers: ["CUSTOM_HEADER": "a value"])
        // header should be contained on the returned request
        let header = result.allHTTPHeaderFields!["CUSTOM_HEADER"]
        
        XCTAssertNotNil(header)
        XCTAssertTrue(header == "a value", "header should match")
    }
    
    func testHeadersShouldExistOnRequestWhenPOST() {
        let url = "http://api.icndb.com/jokes/12"
        let serialiser = JsonRequestSerializer()
        let result = serialiser.request(url: URL(string: url)!, method:.post, parameters: ["param1": "value1"], headers: ["CUSTOM_HEADER": "a value"])
        // header should be contained on the returned request
        let header = result.allHTTPHeaderFields!["CUSTOM_HEADER"]
        
        XCTAssertNotNil(header)
        XCTAssertTrue(header == "a value", "header should match")
    }
}

