//
//  File.swift
//
//
//  Created by Sittichai Chumjai on 8/4/2567 BE.
//

import Foundation
import Security


public class TokenManager{
    
    init(){
    }

    public static var accessToken: String? {
        get {
            return KeychainManager.shared.getToken(forKey: "accessToken") ?? ""
        }
        set {
            let _ = try? KeychainManager.shared.saveToken(newValue ?? "", forKey: "accessToken")
        }
    }

    public static var  refreshToken: String? {
        get {
            return KeychainManager.shared.getToken(forKey: "refreshToken") ?? ""
        }
        set {
            let _ = try? KeychainManager.shared.saveToken(newValue ?? "", forKey: "refreshToken")
        }
    }

    public static var expiredTimestamp: TimeInterval? {
        get {
            return TimeInterval(UserDefaults.standard.double(forKey:"expiredTimestamp"))
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "expiredTimestamp")
        }
    }
}



final class KeychainManager {
    static let shared = KeychainManager()
    private init() {}

    enum KeychainError: Error {
        case storeFailed
        case duplicateEntry
        case unknown(OSStatus)
    }

    func saveToken(_ token: String, forKey key: String) throws {
        if let data = token.data(using: .utf8) {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecValueData as String: data,
                kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
            ]

            let status = SecItemAdd(query as CFDictionary, nil)

            guard status != errSecDuplicateItem else {
                throw KeychainError.duplicateEntry
            }

            guard status == errSecSuccess else {
                throw KeychainError.unknown(status)
            }
        }
    }


    func getToken(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        }

        return nil
    }

}






