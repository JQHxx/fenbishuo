//
//  CTError.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/1/21.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import Foundation

struct CTError: Error, CustomStringConvertible {
    
    let message: String
    
    let code: Int
    
    let file: String
    let function: String
    let line: Int
    
    init(_ message: String,
         code: Int = 0,
         _ file: String = #file,
         _ function: String = #function,
         _ line: Int = #line) {
        
        self.message = message
        self.code = code
        
        self.file = file
        self.function = function
        self.line = line
    }
    
    var description: String {
        return "CTError Code: \(code), Message: \(message) (\(function) - line:\(line))"
    }
}
