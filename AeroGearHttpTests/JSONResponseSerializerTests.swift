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
 
 class JSONResponseSerializerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        OHHTTPStubs.removeAllStubs()
    }
    
    func testHttpDeinitShouldHappenAfterAllTasksAreCompleted() {
        // set up http stub
        _ = stub(condition: isHost("whatever.com")) { _ in
            let obj = ["key":"value"]
            return OHHTTPStubsResponse(jsonObject: obj, statusCode: 200, headers: nil)
        }
        // async test expectation
        let getExpectation = expectation(description: "request with valid JSON data");
        var http: Http?
        http = Http(baseURL: "http://whatever.com")
        
        http?.request(method: .get, path: "/get", completionHandler: {(response, error) in
            XCTAssertNil(error, "error should be nil")
            XCTAssertTrue((response as! Dictionary<String, String>)["key"] == "value")
            getExpectation.fulfill()
        })
        // set http to nil to trigger deinit
        http = nil
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testJSONSerializerWithValidRequestAndCustomResponseSerializerINGETMethod() {
        // set up http stub
        _ = stub(condition: isHost("whatever.com")) { _ in
            let obj = ["key":"value"]
            return OHHTTPStubsResponse(jsonObject: obj, statusCode: 200, headers: nil)
        }
        let http = Http(baseURL: "http://whatever.com")
        // async test expectation
        let getExpectation = expectation(description: "request with valid JSON data")
        let jsonSerializerAlwaysFails = JsonResponseSerializer(validation: { (response: URLResponse?, data: Data) -> Void in
            var error: NSError! = NSError(domain: "ERROR", code: 0, userInfo: nil)
            error = NSError(domain: HttpResponseSerializationErrorDomain, code: 444, userInfo: ["Foo":"bar"])
            throw error
        })
        
        // call GET with cutom Serializer
        http.request(method: .get, path: "/get", responseSerializer: jsonSerializerAlwaysFails, completionHandler: {(response, error) in
            XCTAssertNotNil(error, "error should not be nil")
            XCTAssertEqual(error!.code, 444)
            XCTAssertTrue(error!.userInfo.description.contains("Foo"))
            getExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testJSONSerializerWithValidRequestAndCustomValidationClosure() {
        // set up http stub
        _ = stub(condition: isHost("whatever.com")) { _ in
            let obj = ["key":"value"]
            return OHHTTPStubsResponse(jsonObject: obj, statusCode: 200, headers: nil)
        }
        
        let http = Http(baseURL: "http://whatever.com", sessionConfig: URLSessionConfiguration.default,
            requestSerializer: JsonRequestSerializer(),
            responseSerializer: JsonResponseSerializer(validation: { (response: URLResponse?, data: Data) -> Void in
                var error: NSError! = NSError(domain: HttpErrorDomain, code: 0, userInfo: nil)
                let httpResponse = response as! HTTPURLResponse
                
                if !(httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
                    let userInfo = [NSLocalizedDescriptionKey: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode),
                        NetworkingOperationFailingURLResponseErrorKey: response ?? ""] as [String : Any]
                    error = NSError(domain: HttpResponseSerializationErrorDomain, code: httpResponse.statusCode, userInfo: userInfo)
                    throw error
                }
                
                // validate JSON
                do {
                    try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0))
                } catch  _  {
                    let userInfo = [NSLocalizedDescriptionKey: "Invalid response received, can't parse JSON" as NSString,
                        NetworkingOperationFailingURLResponseErrorKey: response ?? ""] as [String : Any]
                    let customError = NSError(domain: HttpResponseSerializationErrorDomain, code: NSURLErrorBadServerResponse, userInfo: userInfo)
                    throw customError;
                }
                
            }))
        
        // async test expectation
        let getExpectation = expectation(description: "request with valid JSON data")
        http.request(method: .get, path: "/get", completionHandler: {(response, error) in
            XCTAssertNil(error, "error should be nil")
            XCTAssertTrue((response as! Dictionary<String, String>)["key"] == "value")
            getExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testJSONSerializerWithValidRequestAndCustomResponseClosure() {
        // set up http stub
        _ = stub(condition: isHost("whatever.com")) { _ in
            let obj = ["key":"value"]
            return OHHTTPStubsResponse(jsonObject: obj, statusCode: 200, headers: nil)
        }
        
        let http = Http(baseURL: "http://whatever.com", sessionConfig: URLSessionConfiguration.default,
            requestSerializer: JsonRequestSerializer(),
            responseSerializer: JsonResponseSerializer(validation: { (response: URLResponse?, data: Data) -> Void in
                var error: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
                let httpResponse = response as! HTTPURLResponse
                
                if !(httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
                    let userInfo = [NSLocalizedDescriptionKey: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode),
                        NetworkingOperationFailingURLResponseErrorKey: response ?? ""] as [String : Any]
                    error = NSError(domain: HttpResponseSerializationErrorDomain, code: httpResponse.statusCode, userInfo: userInfo)
                    throw error
                }
                
                // validate JSON
                do {
                    try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0))
                } catch  _  {
                    let userInfo = [NSLocalizedDescriptionKey: "Invalid response received, can't parse JSON" as NSString,
                        NetworkingOperationFailingURLResponseErrorKey: response ?? ""] as [String : Any]
                    let customError = NSError(domain: HttpResponseSerializationErrorDomain, code: NSURLErrorBadServerResponse, userInfo: userInfo)
                    throw customError;
                }
                
                }, response: { (data: Data, status: Int) -> Any? in
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0))
                        let finalResponse = ["status": status, "data": jsonResponse]
                        return finalResponse
                    } catch _ {
                        return nil
                    }

            }))
        
        // async test expectation
        let getExpectation = expectation(description: "request with valid JSON data")
        http.request(method: .get, path: "/get", completionHandler: {(response, error) in
            XCTAssertNil(error, "error should be nil")
            let resp = response as! [String: AnyObject]
            XCTAssertTrue(resp["status"] as! Int == 200)
            let responseData = resp["data"] as! [String: AnyObject]
            XCTAssertTrue(responseData["key"] as! String == "value")
            getExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testJSONSerializerWithInvalidRequestAndCustomValidationClosure() {
        // set up http stub
        _ = stub(condition: isHost("whatever.com")) {_ in OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)}
        
        let http = Http(baseURL: "http://whatever.com", sessionConfig: URLSessionConfiguration.default,
            requestSerializer: JsonRequestSerializer(),
            responseSerializer: JsonResponseSerializer(validation: { (response: URLResponse?, data: Data) -> Void in
                var error: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
                let httpResponse = response as! HTTPURLResponse
                
                if !(httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
                    error = NSError(domain: HttpResponseSerializationErrorDomain, code: httpResponse.statusCode, userInfo: ["Foo":"Bar"])
                    throw error
                }
                
                // validate JSON
                do {
                    try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0))
                } catch  _  {
                    let userInfo = [NSLocalizedDescriptionKey: "Don't care" as NSString,
                        NetworkingOperationFailingURLResponseErrorKey: response ?? ""] as [String : Any]
                    let customError = NSError(domain: HttpResponseSerializationErrorDomain, code: NSURLErrorBadServerResponse, userInfo: userInfo)
                    throw customError;
                }
                
            }))
        
        // async test expectation
        let getExpectation = expectation(description: "request with invalid JSON data");
        // request html data although json serializer is setup
        http.request(method: .get, path: "/html",  parameters: ["key": "value"], completionHandler: {(response, error) in
            XCTAssertNil(response, "response is nil")
            XCTAssertNotNil(error, "error should be not nil")
            XCTAssertEqual(error!.code, NSURLErrorBadServerResponse)
            XCTAssertTrue(error!.userInfo.description.contains("Don't care"))
            getExpectation.fulfill()
        })
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testJSONSerializerWithInvalidRequest() {
        // set up http stub
        _ = stub(condition: isHost("whatever.com")) {_ in OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)}
        let http = Http(baseURL: "http://whatever.com")
        // async test expectation
        let getExpectation = expectation(description: "request with invalid JSON data");
        // request html data although json serializer is setup
        http.request(method: .get, path: "/html",  parameters: ["key": "value"], completionHandler: {(response, error) in
            XCTAssertNil(response, "response is nil")
            XCTAssertNotNil(error, "error should be not nil")
            XCTAssertEqual(error!.code, NSURLErrorBadServerResponse)
            XCTAssertTrue(error!.userInfo.description.contains("Invalid response received, can't parse JSON"))
            getExpectation.fulfill()
        })
        waitForExpectations(timeout: 10, handler: nil)
    }
}
