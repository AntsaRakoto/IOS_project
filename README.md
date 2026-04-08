# Nom Swift App : VisionBoard Manager

VisionBoard Manager une application web CRUD (Créer, Lire, Mettre à jour, Supprimer) entièrement fonctionnelle et personnalisée. L'application est développée intégralement en Swift, en utilisant le framework web Hummingbird 2 et SQLite pour la persistance des données, et s'exécute dans l'environnement GitHub Codespaces. 

Le projet aborde la gestion des requêtes HTTP de base, la modélisation des données et la création d'interfaces utilisateur web.

---
## 1. Desccription 
VisionBoard Manager est une application web permettant de créer, visualiser et gérer des visions (objectifs, rêves ou inspirations).

L’utilisateur peut ajouter des éléments avec son titre, une image URL, sa description, sa catégorie, son budget et son statut, sa date de création sera automatiquement enregistré. L'utilisateur peut les modifier ou les supprimer afin de construire son propre tableau de visualisation. 

Il peut également rechercher un élément par son titre ou sa description et filtrer les éléments par catégorie et statut.

---

## 3. Fonctionnement
L’utilisateur accède à une interface web

Il peut :
- Ajouter une vision (titre, description, image)
- Voir toutes les visions
- Rechercher une vision
- Filtrer par catégorie et statut 
- Voir les détails de chaque vision
- Modifier une vision existante
- Supprimer une vision
- Mettre à jour le statut d'une vision si elle est complétée ou pas encore

Les données sont stockées dans une base de donnée SQLite

---

## 4. Routes exposées

| Méthode | Route                 | Description                                       |
| ------- | --------------------- | ------------------------------------------------- |
| GET     | `/`                   | Affiche la page d’accueil avec toutes les visions |
| GET     | `/add`                | Affiche le formulaire de création                 |
| POST    | `/add`                | Crée une nouvelle vision                          |
| GET     | `/vision/:id`         | Affiche le détail d'une vision spécifique         |
| POST    | `/delete/:id`         | Supprime une vision          |
| POST    | `/toggle/:id`         | Met à jour le statut d'une vision                 |
| GET     | `/edit/:id`           | Affiche le formulaire de modification             |
| POST    | `/edit/:id`           | Modifie une vision           |

---
## 5. Exécution du projet

1. Opening in GitHub Codespaces : Click the green **"Code"** button in this repository, select the **"Codespaces"** tab and click **"VisionBoard Manager"**.
2. Build & Run : Open the integrated terminal and run:

```bash
./build.sh
```

This resolves dependencies and compiles the project. When it finishes, start the server:

```bash
./run.sh
```

Codespaces will detect that port **8080** is now in use and show a pop-up — click **"Open in Browser"** (or find it under the **Ports** tab). You should see the Task List app running live.

> To stop the server press `Ctrl + C` in the terminal.
---



## 4. Project Structure

```
.devcontainer/
  devcontainer.json     # Codespaces container config (Swift 6.2, VS Code extensions, port forwarding)
Sources/App/
  main.swift            # Entry point — server setup and HTTP route definitions
  Models.swift          # Data model: the TaskItem struct
  Database.swift        # SQLite setup and all database queries
  Views.swift           # HTML page rendering (returns pages to the browser)
Package.swift           # Swift package definition — dependencies and build targets
build.sh                # Helper script: resolve + compile
run.sh                  # Helper script: start the server
```

---

## 5. How It Works

```
Browser  →  HTTP Request
             ↓
         main.swift  (Hummingbird router matches the route)
             ↓
         Database.swift  (SQLite.swift reads/writes db.sqlite3)
             ↓
         Views.swift  (builds an HTML string from the data)
             ↓
         HTTP Response  →  Browser renders the page
```

| Layer | File | Technology |
|---|---|---|
| Web server & routing | `main.swift` | [Hummingbird 2](https://github.com/hummingbird-project/hummingbird) |
| Data model | `Models.swift` | Swift `struct` |
| Database | `Database.swift` | [SQLite.swift](https://github.com/stephencelis/SQLite.swift) |
| UI / HTML | `Views.swift` | [Pico CSS](https://picocss.com) |

---

## 6. Assignment

Your job is to extend this template into your own app. Here are the four files you will work in and what to change:

### `Models.swift` — Define your data
Replace or extend `TaskItem` with a struct that represents the data your app works with.
```swift
struct TaskItem: Codable, Sendable {
    let id: Int64?
    var title: String
    var isCompleted: Bool
    // Add your own fields here, e.g.:
    // var dueDate: String
    // var priority: Int
}
```

### `Database.swift` — Read and write data
Update the SQLite table columns to match your model, and add functions for any new queries your app needs (e.g. filtering, deleting, updating fields).

### `Views.swift` — Change the UI
Modify `renderIndex(items:)` to display your data the way you want. You can add new `render...()` functions for additional pages.

### `main.swift` — Add routes
Register new routes to handle new pages or actions. Follow the existing pattern:


---

## 7. Key Swift Concepts in This Project

| Concept | Where to see it |
|---|---|
| `struct` | `Models.swift`, `Database.swift`, `Views.swift` |
| `async/await` | `main.swift` — `app.runService()`, request handlers |
| Closures | `main.swift` — route handler blocks `{ request, context in ... }` |
| Protocol conformance | `Views.swift` — `HTML: ResponseGenerator` |
| `throws` / `try` | `Database.swift` — all database calls |
| Extensions | `Database.swift` — `Connection: @unchecked Sendable` |
