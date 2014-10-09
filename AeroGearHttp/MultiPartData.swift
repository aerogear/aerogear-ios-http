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

public class MultiPartData {

    public var name: String
    public var filename: String
    public var mimeType: String
    public var data: NSData
    
    init(url: NSURL, mimeType: String) {
        self.name = url.lastPathComponent
        self.filename = url.lastPathComponent
        self.mimeType = mimeType;
        
        self.data = NSData(contentsOfURL: url)!
    }
    
    init(data: NSData, name: String, filename: String, mimeType: String) {
        self.data = data;
        self.name = name;
        self.filename = filename;
        self.mimeType = mimeType;
    }
}
