//
//  MockURLSession.swift
//  OpenMarketTests
//
//  Created by Kyungmin Lee on 2021/01/28.
//

import Foundation
@testable import OpenMarket

class MockURLSession: URLSessionProtocol {
    var makeRequestFail = false
    var urlSessionDataTask: MockURLSessionDataTask?
    var sampleData: Data
    
    init(makeRequestFail: Bool = false, sampleData: Data) {
        self.makeRequestFail = makeRequestFail
        self.sampleData = sampleData
    }
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let successResponse = HTTPURLResponse(url: OpenMarketAPI.registerMarketItem.url!, statusCode: 200, httpVersion: "2", headerFields: nil)
        let failurResponse = HTTPURLResponse(url: OpenMarketAPI.registerMarketItem.url!, statusCode: 410, httpVersion: "2", headerFields: nil)
        let urlSessionDataTask = MockURLSessionDataTask()
        
        urlSessionDataTask.resumeDidCall = {
            if self.makeRequestFail {
                completionHandler(nil, failurResponse, nil)
            } else {
                completionHandler(self.sampleData, successResponse, nil)
            }
        }
        self.urlSessionDataTask = urlSessionDataTask
        
        return urlSessionDataTask
    }
    
    
}
