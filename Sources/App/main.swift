import Foundation
import Hummingbird
@preconcurrency import SQLite

// Setup SQLite Database
let db = try Database.setup()

// Setup Web Server (Hummingbird)
let router = Router()

// Root Page
router.get("/") { request, _ -> HTML in
    let params = request.uri.queryParameters
    
    // Logique pour le statut (Conversion String -> Bool?)
    let statusParam = params.get("status")
    var isDone: Bool? = nil
    if statusParam == "done" { isDone = true }
    else if statusParam == "todo" { isDone = false }
    
    // Récupération des autres filtres
    let searchText = params.get("search")
    let catId = params.get("categoryId", as: Int64.self)
    
    // Appel à la base de données filtrée
    let filteredVisions = try Database.fetchFilteredVisions(
        db: db, 
        search: searchText, 
        catId: catId, 
        isDone: isDone
    )
    let allCategories = try Database.fetchAllCategories(db: db)
    
    return Views.renderIndex(items: filteredVisions, categories: allCategories)
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
    
    // Extraction des champs du formulaire
    // Pour éviter les + 
    let title = components.queryItems?.first(where: { $0.name == "title" })?.value?
        .replacingOccurrences(of: "+", with: " ") // Force le remplacement des +
        .removingPercentEncoding ?? ""
        
    let description = components.queryItems?.first(where: { $0.name == "description" })?.value?
        .replacingOccurrences(of: "+", with: " ")
        .removingPercentEncoding ?? ""

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

// Route pour voir les détails
router.get("/vision/:id") { request, context -> HTML in
    //let params = request.uri.queryParameters
    //let id = params.get("id", as: Int64.self) ?? 0
    guard let idString = context.parameters.get("id"),
          let id = Int64(idString) else {
        return HTML(content: "<h1>ID invalide</h1>")
    }
    guard let vision = try Database.fetchVisionById(db: db, idvis: id) else {
        return HTML(content: "<h1>Vision non trouvée</h1>")
    }
    let allCategories = try Database.fetchAllCategories(db: db)
    return Views.renderDetail(item: vision, categories: allCategories)
}

// Route pour supprimer (POST)
router.post("/delete/:id") { request, context -> Response in
    //let params = request.uri.queryParameters
    //let id = params.get("id", as: Int64.self) ?? 0
    guard let idString = context.parameters.get("id"),
          let id = Int64(idString) else {
        return Response(status: .badRequest)
    }
    try Database.deleteVision(db: db, idvis: id)
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

// AFFICHER le formulaire de modification
router.get("/edit/:id") { request, context -> HTML in
    guard let idString = context.parameters.get("id"), let id = Int64(idString) else {
        return HTML(content: "ID invalide")
    }
    
    guard let vision = try Database.fetchVisionById(db: db, idvis: id) else {
        return HTML(content: "Vision introuvable")
    }
    
    let allCategories = try Database.fetchAllCategories(db: db)
    return Views.renderEdit(item: vision, categories: allCategories)
}

// TRAITER la modification
router.post("/edit/:id") { request, context -> Response in
    guard let idString = context.parameters.get("id"), let id = Int64(idString) else {
        return Response(status: .badRequest)
    }

    let buffer = try await request.body.collect(upTo: 1024 * 16)
    let bodyString = String(buffer: buffer)
    var components = URLComponents()
    components.percentEncodedQuery = bodyString

    // Récupération des données 
    let title = components.queryItems?.first(where: { $0.name == "title" })?.value?.replacingOccurrences(of: "+", with: " ").removingPercentEncoding ?? ""
    let description = components.queryItems?.first(where: { $0.name == "description" })?.value?.replacingOccurrences(of: "+", with: " ").removingPercentEncoding ?? ""
    let imgUrl = components.queryItems?.first(where: { $0.name == "imgUrl" })?.value?.removingPercentEncoding ?? ""
    let budget = Double(components.queryItems?.first(where: { $0.name == "budget" })?.value ?? "0") ?? 0.0
    let catId = Int64(components.queryItems?.first(where: { $0.name == "categoryId" })?.value ?? "0") ?? 0

    let updatedVision = VisionItem(id: id, title: title, description: description, imgUrl: imgUrl, budget: budget, createdAt: Date(), categoryId: catId, isCompleted: false)

    try Database.updateVision(db: db, idvis: id, newData: updatedVision)

    // Redirection vers la page de détails pour voir le résultat
    return Response(status: .seeOther, headers: [.location: "/vision/\(id)"])
}

let app = Application(
    router: router,
    configuration: .init(address: .hostname("0.0.0.0", port: 8080))
)

print("🚀 Server started at http://localhost:8080")
try await app.runService()