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

import Foundation

/**
A response deserializer to a generic String object.
*/
public class StringResponseSerializer : ResponseSerializer {
    /**
    Deserialize the response received.
    
    :returns: the serialized response
    */
    public var response: (NSData, Int) -> AnyObject? = {(data: NSData, status: Int) -> (AnyObject?) in
        return NSString(data: data, encoding:NSUTF8StringEncoding)
    }
    
    /**
    Validate the response received.
    
    :returns:  either true or false if the response is valid for this particular serializer.
    */
    public var validateResponse: (NSURLResponse!, NSData) throws -> Void = { (response: NSURLResponse!, data: NSData) throws in
        var error: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
        let httpResponse = response as! NSHTTPURLResponse
        
        if !(httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
            let userInfo = [
                NSLocalizedDescriptionKey: NSHTTPURLResponse.localizedStringForStatusCode(httpResponse.statusCode),
                NetworkingOperationFailingURLResponseErrorKey: response]

            if (true) {
                error = NSError(domain: HttpResponseSerializationErrorDomain, code: httpResponse.statusCode, userInfo: userInfo)
            }
            
            throw error
        }
    }
    
    public init() {
    }
    
    public init(validateResponse: (NSURLResponse!, NSData) throws -> Void, response: (NSData, Int) -> AnyObject?) {
        self.validateResponse = validateResponse
        self.response = response
    }
    
    public init(validateResponse: (NSURLResponse!, NSData) throws -> Void) {
        self.validateResponse = validateResponse
    }
    
    public init(response: (NSData, Int) -> AnyObject?) {
        self.response = response
    }
}