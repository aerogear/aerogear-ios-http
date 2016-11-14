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

class HttpAuthenticationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testHTTPBasicAuthenticationWithValidCredentials() {
        // async test expectation
        let getExpectation = expectation(description: "HTTPBasicAuthentication with valid credentials");
        
        let user = "john"
        let password = "pass"
        let credential = URLCredential(user: user, password: password, persistence: .none)
        
        let http = Http(baseURL: "http://httpbin.org")
        
        http.request(method: .get, path: "/basic-auth/\(user)/\(password)", credential: credential, completionHandler: {(response, error) in
            XCTAssertNil(error, "error should be nil")
            
            let JSON = response as! NSDictionary!
            XCTAssertTrue(JSON?["authenticated"] as! Bool)
            
            getExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 300, handler: nil)
    }
    
    func testHTTPBasicAuthenticationWithInvalidCredentials() {
        // async test expectation
        let getExpectation = expectation(description: "HTTPBasicAuthentication with invalid credentials");
        
        let user = "john"
        let password = "pass"
        let credential = URLCredential(user: user, password: password, persistence: .none)
        
        let http = Http(baseURL: "http://httpbin.org")
        
        http.request(method: .get, path: "/basic-auth/\(user)/invalid", credential: credential, completionHandler: {(response, error) in
            XCTAssertNil(response, "response should be nil")
            XCTAssertNotNil(error, "error should not be nil")
            XCTAssert(error?.code == -999, "error code should be equal to -999:'cancelled'")
            
            getExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 300, handler: nil)
    }
    
    func testHTTPDigestAuthenticationWithValidCredentials() {
        // async test expectation
        let getExpectation = expectation(description: "HTTPDigestAuthentication with valid credentials");
        
        let user = "user"
        let password = "password"
        let credential = URLCredential(user: user, password: password, persistence: .none)
        
        let http = Http(baseURL: "http://httpbin.org")
        
        http.request(method: .get, path: "/digest-auth/auth/\(user)/\(password)", credential: credential, completionHandler: {(response, error) in
            XCTAssertNil(error, "error should be nil")
            
            let JSON = response as! NSDictionary!
            XCTAssertTrue(JSON?["authenticated"] as! Bool)
            
            getExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 300, handler: nil)
    }
    
    func testHTTPDigestAuthenticationWithInvalidCredentials() {
        // async test expectation
        let getExpectation = expectation(description: "HTTPDigestAuthentication with invalid credentials");
        
        let user = "john"
        let password = "pass"
        let credential = URLCredential(user: user, password: password, persistence: .none)
        
        let http = Http(baseURL: "http://httpbin.org")
        
        http.request(method: .get, path: "/digest-auth/auth/\(user)/invalid", credential: credential, completionHandler: {(response, error) in
            XCTAssertNil(response, "response should be nil")
            XCTAssertNotNil(error, "error should not be nil")
            XCTAssert(error?.code == -999, "error code should be equal to -999:'cancelled'")
            
            getExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 300, handler: nil)
    }
    
}
