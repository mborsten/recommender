//
//  File.swift
//  
//
//  Created by Marcel Borsten on 19/06/2020.
//

import Vapor
import Fluent

private extension DateFormatter {
    static var recommendFeedback: DateFormatter {
        let d = DateFormatter()
        d.dateFormat = "yyyy-MM-dd"
        return d
    }
}

private extension Date {
    var feedbackDateString: String { DateFormatter.recommendFeedback.string(from: self) }
}

public struct Recommend {

    unowned var request: Request

    var config: RecommendConfig = RecommendConfig()

    private struct Feedback: Content {

        let userId: String
        let itemId: String
        let rating: Int

        enum CodingKeys: String, CodingKey {
            case userId = "UserId"
            case itemId = "ItemId"
            case rating = "Rating"
        }
    }

    private struct InsertItem: Content {

        let id: String
        let timeStamp: String = Date().feedbackDateString

        enum CodingKeys: String, CodingKey {
            case id = "ItemId"
            case timeStamp = "TimeStamp"
        }
    }


    private struct Response: Codable {

        let itemsBefore: Int
        let itemsAfter: Int
        let usersBefore: Int
        let usersAfter: Int
        let feedbackBefore: Int
        let feedbackAfter: Int

        enum CodingKeys: String, CodingKey {
            case itemsBefore = "ItemsBefore"
            case itemsAfter = "ItemsAfter"
            case usersBefore = "UsersBefore"
            case usersAfter = "UsersAfter"
            case feedbackBefore = "FeedbackBefore"
            case feedbackAfter = "FeedbackAfter"
        }

        var logMessage: String {
            "Items: \(itemsBefore) / \(itemsAfter) || Users: \(usersBefore) / \(usersAfter) || feedback: \(feedbackBefore) / \(feedbackAfter)"
        }
    }

    private var uri: URI {
        URI(scheme: config.scheme.rawValue, host: config.host, port: config.port, path: "/", query: nil, fragment: nil)
    }

    private var insertItemURI: URI {
        var uri = self.uri
        uri.path = "/items"
        return uri
    }

    private var insertFeedbackURI: URI {
        var uri = self.uri
        uri.path = "/feedback"
        return uri
    }

    private func recommendedURI(userId: String) -> URI {
        var uri = self.uri
        uri.path = "/recommends/\(userId)/"
        uri.query = "number=10&p=0.5&t=0.5&c=1"
        return uri
    }

    private func popularURI(number: Int) -> URI {
        var uri = self.uri
        uri.path = "/popular"
        uri.query = "number=\(number)"
        return uri
    }

}

extension Recommend {

    private struct Item: Content {

        let id: String
        let popularity: Double
        let score: Double

        enum CodingKeys: String, CodingKey {
            case id = "ItemId"
            case popularity = "Popularity"
            case score = "Score"
        }
    }

    public func insertItem(id: String) -> EventLoopFuture<Void> {
        return request.client.put(insertItemURI) { req in
            try req.content.encode([InsertItem(id: id)])
        }.flatMapThrowing { res in
            return try res.content.decode(Response.self)
        }.map { res in
            self.request.logger.info("\(res.logMessage)")
        }.transform(to:())
    }

    public func insertFeedback(userId: String, itemId: String, rating: Int) -> EventLoopFuture<Void> {
        return request.client.put(insertFeedbackURI) { req in
            try req.content.encode([Feedback(userId: userId, itemId: itemId, rating: rating)])
        }.flatMapThrowing { res -> Response? in
            do {
                return try self.request.content.decode(Response.self)
            } catch {
                return nil
            }
        }.map { res in
            if let res = res {
                self.request.logger.debug("\(res.logMessage)")
            }
        }
        .transform(to: ())
    }

    func recommendedIdsFor(userId: String) -> EventLoopFuture<[String]> {
        return getIds(forURI: recommendedURI(userId: userId))
    }

    func popularIds(number: Int) -> EventLoopFuture<[String]> {
        return getIds(forURI: popularURI(number: number))
    }

    private func getIds(forURI uri: URI) -> EventLoopFuture<[String]> {
        return request
            .client
            .get(uri)
            .flatMapThrowing { res -> [Recommend.Item] in
                return try res.content.decode([Item].self)
        }.map { items in
            items.map{ $0.id }
        }
    }

}
