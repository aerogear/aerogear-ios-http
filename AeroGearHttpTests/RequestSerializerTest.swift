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

class RequestSerializerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    @available(iOS 8, *)
    func testGETWithParameters8() {
        let url = "http://api.icndb.com/jokes/12"
        let serialiser = JsonRequestSerializer()
        let result = serialiser.request(url: URL(string: url)!, method:.get, parameters: ["param1": "value1", "array": ["one", "two", "three", "four"], "numeric": 5])
        if let urlString = result.url?.absoluteString {
            XCTAssertTrue(urlString.contains("param1=value1"))
            XCTAssertTrue(urlString.contains("numeric=5"))
            XCTAssertTrue(urlString.contains("array%5B%5D=one&array%5B%5D=two&array%5B%5D=three&array%5B%5D=four"))
        } else {
            XCTFail("url should not give an empty string")
        }
    }
    
    func testGETWithParameters() {
        let url = "http://api.icndb.com/jokes/12"
        let serialiser = JsonRequestSerializer()
        let result = serialiser.request(url: URL(string: url)!, method:.get, parameters: ["param1": "value1", "array": ["one", "two", "three", "four"], "numeric": 5, "dictionary": ["key_one":"value_one"]])
        if let urlString = result.url?.absoluteString  {
            XCTAssertTrue(NSString(string: urlString).range(of: "param1=value1").location != NSNotFound)
            XCTAssertTrue(NSString(string: urlString).range(of: "numeric=5").location != NSNotFound)
            XCTAssertTrue(NSString(string: urlString).range(of: "dictionary%5Bkey_one%5D=value_one").location != NSNotFound)
            XCTAssertTrue(NSString(string: urlString).range(of: "array%5B%5D=one&array%5B%5D=two&array%5B%5D=three&array%5B%5D=four").location != NSNotFound)
        } else {
            XCTFail("url should not give an empty string")
        }
    }
    
    func testStringResponseSerializer() {
        let serialiser = StringResponseSerializer()
        
        let result: String? = serialiser.response("some text received".data(using: String.Encoding.utf8)!, 200) as? String
        XCTAssertTrue(result == "some text received")
    }
}
