//
//  AuthService.swift
//  Blendery
//
//  Created by 박성준 on 12/24/25.
//

import Foundation

// ✅ 로그인 전용 에러 (한국어 메시지 제공)
enum AuthError: LocalizedError {
    case invalidURL
    case noHTTPResponse
    case server(statusCode: Int, body: String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "로그인 주소가 올바르지 않습니다."
        case .noHTTPResponse:
            return "서버 응답을 받을 수 없습니다."
        case let .server(statusCode, body):
            switch statusCode {
            case 401:
                return "아이디 또는 비밀번호가 올바르지 않습니다."
            case 403:
                return "접근 권한이 없습니다."
            case 404:
                return "로그인 API를 찾을 수 없습니다."
            case 500...599:
                return "서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요."
            default:
                let trimmed = body.trimmingCharacters(in: .whitespacesAndNewlines)
                return trimmed.isEmpty
                ? "로그인에 실패했습니다. (코드: \(statusCode))"
                : "로그인에 실패했습니다. (코드: \(statusCode))\n\(trimmed)"
            }
        }
    }
}

final class AuthService {

    // ✅ 프로젝트에서 이미 쓰는 BaseURL 재사용
    private let baseURL = BaseURL.baseUrl.rawValue

    func login(request: LoginRequest) async throws -> String {

        // ✅ baseURL 끝에 / 붙어도 안전하게 처리
        let base = baseURL.hasSuffix("/") ? String(baseURL.dropLast()) : baseURL

        // ❗️서버 로그인 경로가 다르면 여기만 바꾸면 됨
        // 예: "\(base)/api/login" or "\(base)/api/auth/login"
        guard let url = URL(string: "\(base)/api/auth/login") else {
            throw AuthError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept") // ✅ 추가(서버에 따라 필요)

        let bodyData = try JSONEncoder().encode(request)
        urlRequest.httpBody = bodyData

        // ✅ 디버그: 실제로 어디로 무엇을 보내는지 확인
        print("➡️ LOGIN URL:", url.absoluteString)
        print("➡️ LOGIN BODY:", String(data: bodyData, encoding: .utf8) ?? "nil")

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let http = response as? HTTPURLResponse else {
            throw AuthError.noHTTPResponse
        }

        let raw = String(data: data, encoding: .utf8) ?? ""
        print("📡 login statusCode:", http.statusCode)
        print("📦 login raw:", raw)

        guard (200...299).contains(http.statusCode) else {
            throw AuthError.server(statusCode: http.statusCode, body: raw)
        }

        // ✅ 응답 JSON에 role이 있어도, LoginResponse가 accessToken만 갖고 있으면 정상 디코딩됨
        let decoded = try JSONDecoder().decode(LoginResponse.self, from: data)
        return decoded.accessToken
    }
}
