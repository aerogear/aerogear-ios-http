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
A request serializer to JSON objects/
*/
public class JsonRequestSerializer:  HttpRequestSerializer {
    
    public override func request(url: NSURL, method: HttpMethod, parameters: [String: AnyObject]?, headers: [String: String]? = nil) -> NSURLRequest {
        if method == HttpMethod.GET || method == HttpMethod.HEAD || method == HttpMethod.DELETE {
            return super.request(url, method: method, parameters: parameters, headers: headers)
        } else {
            var request = NSMutableURLRequest(URL: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
            request.HTTPMethod = method.rawValue

            // set type
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            // set body
            if (parameters != nil) {
                var body =  NSJSONSerialization.dataWithJSONObject(parameters!, options: nil, error: nil)
                // set body
                if (body != nil) {
                    request.setValue("\(body?.length)", forHTTPHeaderField: "Content-Length")
                    request.HTTPBody = body
                }
            }
            
            // apply headers to new request
            if(headers != nil) {
                for (key,val) in headers! {
                    request.addValue(val, forHTTPHeaderField: key)
                }
            }

            return request
        }
    }
}
