//
//  File.swift
//  
//
//  Created by Marcel Borsten on 20/06/2020.
//

import Fluent
import Vapor

public protocol RecommendableModel: Fluent.Model {
    static func recommended(req: Request, userId: UUID) -> EventLoopFuture<[Self]>
    static func popular(req: Request, number: Int) -> EventLoopFuture<[Self]>
}

extension RecommendableModel where IDValue == UUID {

    /// Fetches a list of items recommended based on the given userId.
    /// - Parameters:
    ///   - req: The request
    ///   - userId: The userId
    /// - Returns: EventloopFuture with the resuls.
    public static func recommended(req: Request, userId: UUID) -> EventLoopFuture<[Self]> {

        return req.recommend.recommendedIdsFor(userId: userId.uuidString).flatMap { recommendedIds in

            let uuids = recommendedIds.compactMap(UUID.init(uuidString:))

            return Self.query(on: req.db)
                .filter(\Self._$id ~~ uuids)
                .all()

        }
    }

    /// Fetches a list of popular items
    /// - Parameters:
    ///   - req: The request
    ///   - number: The maximum number of items in the response
    /// - Returns: EventLoopFuture with the results
    static func popular(req: Request, number: Int = 10) -> EventLoopFuture<[Self]> {

        return req.recommend.popularIds(number: number).flatMap { popularIds in

            let uuids = popularIds.compactMap(UUID.init(uuidString:))

            return Self.query(on: req.db)
                .filter(\Self._$id ~~ uuids)
                .all()

        }

    }

}
