//
//  BlenderyAPI.swift
//  Blendery
//
//  Created by 박성준 on 12/31/25.
//

import Foundation

// MARK: - API Error
enum APIError: Error {
    case unauthorized        // 401
    case forbidden           // 403
    case badStatus(Int)      // 기타 상태코드
    case invalidResponse
}

// MARK: - BlenderyAPI
final class BlenderyAPI {

    static let shared = BlenderyAPI()

    // baseURL은 루트만
    let baseURL: URL = {
        guard let url = URL(string: BaseURL.baseUrl.rawValue) else {
            fatalError("❌ Invalid BaseURL: \(BaseURL.baseUrl.rawValue)")
        }
        return url
    }()

    private init() {}

    // MARK: - Response Validation
    func validate(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch http.statusCode {
        case 200..<300:
            return
        case 401:
            throw APIError.unauthorized
        case 403:
            throw APIError.forbidden
        default:
            throw APIError.badStatus(http.statusCode)
        }
    }

    // MARK: - Generic Request
    func request<T: Decodable>(
        _ request: URLRequest,
        type: T.Type
    ) async throws -> T {

        let (data, response) = try await URLSession.shared.data(for: request)

        // 🔎 Debug Log
        if let http = response as? HTTPURLResponse {
            print("📡 statusCode:", http.statusCode)
            print("📦 headers:", request.allHTTPHeaderFields ?? [:])
            print("📦 raw:", String(data: data, encoding: .utf8) ?? "nil")
        }

        try validate(response)

        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}

// MARK: - Authorized Request Builder
extension BlenderyAPI {

    func makeAuthorizedRequest(
        url: URL,
        method: String = "GET"
    ) -> URLRequest {

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = TokenStore.loadAccessToken() {
            request.setValue(
                "Bearer \(token)",
                forHTTPHeaderField: "Authorization"
            )
        }

        return request
    }
    
    func fetchRecipeDetail(recipeId: UUID) async throws -> RecipeModel {

            let endpoint = baseURL
                .appendingPathComponent("api/recipe")
                .appendingPathComponent(recipeId.uuidString)

            let request = makeAuthorizedRequest(url: endpoint)

            return try await self.request(
                request,
                type: RecipeModel.self
            )
        }

}

extension BlenderyAPI {

    func searchRecipes(
        keyword: String
    ) async throws -> [SearchRecipeModel] {

        let endpoint = baseURL
            .appendingPathComponent("api/recipe/search/recipes")

        guard var components = URLComponents(
            url: endpoint,
            resolvingAgainstBaseURL: false
        ) else {
            throw URLError(.badURL)
        }

        components.queryItems = [
            URLQueryItem(name: "keyword", value: keyword)
        ]

        let url = components.url!
        let request = makeAuthorizedRequest(url: url)

        return try await self.request(
            request,
            type: [SearchRecipeModel].self
        )
    }
}

extension BlenderyAPI {

    /// franchiseId / category / favorite 조건으로 레시피 검색
    func searchRecipes(
        franchiseId: String,
        category: String? = nil,
        favorite: Bool? = nil
    ) async throws -> [RecipeModel] {

        let endpoint = baseURL.appendingPathComponent("api/recipe/search/recipes")

        guard var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false) else {
            throw URLError(.badURL)
        }

        var items: [URLQueryItem] = [
            URLQueryItem(name: "franchiseId", value: franchiseId)
        ]

        if let category, !category.isEmpty {
            items.append(URLQueryItem(name: "category", value: category))
        }

        if let favorite {
            items.append(URLQueryItem(name: "favorite", value: favorite ? "true" : "false"))
        }

        components.queryItems = items

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        let request = makeAuthorizedRequest(url: url)

        return try await self.request(
            request,
            type: [RecipeModel].self
        )
    }
}
