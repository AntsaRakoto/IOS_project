import Hummingbird
import Foundation

struct Views {
    // PAGE D'ACCUEIL 
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

            \(renderFilters(categories: categories))

            <div class="grid-visions">
            \(items.isEmpty ? "<p>Aucune vision trouvée... </p>" : items.map { renderCard(item: $0, categories: categories) }.joined())
        </div>
            </body>
        </html>
        """
        return HTML(content: content)
    }

    // COMPOSANT CARTE pour chaque vision
    private static func renderCard(item: VisionItem, categories: [CategoryItem]) -> String {
        let categoryName = categories.first(where: { $0.id == item.categoryId })?.name ?? "Général"
        
        return """
        <article style="display: flex; flex-direction: column; height: 100%;">
            <header style="padding: 0.5rem;">
                <div style="display: flex; justify-content: space-between; align-items: center;">
                    <mark style="font-size: 0.6rem;">\(categoryName)</mark>
                    <a href="/vision/\(item.id ?? 0)" style="font-size: 0.7rem; text-decoration: none;">Détails</a>
                </div>
                <h6 style="margin: 0.5rem 0 0 0;">\(item.title)</h6>
            </header>

            <div style="flex-grow: 1; padding: 0.5rem;">
                \(item.imgUrl.isEmpty ? "" : "<img src='\(item.imgUrl)' style='width: 100%; height: 100px; object-fit: cover; border-radius: 4px;'>")
            </div>

            <footer style="padding: 0.5rem; display: flex; gap: 0.5rem; justify-content: center;">
                <form action="/toggle/\(item.id ?? 0)" method="post" style="margin: 0;">
                    <button type="submit" class="outline \(item.isCompleted ? "secondary" : "primary")" 
                            style="font-size: 0.6rem; padding: 0.2rem 0.5rem; margin: 0;">
                        \(item.isCompleted ? "Réouvrir" : "Fait")
                    </button>
                </form>
                
                <form action="/delete/\(item.id ?? 0)" method="post" style="margin: 0;" onsubmit="return confirm('Supprimer cette vision ?');">
                    <button type="submit" class="outline contrast" 
                            style="font-size: 0.6rem; padding: 0.2rem 0.5rem; margin: 0; color: #d32f2f; border-color: #d32f2f;">
                        Supprimer
                    </button>
                </form>
            </footer>
        </article>
        """
    }

    // Composant du formulaire de filtre (sur la page d'accueil)
    static func renderFilters(categories: [CategoryItem]) -> String {
        return """
        <article style="padding: 1rem; margin-bottom: 2rem;">
            <form method="get" action="/" style="display: grid; grid-template-columns: 2fr 1fr 1fr auto; gap: 1rem; margin: 0; align-items: end;">
                <label>Recherche
                    <input type="search" name="search" placeholder="Titre ou description...">
                </label>
                
                <label>Catégorie
                    <select name="categoryId">
                        <option value="">Toutes</option>
                        \(categories.map { "<option value='\($0.id ?? 0)'>\($0.name)</option>" }.joined())
                    </select>
                </label>

                <label>Statut
                    <select name="status">
                        <option value="all">Tout</option>
                        <option value="todo">À faire</option>
                        <option value="done">Terminé</option>
                    </select>
                </label>

                <button type="submit" class="outline">Filtrer</button>
            </form>
        </article>
        """
    }

    // PAGE DU FORMULAIRE
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

    // PAGE DE DÉTAIL
    static func renderDetail(item: VisionItem, categories: [CategoryItem]) -> HTML {
        let categoryName = categories.first(where: { $0.id == item.categoryId })?.name ?? "Général"
        
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
                <nav aria-label="breadcrumb">
                <ul>
                    <li><a href="/">Accueil</a></li>
                    <li>Détails de la vision</li>
                </ul>
                </nav>

                <article>
                    <div class="grid">
                        <div>
                            \(item.imgUrl.isEmpty ? "<div>Pas d'image</div>" : "<img src='\(item.imgUrl)' style='width: 100%; border-radius: 8px;'>")
                        </div>
                        <div>
                            <hgroup>
                                <h1>\(item.title)</h1>
                                <p>Catégorie : <strong>\(categoryName)</strong> | Statut : \(item.isCompleted ? "Terminé" : "En cours")</p>
                            </hgroup>
                            
                            <p><strong>Description :</strong><br>\(item.description)</p>
                            <p><strong>Budget prévu :</strong> \(item.budget) €</p>
                            <p><small>Créé le : \(item.createdAt)</small></p>

                            <hr>
                            <a href="/edit/\(item.id ?? 0)" role="button" class="secondary">Modifier cette vision</a>
                        </div>
                    </div>
                </article>
            </body>
        </html>
        """
        return HTML(content: content)
    }

    static func renderEdit(item: VisionItem, categories: [CategoryItem]) -> HTML {
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
                <nav aria-label="breadcrumb">
                <ul>
                    <li><a href="/">Accueil</a></li>
                    <li><a href="/vision/\(item.id ?? 0)">Détails</a></li>
                    <li>Modifier</li>
                </ul>
                </nav>

                <article>
                    <h2>Modifier la vision : </h2>
                    <form action="/edit/\(item.id ?? 0)" method="post">
                        <label>Titre
                            <input type="text" name="title" value="\(item.title)" required>
                        </label>

                        <label>Description
                            <textarea name="description" required>\(item.description)</textarea>
                        </label>

                        <label>URL de l'image
                            <input type="url" name="imgUrl" value="\(item.imgUrl)">
                        </label>

                        <div class="grid">
                            <label>Budget (€)
                                <input type="number" name="budget" value="\(item.budget)" step="0.01">
                            </label>

                            <label>Catégorie
                                <select name="categoryId">
                                    \(categories.map { cat in
                                        let selected = (cat.id == item.categoryId) ? "selected" : ""
                                        return "<option value='\(cat.id ?? 0)' \(selected)>\(cat.name)</option>"
                                    }.joined())
                                </select>
                            </label>
                        </div>

                        <button type="submit">Enregistrer les modifications</button>
                        <a href="/vision/\(item.id ?? 0)" class="secondary outline" role="button">Annuler</a>
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