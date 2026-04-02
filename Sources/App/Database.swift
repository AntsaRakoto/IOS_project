import SQLite
import Foundation

// Connection uses an internal serial queue, so it is safe to mark Sendable.
extension Connection: @unchecked @retroactive Sendable {}

struct Database {
    // Définition de la table des catégories
    static let categories = Table("categories")
    static let catId = Expression<Int64>("id")
    static let catName = Expression<String>("name")

    // Definition de la table des visions
    static let visions = Table("visions")
    static let id = Expression<Int64>("id")
    static let title = Expression<String>("title")
    static let description = Expression<String>("description")
    static let imgUrl = Expression<String>("img_url")
    static let budget = Expression<Double>("budget")
    static let createdAt = Expression<Date>("created_at")
    static let categoryId = Expression<Int64?>("category_id")
    static let isCompleted = Expression<Bool>("is_completed")

    static func setup() throws -> Connection {
        let db = try Connection("db.sqlite3")

        // Création de la table des catégories
        try db.run(categories.create(ifNotExists: true) { t in
            t.column(catId, primaryKey: .autoincrement)
            t.column(catName, unique: true)
        })

        // Insérer des catégories initiales si la table est vide
        let count = try db.scalar(categories.count)
        if count == 0 {
            let initialCategories = ["Voyage", "Finances", "Santé", "Travail", "Loisirs"]
            for name in initialCategories {
                try db.run(categories.insert(catName <- name))
            }
        }

        try db.run(visions.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(title)
            t.column(description)
            t.column(imgUrl)
            t.column(budget)
            t.column(createdAt)
            t.column(categoryId, references: categories, catId)
            t.column(isCompleted, defaultValue: false)
        })

        return db
    }

    static func fetchAllVisions(db: Connection) throws -> [VisionItem] {
        return try db.prepare(visions).map { row in
            VisionItem(
                id: row[id],
                title: row[title],
                description: row[description],
                imgUrl: row[imgUrl],
                budget: row[budget],
                createdAt: row[createdAt],
                categoryId: row[categoryId],
                isCompleted: row[isCompleted]
            )
        }
    }

    static func fetchAllCategories(db: Connection) throws -> [CategoryItem] {
        return try db.prepare(categories).map { row in
            CategoryItem(
                id: row[catId],
                name: row[catName]
            )
        }
    }

    static func addVision(db: Connection, vision: VisionItem) throws {
        try db.run(visions.insert(
            title <- vision.title,
            description <- vision.description,
            imgUrl <- vision.imgUrl,
            budget <- vision.budget,
            createdAt <- vision.createdAt,
            categoryId <- vision.categoryId,
            isCompleted <- vision.isCompleted
        ))
    }

    static func toggleVision(db: Connection, id targetId: Int64) throws {
        let vision = visions.filter(id == targetId)
        // Find current state to flip it
        if let current = try db.pluck(vision) {
            try db.run(vision.update(isCompleted <- !current[isCompleted]))
        }
    }
}