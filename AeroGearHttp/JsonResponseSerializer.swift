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
A response deserializer to JSON objects.
*/
public class JsonResponseSerializer : ResponseSerializer {
    /**
    Deserialize the response received.
    
    :returns: the serialized response
    */
    public func response(data: NSData) -> (AnyObject?) {
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
        } catch _ {
            return nil
        }
    }
    
    /**
    Validate the response received. throw an error is the response is not va;id.
    
    :returns:  either true or false if the response is valid for this particular serializer.
    */
    public func validateResponse(response: NSURLResponse!, data: NSData) throws {
        var error: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
        let httpResponse = response as! NSHTTPURLResponse
        
        if !(httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
            let userInfo = [NSLocalizedDescriptionKey: NSHTTPURLResponse.localizedStringForStatusCode(httpResponse.statusCode),
                NetworkingOperationFailingURLResponseErrorKey: response]
            error = NSError(domain: HttpResponseSerializationErrorDomain, code: httpResponse.statusCode, userInfo: userInfo)
            throw error
        }
        
        // validate JSON
        do {
            try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
        } catch  _  {
            let userInfo = [NSLocalizedDescriptionKey: "Invalid response received, can't parse JSON" as NSString,
                NetworkingOperationFailingURLResponseErrorKey: response]
            let customError = NSError(domain: HttpResponseSerializationErrorDomain, code: NSURLErrorBadServerResponse, userInfo: userInfo)
            throw customError;
        }
    }
    
    public init() {
    }
}