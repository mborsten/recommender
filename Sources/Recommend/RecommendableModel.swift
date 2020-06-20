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
}

extension RecommendableModel where IDValue == UUID {

    public static func recommended(req: Request, userId: UUID) -> EventLoopFuture<[Self]> {

        return req.recommend.recommendedIdsFor(userId: userId.uuidString).flatMap { recommendedIds in

            let uuids = recommendedIds.compactMap(UUID.init(uuidString:))

            return Self.query(on: req.db)
                .filter(\Self._$id ~~ uuids)
                .all()

        }
    }

}
