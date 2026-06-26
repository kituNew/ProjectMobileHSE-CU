import Foundation
@testable import LectureHSE1

func makeTestNews(
    title: String = "Beer story",
    url: String? = "https://example.com/news",
    publishedDate: Date = Date(timeIntervalSince1970: 1)
) -> New {
    New(
        section: "Food",
        subsection: "Drinks",
        title: title,
        abstract: "Abstract",
        byline: "Byline",
        source: "NYT",
        url: url,
        updatedDate: publishedDate,
        createdDate: publishedDate,
        publishedDate: publishedDate,
        relatedUrls: url.map {
            [RelatedUrl(suggestedLinkText: title, url: $0)]
        },
        multimedia: [
            Multimedia(
                url: "https://example.com/image.jpg",
                height: 300,
                width: 500,
                caption: "Caption"
            )
        ]
    )
}

func makeTestNote(
    id: String = "note-1",
    title: String = "Title",
    text: String = "Text",
    updatedAt: Date = Date(timeIntervalSince1970: 1)
) -> Note {
    Note(
        id: id,
        title: title,
        text: text,
        updatedAt: updatedAt
    )
}

func makeTestReminder(
    id: String = "reminder-1",
    text: String = "Reminder",
    description: String = "Description",
    priority: Priority = .medium,
    flag: Bool = false,
    toDate: Date? = nil,
    isDone: Bool = false
) -> Reminder {
    Reminder(
        id: id,
        text: text,
        description: description,
        priority: priority,
        flag: flag,
        toDate: toDate,
        isDone: isDone
    )
}

enum TestError: Error, LocalizedError {
    case expected

    var errorDescription: String? {
        "Expected test error"
    }
}
