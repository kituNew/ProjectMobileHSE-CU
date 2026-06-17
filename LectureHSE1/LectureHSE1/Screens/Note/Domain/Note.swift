import Foundation

struct Note: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var text: String
    var updatedAt: Date

    init(
        id: String = UUID().uuidString,
        title: String,
        text: String,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.text = text
        self.updatedAt = updatedAt
    }
}
