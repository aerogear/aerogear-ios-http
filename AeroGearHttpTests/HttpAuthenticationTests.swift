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
        let getExpectation = expectationWithDescription("HTTPBasicAuthentication with valid credentials");
        
        let user = "john"
        let password = "pass"
        let credential = NSURLCredential(user: user, password: password, persistence: .None)
        
        let http = Http(baseURL: "http://httpbin.org")
        
        http.request(.GET, path: "/basic-auth/\(user)/\(password)", credential: credential, completionHandler: {(response, error) in
            XCTAssertNil(error, "error should be nil")
            
            let JSON = response as! NSDictionary!
            XCTAssertTrue(JSON["authenticated"] as! Bool)
            
            getExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(300, handler: nil)
    }
    
    func testHTTPBasicAuthenticationWithInvalidCredentials() {
        // async test expectation
        let getExpectation = expectationWithDescription("HTTPBasicAuthentication with invalid credentials");
        
        let user = "john"
        let password = "pass"
        let credential = NSURLCredential(user: user, password: password, persistence: .None)
        
        let http = Http(baseURL: "http://httpbin.org")
        
        http.request(.GET, path: "/basic-auth/\(user)/invalid", credential: credential, completionHandler: {(response, error) in
            XCTAssertNil(response, "response should be nil")
            XCTAssertNotNil(error, "error should not be nil")
            XCTAssert(error?.code == -999, "error code should be equal to -999:'cancelled'")
            
            getExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(300, handler: nil)
    }
    
    func testHTTPDigestAuthenticationWithValidCredentials() {
        // async test expectation
        let getExpectation = expectationWithDescription("HTTPDigestAuthentication with valid credentials");
        
        let user = "user"
        let password = "password"
        let credential = NSURLCredential(user: user, password: password, persistence: .None)
        
        let http = Http(baseURL: "http://httpbin.org")
        
        http.request(.GET, path: "/digest-auth/auth/\(user)/\(password)", credential: credential, completionHandler: {(response, error) in
            XCTAssertNil(error, "error should be nil")
            
            let JSON = response as! NSDictionary!
            XCTAssertTrue(JSON["authenticated"] as! Bool)
            
            getExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(300, handler: nil)
    }
    
    func testHTTPDigestAuthenticationWithInvalidCredentials() {
        // async test expectation
        let getExpectation = expectationWithDescription("HTTPDigestAuthentication with invalid credentials");
        
        let user = "john"
        let password = "pass"
        let credential = NSURLCredential(user: user, password: password, persistence: .None)
        
        let http = Http(baseURL: "http://httpbin.org")
        
        http.request(.GET, path: "/digest-auth/auth/\(user)/invalid", credential: credential, completionHandler: {(response, error) in
            XCTAssertNil(response, "response should be nil")
            XCTAssertNotNil(error, "error should not be nil")
            XCTAssert(error?.code == -999, "error code should be equal to -999:'cancelled'")
            
            getExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(300, handler: nil)
    }
    
    /*
    func testHTTPAuthenticationWithProtectionSpace() {
        // async test expectation
        let getExpectation = expectationWithDescription("HTTPAuthenticationWithProtectionSpace");

        let user = "user"
        let password = "password"
        // notice that we use '.ForSession' type otherwise credential storage will discard and
        // won't save it when doing 'credentialStorage.setDefaultCredential' later on
        let credential = NSURLCredential(user: user, password: password, persistence: .ForSession)

        // create a protection space
        let protectionSpace: NSURLProtectionSpace = NSURLProtectionSpace(host: "httpbin.org", port: 443,protocol: NSURLProtectionSpaceHTTPS, realm: "me@kennethreitz.com", authenticationMethod: NSURLAuthenticationMethodHTTPDigest);
        
        // assign it to credential storage
        let credentialStorage: NSURLCredentialStorage = NSURLCredentialStorage.sharedCredentialStorage()
        credentialStorage.setDefaultCredential(credential, forProtectionSpace: protectionSpace);

        // set up default configuration and assign credential storage
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.URLCredentialStorage = credentialStorage
        
        print(configuration.URLCredentialStorage?.allCredentials.count);
        // assign custom configuration to Http
        let http = Http(baseURL: "https://httpbin.org", sessionConfig: configuration)
        
        // perform request, the credentials would be used when requested
        http.request(.GET, path: "/digest-auth/auth/\(user)/\(password)", completionHandler: {(response, error) in
            XCTAssertNil(error, "error should be nil")
            
            let JSON = response as! NSDictionary!
            XCTAssertTrue(JSON["authenticated"] as! Bool)
            
            getExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(300, handler: nil)
    }
 */
    
}
