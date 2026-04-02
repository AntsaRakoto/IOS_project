import Foundation
import Hummingbird
@preconcurrency import SQLite

// Setup SQLite Database
let db = try Database.setup()

// Setup Web Server (Hummingbird)
let router = Router()

// Root Page
router.get("/") { _, _ -> HTML in
    // On récupère les deux listes depuis la Database
    let allVisions = try Database.fetchAllVisions(db: db)
    let allCategories = try Database.fetchAllCategories(db: db)
    
    return Views.renderIndex(items: allVisions, categories: allCategories)
}

// PAGE FORMULAIRE : Affiche la page de création seule
router.get("/add") { _, _ -> HTML in
    let allCategories = try Database.fetchAllCategories(db: db)
    return Views.renderAddForm(categories: allCategories)
}

router.post("/add") { request, _ -> Response in
    let buffer = try await request.body.collect(upTo: 1024 * 16)
    let bodyString = String(buffer: buffer)
    
    var components = URLComponents()
    components.percentEncodedQuery = bodyString
    
    // Extraction (identique à avant)
    let title = components.queryItems?.first(where: { $0.name == "title" })?.value ?? ""
    let description = components.queryItems?.first(where: { $0.name == "description" })?.value ?? ""
    let imgUrl = components.queryItems?.first(where: { $0.name == "imgUrl" })?.value ?? ""
    let budgetString = components.queryItems?.first(where: { $0.name == "budget" })?.value ?? "0"
    let categoryString = components.queryItems?.first(where: { $0.name == "categoryId" })?.value ?? ""

    guard !title.isEmpty else { return Response(status: .badRequest) }

    let newVision = VisionItem(
        id: nil,
        title: title,
        description: description,
        imgUrl: imgUrl,
        budget: Double(budgetString) ?? 0.0,
        createdAt: Date(),
        categoryId: Int64(categoryString),
        isCompleted: false
    )

    try Database.addVision(db: db, vision: newVision)

    // Redirection vers l'accueil ("/") après l'ajout
    return Response(status: .seeOther, headers: [.location: "/"])
}

// API: Toggle Task
router.post("/toggle/:id") { _, context -> Response in
    guard let idStr = context.parameters.get("id"), let targetId = Int64(idStr) else {
        return Response(status: .badRequest)
    }
    try Database.toggleVision(db: db, id: targetId)
    return Response(status: .seeOther, headers: [.location: "/"])
}

let app = Application(
    router: router,
    configuration: .init(address: .hostname("0.0.0.0", port: 8080))
)

print("🚀 Server started at http://localhost:8080")
try await app.runService()