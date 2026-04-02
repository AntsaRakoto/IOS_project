import Hummingbird
import Foundation

struct Views {
    // --- PAGE D'ACCUEIL ---
    static func renderIndex(items: [VisionItem], categories: [CategoryItem]) -> HTML {
        let content = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css">
            <title>VisionBoard</title>
            <style>
                /* Force la grille à avoir maximum 4 colonnes sur grand écran */
                .grid-visions {
                    display: grid;
                    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                    gap: 1rem;
                }
            </style>
        </head>
            <body class="container">
            <header style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem;">
                <h1 style="margin: 0;">Mes Visions</h1>
                <a href="/add" role="button" class="contrast"> ＋ Nouvelle Vision</a>
            </header>

            <div class="grid-visions">
                \(items.map { renderCard(item: $0, categories: categories) }.joined())
            </div>
            </body>
        </html>
        """
        return HTML(content: content)
    }

    // --- COMPOSANT CARTE (L'unité de base) ---
    private static func renderCard(item: VisionItem, categories: [CategoryItem]) -> String {
        let statusEmoji = item.isCompleted ? "✅" : "⭕️"
        let category = categories.first(where: { $0.id == item.categoryId })
        let categoryName = category?.name ?? "Général"
        return """
        <article style="display: flex; flex-direction: column; justify-content: space-between;">
            <header style="padding: 0.5rem 1rem;">
                <div style="display: flex; justify-content: space-between; align-items: start;">
                    <h5 style="margin: 0;">\(item.title)</h5>
                    <span>\(statusEmoji)</span>
                    <mark style="font-size: 0.7rem;"> \(categoryName)</mark>
                </div>
            </header>

            \(item.imgUrl.isEmpty ? "" : "<img src='\(item.imgUrl)' style='width: 100%; height: 150px; object-fit: cover; border-radius: 4px;'>")

            <div style="padding: 1rem 0;">
                <p style="font-size: 0.9rem; color: var(--pico-muted-color);">\(item.description)</p>
                <small>Budget: <strong>\(item.budget)€</strong></small>
            </div>

            <footer style="margin-top: auto; padding: 0.5rem 1rem;">
                <form action="/toggle/\(item.id ?? 0)" method="post" style="margin: 0;">
                    <button type="submit" class="outline secondary p-2" style="font-size: 0.7rem;">
                        \(item.isCompleted ? "Réouvrir" : "Compléter")
                    </button>
                </form>
            </footer>
        </article>
        """
    }

    // --- PAGE DU FORMULAIRE ---
    static func renderAddForm(categories: [CategoryItem]) -> HTML {
        let content = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css">
            <title>VisionBoard</title>
        </head>
            <body class="container">
                <article>
                    <header>
                        <a href="/" style="float: right;">Fermer ✕</a>
                        <h3>Nouvelle Vision</h3>
                    </header>
                    <form action="/add" method="post">
                        <label>Titre
                            <input type="text" name="title" placeholder="Mon prochain rêve..." required>
                        </label>
                        
                        <div class="grid">
                            <label>Catégorie
                                <select name="categoryId">
                                    <option value="">Général</option>
                                    \(categories.map { "<option value='\($0.id ?? 0)'>\($0.name)</option>" }.joined())
                                </select>
                            </label>
                            <label>Budget (€)
                                <input type="number" name="budget" step="0.01" value="0">
                            </label>
                        </div>

                        <label>Image (URL)
                            <input type="url" name="imgUrl" placeholder="https://...">
                        </label>

                        <label>Description
                            <textarea name="description" rows="3"></textarea>
                        </label>

                        <button type="submit">Enregistrer dans ma liste</button>
                    </form>
                </article>
            </body>
        </html>
        """
        return HTML(content: content)
    }
}

// Allows Hummingbird to return HTML strings
struct HTML: ResponseGenerator {
    let content: String
    func response(from request: Request, context: some RequestContext) throws -> Response {
        return Response(
            status: .ok,
            headers: [.contentType: "text/html"],
            body: .init(byteBuffer: .init(string: content))
        )
    }
}