//
//  KeychainService.swift
//  Blendery
//
//  Created by 박성준 on 12/24/25.
//

import Foundation
import Security

final class KeychainHelper {
    static let shared = KeychainHelper()
    private let serviceName = "com.blendary.app" // 앱 식별자

    // ✅ 토큰은 한 개만 쓸 거라 account를 고정 키로 사용
    private let tokenAccount = "accessToken"

    // 1. 토큰 저장 (Save)
    func saveToken(token: String) {
        let data = Data(token.utf8)

        // ✅ 기존 데이터 삭제 (service + account 기준)
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: tokenAccount
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        // ✅ 새 데이터 추가
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: tokenAccount,
            kSecValueData as String: data
        ]
        SecItemAdd(addQuery as CFDictionary, nil)
    }

    // 2. 토큰 읽기 (Read)
    // ✅ 기존 시그니처 유지(하지만 내부는 tokenAccount 사용)
    func readToken(account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: tokenAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == errSecSuccess, let data = item as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }

    // 3. 토큰 삭제 (Delete - 로그아웃 시 사용)
    func deleteToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: tokenAccount
        ]
        SecItemDelete(query as CFDictionary)
    }
}
