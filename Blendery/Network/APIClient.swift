//
//  APIClient.swift
//  Blendery
//
//  Created by 박영언 on 12/29/25.
//

import Foundation

final class APIClient {

    static let shared = APIClient()
    private init() {}

    private let baseURL = BaseURL.baseUrl.rawValue

    func fetchRecipeDetail(recipeId: UUID) async throws -> RecipeModel {
        let url = URL(string: "\(baseURL)/api/recipe/\(recipeId.uuidString)")!

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode)
        else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(RecipeModel.self, from: data)
    }
    
    func fetchRecipes(
        franchiseId: String,
        category: String? = nil,
        favorite: Bool? = nil
    ) async throws -> [RecipeModel] {

        var components = URLComponents(string: "\(baseURL)/api/recipe/recipes")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "franchiseId", value: franchiseId)
        ]

        if let category {
            queryItems.append(
                URLQueryItem(name: "category", value: category)
            )
        }

        if let favorite {
            queryItems.append(
                URLQueryItem(name: "favorite", value: String(favorite))
            )
        }

        components.queryItems = queryItems

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let http = response as? HTTPURLResponse {
            print("📡 statusCode:", http.statusCode)
        }

        print("📦 raw response:", String(data: data, encoding: .utf8) ?? "nil")

        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode)
        else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode([RecipeModel].self, from: data)
    }
}
