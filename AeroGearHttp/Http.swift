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

public enum HttpMethod: String {
    case GET = "GET"
    case HEAD = "HEAD"
    case DELETE = "DELETE"
    case POST = "POST"
    case PUT = "PUT"
}

enum FileRequestType {
    case Download(String?)
    case Upload(UploadType)
}

enum UploadType {
    case Data(NSData)
    case File(NSURL)
    case Stream(NSInputStream)
}

public typealias ProgressBlock = (Int64, Int64, Int64) -> Void
public typealias CompletionBlock = (AnyObject?, NSError?) -> Void

public class Http {

    var baseURL: String?
    var session: NSURLSession
    var requestSerializer: RequestSerializer
    var responseSerializer: ResponseSerializer
    var authzModule:  AuthzModule?
    
    private var delegate: SessionDelegate;
    
    public init(baseURL: String? = nil,
                    sessionConfig: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration(),
                    requestSerializer: RequestSerializer = JsonRequestSerializer(),
                    responseSerializer: ResponseSerializer = JsonResponseSerializer()) {
        self.baseURL = baseURL
        self.delegate = SessionDelegate()
        self.session = NSURLSession(configuration: sessionConfig, delegate: self.delegate, delegateQueue: NSOperationQueue.mainQueue())
        self.requestSerializer = requestSerializer
        self.responseSerializer = responseSerializer
    }
    
    deinit {
        self.session.invalidateAndCancel()
    }

    private func request(url: String, parameters: [String: AnyObject]? = nil,  method:HttpMethod, completionHandler: CompletionBlock) {
        let block: () -> Void =  {
            var finalURL = self.calculateURL(self.baseURL, url: url)
            
            var request: NSURLRequest
            
            // care for multipart request is multipart data are set
            if (self.hasMultiPartData(parameters)) {
                request = self.requestSerializer.multipartRequest(finalURL, method: method, parameters: parameters, headers: self.authzModule?.authorizationFields())
            } else {
                request = self.requestSerializer.request(finalURL, method: method, parameters: parameters, headers: self.authzModule?.authorizationFields())
            }

            let task = self.session.dataTaskWithRequest(request);
            let delegate = TaskDataDelegate()
            delegate.completionHandler = completionHandler
            delegate.responseSerializer = self.responseSerializer;
            
            self.delegate[task] = delegate
            task.resume()
        }
        
        // cater for authz and pre-authorize prior to performing request
        if (self.authzModule != nil) {
            self.authzModule?.requestAccess({ (response, error ) in
                // if there was an error during authz, no need to continue
                if (error != nil) {
                    completionHandler(nil, error)
                    return
                }
                // ..otherwise proceed normally
                block();
            })
        } else {
            block()
        }
    }
    
    private func fileRequest(url: String, parameters: [String: AnyObject]? = nil,  method: HttpMethod,  type: FileRequestType, progress: ProgressBlock?, completionHandler: CompletionBlock) {
        
        let block: () -> Void  = {
            var finalURL = self.calculateURL(self.baseURL, url: url)
            let request = self.requestSerializer.request(finalURL, method: method, parameters: parameters, headers: self.authzModule?.authorizationFields())
            
            var task: NSURLSessionTask

            switch type {
                case .Download(let destinationDirectory):
                    task = self.session.downloadTaskWithRequest(request)
                    
                    let delegate = TaskDownloadDelegate()
                    delegate.downloadProgress = progress
                    delegate.destinationDirectory = destinationDirectory;
                    delegate.completionHandler = completionHandler

                    self.delegate[task] = delegate

                case .Upload(let uploadType):
                    switch uploadType {
                        case .Data(let data):
                            task = self.session.uploadTaskWithRequest(request, fromData: data)
                        case .File(let url):
                            task = self.session.uploadTaskWithRequest(request, fromFile: url)
                        case .Stream(let stream):
                            task = self.session.uploadTaskWithStreamedRequest(request)
                    }

                let delegate = TaskUploadDelegate()
                delegate.uploadProgress = progress
                delegate.completionHandler = completionHandler
                    
                self.delegate[task] = delegate
            }
            
            task.resume()
        }
        
        // cater for authz and pre-authorize prior to performing request
        if (self.authzModule != nil) {
            self.authzModule?.requestAccess({ (response, error ) in
                // if there was an error during authz, no need to continue
                if (error != nil) {
                    completionHandler(nil, error)
                    return
                }
                // ..otherwise proceed normally
                block();
            })
        } else {
            block()
        }
    }
    
    public func GET(url: String, parameters: [String: AnyObject]? = nil, completionHandler: CompletionBlock) {
        request(url, parameters: parameters,  method:.GET, completionHandler: completionHandler)
    }
    
    public func POST(url: String, parameters: [String: AnyObject]? = nil, completionHandler: CompletionBlock) {
        request(url, parameters: parameters, method:.POST, completionHandler: completionHandler)
    }
    
    public func PUT(url: String, parameters: [String: AnyObject]? = nil, completionHandler: CompletionBlock) {
        request(url, parameters: parameters, method:.PUT, completionHandler: completionHandler)
    }
    
    public func DELETE(url: String, parameters: [String: AnyObject]? = nil, completionHandler: CompletionBlock) {
        request(url, parameters: parameters, method:.DELETE, completionHandler: completionHandler)
    }
    
    public func HEAD(url: String, parameters: [String: AnyObject]? = nil, completionHandler: CompletionBlock) {
        request(url, parameters: parameters, method:.HEAD, completionHandler: completionHandler)
    }
    
    public func download(url: String,  destinationDirectory: String? = nil, parameters: [String: AnyObject]? = nil,  method: HttpMethod = .GET, progress: ProgressBlock?, completionHandler: CompletionBlock) {
        fileRequest(url, parameters: parameters, method: method, type: .Download(destinationDirectory), progress: progress, completionHandler: completionHandler)
    }
    
    public func upload(url: String,  file: NSURL, parameters: [String: AnyObject]? = nil,  method: HttpMethod = .POST, progress: ProgressBlock?, completionHandler: CompletionBlock) {
        fileRequest(url, parameters: parameters, method: method, type: .Upload(.File(file)), progress: progress, completionHandler: completionHandler)
    }
    
    public func upload(url: String,  data: NSData, parameters: [String: AnyObject]? = nil, method: HttpMethod = .POST, progress: ProgressBlock?, completionHandler: CompletionBlock) {
        fileRequest(url, parameters: parameters, method: method, type: .Upload(.Data(data)), progress: progress, completionHandler: completionHandler)
    }
    
    public func upload(url: String,  stream: NSInputStream,  parameters: [String: AnyObject]? = nil, method: HttpMethod = .POST, progress: ProgressBlock?, completionHandler: CompletionBlock) {
        fileRequest(url, parameters: parameters, method: method, type: .Upload(.Stream(stream)), progress: progress, completionHandler: completionHandler)
    }
    
    // MARK: SessionDelegate
    class SessionDelegate: NSObject, NSURLSessionDelegate,  NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate {
        
        private var delegates: [Int:  TaskDelegate]
        
        private subscript(task: NSURLSessionTask) -> TaskDelegate? {
            get {
                return self.delegates[task.taskIdentifier]
            }
            
            set (newValue) {
                self.delegates[task.taskIdentifier] = newValue
            }
        }
        
        required override init() {
            self.delegates = Dictionary()
            super.init()
        }
        
        func URLSession(session: NSURLSession!, didBecomeInvalidWithError error: NSError!) {
            // TODO
        }
        
        func URLSession(session: NSURLSession!, didReceiveChallenge challenge: NSURLAuthenticationChallenge!, completionHandler: ((NSURLSessionAuthChallengeDisposition, NSURLCredential!) -> Void)!) {

            // TODO: handle authentication
            completionHandler(.PerformDefaultHandling, nil)
        }
        
        func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession!) {
            // TODO
        }
        
        // MARK: NSURLSessionTaskDelegate
        
        func URLSession(session: NSURLSession!, task: NSURLSessionTask!, willPerformHTTPRedirection response: NSHTTPURLResponse!, newRequest request: NSURLRequest!, completionHandler: ((NSURLRequest!) -> Void)!) {
            
            if let delegate = self[task] {
                delegate.URLSession(session, task: task, willPerformHTTPRedirection: response, newRequest: request, completionHandler: completionHandler)
            }
        }
        
        func URLSession(session: NSURLSession!, task: NSURLSessionTask!, didReceiveChallenge challenge: NSURLAuthenticationChallenge!, completionHandler: ((NSURLSessionAuthChallengeDisposition, NSURLCredential!) -> Void)!) {
            if let delegate = self[task] {
                delegate.URLSession(session, task: task, didReceiveChallenge: challenge, completionHandler: completionHandler)
            } else {
                self.URLSession(session, didReceiveChallenge: challenge, completionHandler: completionHandler)
            }
        }
        
        func URLSession(session: NSURLSession!, task: NSURLSessionTask!, needNewBodyStream completionHandler: ((NSInputStream!) -> Void)!) {
            if let delegate = self[task] {
                delegate.URLSession(session, task: task, needNewBodyStream: completionHandler)
            }
        }
        
        func URLSession(session: NSURLSession!, task: NSURLSessionTask!, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
            if let delegate = self[task] as? TaskUploadDelegate {
                delegate.URLSession(session, task: task, didSendBodyData: bytesSent, totalBytesSent: totalBytesSent, totalBytesExpectedToSend: totalBytesExpectedToSend)
            }
        }
        
        func URLSession(session: NSURLSession!, task: NSURLSessionTask!, didCompleteWithError error: NSError!) {
            if let delegate = self[task] {
                delegate.URLSession(session, task: task, didCompleteWithError: error)
            }
        }
        
        // MARK: NSURLSessionDataDelegate
        
        func URLSession(session: NSURLSession!, dataTask: NSURLSessionDataTask!, didReceiveResponse response: NSURLResponse!, completionHandler: ((NSURLSessionResponseDisposition) -> Void)!) {
            completionHandler(.Allow)
        }
        
        func URLSession(session: NSURLSession!, dataTask: NSURLSessionDataTask!, didBecomeDownloadTask downloadTask: NSURLSessionDownloadTask!) {
            let downloadDelegate = TaskDownloadDelegate()
            self[downloadTask] = downloadDelegate
        }
        
       func URLSession(session: NSURLSession!, dataTask: NSURLSessionDataTask!, didReceiveData data: NSData!) {
            if let delegate = self[dataTask] as? TaskDataDelegate {
                delegate.URLSession(session, dataTask: dataTask, didReceiveData: data)
            }
        }
        
        func URLSession(session: NSURLSession!, dataTask: NSURLSessionDataTask!, willCacheResponse proposedResponse: NSCachedURLResponse!, completionHandler: ((NSCachedURLResponse!) -> Void)!) {

            completionHandler(proposedResponse)
        }
        
        // MARK: NSURLSessionDownloadDelegate
        
        func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
            if let delegate = self[downloadTask] as? TaskDownloadDelegate {
                delegate.URLSession(session, downloadTask: downloadTask, didFinishDownloadingToURL: location)
            }
        }
        
        func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
            if let delegate = self[downloadTask] as? TaskDownloadDelegate {
                delegate.URLSession(session, downloadTask: downloadTask, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
            }
        }
        
        func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
            if let delegate = self[downloadTask] as? TaskDownloadDelegate {
                delegate.URLSession(session, downloadTask: downloadTask, didResumeAtOffset: fileOffset, expectedTotalBytes: expectedTotalBytes)
            }
        }
    }
    
    // MARK: NSURLSessionTaskDelegate
    private class TaskDelegate: NSObject, NSURLSessionTaskDelegate {
        
        var data: NSData? { return nil }
        var completionHandler:  ((AnyObject?, NSError?) -> Void)?
        var responseSerializer: ResponseSerializer?
        
        func URLSession(session: NSURLSession!, task: NSURLSessionTask!, willPerformHTTPRedirection response: NSHTTPURLResponse!, newRequest request: NSURLRequest!, completionHandler: ((NSURLRequest!) -> Void)!) {
        
            completionHandler(request)
        }
        
        func URLSession(session: NSURLSession!, task: NSURLSessionTask!, didReceiveChallenge challenge: NSURLAuthenticationChallenge!, completionHandler: ((NSURLSessionAuthChallengeDisposition, NSURLCredential!) -> Void)!) {
            var disposition: NSURLSessionAuthChallengeDisposition = .PerformDefaultHandling
            var credential: NSURLCredential?
            
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                credential = NSURLCredential(forTrust: challenge.protectionSpace.serverTrust)
                disposition = .UseCredential
            }
            completionHandler(disposition, credential)
        }
        
        func URLSession(session: NSURLSession!, task: NSURLSessionTask!, needNewBodyStream completionHandler: ((NSInputStream!) -> Void)!) {
        }
        
        func URLSession(session: NSURLSession!, task: NSURLSessionTask!, didCompleteWithError error: NSError!) {
            if error != nil {
                completionHandler?(nil, error)
                return
            }
            
            var response = task.response as NSHTTPURLResponse
            
            if  let downloadTask = task as? NSURLSessionDownloadTask {
                completionHandler?(response, error)
                return
            }
            
            if let uploadTask = task as? NSURLSessionUploadTask {
                completionHandler?(response, error)
                return
            }
            
            var error: NSError?
            var isValid = self.responseSerializer?.validateResponse(response, data: data!, error: &error)
            
            if (isValid == false) {
                completionHandler?(nil, error)
                return
            }
        
            if (data != nil) {
                var responseObject: AnyObject? = self.responseSerializer?.response(data!)
                completionHandler?(responseObject, nil)
            }
        }
    }
    
    // MARK: NSURLSessionDataDelegate
    private class TaskDataDelegate: TaskDelegate, NSURLSessionDataDelegate {
        
        private var mutableData: NSMutableData
        override var data: NSData? {
            return self.mutableData
        }

        override init() {
            self.mutableData = NSMutableData()
        }

        func URLSession(session: NSURLSession!, dataTask: NSURLSessionDataTask!, didReceiveData data: NSData!) {
            self.mutableData.appendData(data)
        }
        
        func URLSession(session: NSURLSession!, dataTask: NSURLSessionDataTask!, willCacheResponse proposedResponse: NSCachedURLResponse!, completionHandler: ((NSCachedURLResponse!) -> Void)!) {
            var cachedResponse = proposedResponse
            completionHandler(cachedResponse)
        }
    }
    
    // MARK: NSURLSessionDownloadDelegate
    private class TaskDownloadDelegate: TaskDelegate, NSURLSessionDownloadDelegate {

        var downloadProgress: ((Int64, Int64, Int64) -> Void)?
        var resumeData: NSData?
        var destinationDirectory: String?

        func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
            let filename = downloadTask.response?.suggestedFilename
            
            // calculate final destination
            var finalDestination: NSURL
            if (destinationDirectory == nil) {  // use 'default documents' directory if not set
                // use default documents directory
                var documentsDirectory  = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL
                finalDestination = documentsDirectory.URLByAppendingPathComponent(filename!)
            } else {
                // check that the directory exists
                var path = destinationDirectory?.stringByAppendingPathComponent(filename!)
                finalDestination = NSURL(fileURLWithPath: path!)!
            }

            NSFileManager.defaultManager().moveItemAtURL(location, toURL: finalDestination, error: nil)
        }
        
        func URLSession(session: NSURLSession!, downloadTask: NSURLSessionDownloadTask!, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
            
            self.downloadProgress?(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite)
        }
        
        func URLSession(session: NSURLSession!, downloadTask: NSURLSessionDownloadTask!, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        }
    }

    // MARK: NSURLSessionTaskDelegate
    private class TaskUploadDelegate: TaskDataDelegate {

        var uploadProgress: ((Int64, Int64, Int64) -> Void)?
        
        func URLSession(session: NSURLSession!, task: NSURLSessionTask!, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
                self.uploadProgress?(bytesSent, totalBytesSent, totalBytesExpectedToSend)
        }
    }

    // MARK: Utility methods
    public func calculateURL(baseURL: String?,  var url: String) -> NSURL {
        if (baseURL == nil || url.hasPrefix("http")) {
            return NSURL(string: url)!
        }
        
        var finalURL = NSURL(string: baseURL!)!
        if (url.hasPrefix("/")) {
            url = url.substringFromIndex(advance(url.startIndex, 0))
        }
            
        return finalURL.URLByAppendingPathComponent(url);
    }
    
    public func hasMultiPartData(parameters: [String: AnyObject]?) -> Bool {
        if (parameters == nil) {
            return false
        }
        
        var isMultiPart = false
        for (_, value) in parameters! {
            if value is MultiPartData {
                isMultiPart = true
                break
            }
        }
        
        return isMultiPart
    }
}