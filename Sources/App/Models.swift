import Foundation

struct VisionItem: Codable, Sendable {
    let id: Int64?
    var title: String
    var description: String
    var imgUrl: String
    var budget: Double
    var createdAt: Date
    var categoryId: Int64?
    var isCompleted: Bool
}

struct CategoryItem: Codable, Sendable {
    let id: Int64?
    var name: String
}