import Foundation
import Security

protocol KeychainServiceProtocol: Sendable {
    func save(_ value: String, for key: KeychainKey) throws
    func read(key: KeychainKey) throws -> String?
    func delete(key: KeychainKey) throws
}

enum KeychainKey: String {
    case aiAPIKey = "com.chambea.ai.apiKey"
    case userSessionToken = "com.chambea.session.token"
    case refreshToken = "com.chambea.session.refresh"
}

final class KeychainService: KeychainServiceProtocol, @unchecked Sendable {
    func save(_ value: String, for key: KeychainKey) throws {
        guard let data = value.data(using: .utf8) else { return }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unhandled(status: status)
        }
    }

    func read(key: KeychainKey) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status != errSecItemNotFound else { return nil }
        guard status == errSecSuccess, let data = result as? Data else {
            throw KeychainError.unhandled(status: status)
        }
        return String(data: data, encoding: .utf8)
    }

    func delete(key: KeychainKey) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandled(status: status)
        }
    }
}

enum KeychainError: Error {
    case unhandled(status: OSStatus)
}