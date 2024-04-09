//
//  NetworkLogger.swift
//  คนลูกทุ่ง
//
//  Created by TIGER on 8/12/2563 BE.
//


import Foundation
import Moya

public class NetworkLogger {
    
    static func log(request: URLRequest?) {
        print("\n 🚀🚀🚀🚀🚀🚀🚀- OUTGOING -🚀🚀🚀🚀🚀🚀🚀 \n")
        defer { print("\n 🛸🛸🛸🛸🛸🛸🛸-  END -🛸🛸🛸🛸🛸🛸🛸\n") }
        guard let request = request else {return}
        let urlAsString = request.url?.absoluteString ?? ""
        let urlComponents = URLComponents(string: urlAsString)
        
        let method = request.httpMethod != nil ? "🛠\(request.httpMethod ?? "")🛠" : ""
        let path = "🎢 \(urlComponents?.path ?? "") 🎢"
        let query = "\(urlComponents?.query ?? "")"
        let host = "🛰 \(urlComponents?.host ?? "") 🛰"
        
        var output = """
        🔫\(urlAsString) \n\n
        \(method) \(path)\(query) 🔫\n
        HOST: \(host)\n
        """
        
        for (key,value) in request.allHTTPHeaderFields ?? [:] {
            output += "🔌 \(key): \(value) 🔌\n"
        }
        
        if let body = request.httpBody {
            output += "\n 💾 \(String(data: body, encoding: .utf8) ?? "") 💾"
        }
        
        print(output)
    }
    
   
    static func log(response: HTTPURLResponse?, data: Response?, error: Error? = nil) {
        print("\n 🚀🚀🚀🚀🚀🚀🚀- INCOMING -🚀🚀🚀🚀🚀🚀🚀 \n")
        defer { print("\n 🛸🛸🛸🛸🛸🛸🛸-  END -🛸🛸🛸🛸🛸🛸🛸\n") }
        
        let urlString = response?.url?.absoluteString
        let components = NSURLComponents(string: urlString ?? "")
   
        let path = "\(components?.path ?? "")"
        let query = "\(components?.query ?? "")"
        
        var output = ""
        
        if let urlString = urlString {
            output += "🔮\(urlString)🔮"
            output += "\n\n"
        }
        
        if let statusCode =  response?.statusCode {
            output += "🔐HTTP \(statusCode) \(path)?\(query)🔐\n"
        }
        
        if let host = components?.host {
            output += "🏭Host: \(host)🏭\n"
        }
        
        for (key, value) in response?.allHeaderFields ?? [:] {
            output += "📲\(key): \(value)📲\n"
        }
        
        if let body = data?.data {
            output += "\n  🎯🎯🎯🎯🎯🎯🎯🎯- BODY -🎯🎯🎯🎯🎯🎯🎯🎯 \n"
            output += "\(body.prettyPrinted ?? "")"
            output += "\n 🎯🎯🎯🎯🎯🎯🎯🎯🎯🎯🎯🎯🎯🎯🎯🎯🎯🎯🎯🎯🎯 \n"
        }
        
        if error != nil {
            output += "\nError:❌ \(error!.localizedDescription)❌ \n"
        }
        
        print(output)
    }
}

extension Data {
    var prettyPrinted: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }

        return prettyPrintedString as String
    }
    
    func convertToDictionary() -> [String: Any]? {
        guard let jsonText = prettyPrinted else {return nil}
        if let data = jsonText.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                // Handle Error
            }
        }
        return nil
    }
}



struct VerbosePlugin: PluginType {
    let verbose: Bool
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
#if DEBUG
        NetworkLogger.log(request: request)
#endif
        return request
    }

    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
#if DEBUG
        switch result {
            case .success(let body):
                if verbose {
                    NetworkLogger.log(response:body.response, data: body)
                }
            case .failure( _):
                break
        }
#endif
    }

}
