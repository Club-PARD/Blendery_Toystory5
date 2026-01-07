import Security
import Foundation

struct TokenStore {
    private static let service = "Blendery"
    private static let account = "accessToken"
    // 저장
    static func saveAccessToken(_ token: String) {
        let data = Data(token.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        // 기존 토큰 있으면 삭제
        SecItemDelete(query as CFDictionary)
        
        let attributes: [String: Any] = query.merging([
            kSecValueData as String: data
        ]) { $1 }
        
        SecItemAdd(attributes as CFDictionary, nil)
    }
    // 불러오기
    static func loadAccessToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard
            status == errSecSuccess,
            let data = item as? Data
        else {
            return nil
        }
        
        return String(decoding: data, as: UTF8.self)
    }
    
    // 로그아웃 대비
    static func clear() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}
