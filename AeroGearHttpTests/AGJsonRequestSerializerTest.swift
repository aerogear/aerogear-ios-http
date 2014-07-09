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

class AGJsonRequestSerializerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGETWithParameters() {
        
        var url = NSURL.URLWithString("http://api.icndb.com/jokes/12")
        var jsonSerialiser = AGJsonRequestSerializer(url: url, headers: Dictionary<String, String>())
        var result = jsonSerialiser.stringFromParameters(["param1": "value1", "array": ["one", "two", "three", "four"], "numeric": 5])
        XCTAssertTrue(result == "array[]=one&array[]=two&array[]=three&array[]=four&numeric=5&param1=value1")
        
    }
        
}
