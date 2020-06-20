//
//  File.swift
//  
//
//  Created by Marcel Borsten on 20/06/2020.
//

import Vapor

extension Application {

    public var recommendConfig: RecommendConfig? {
        get {
            self.storage[RecommendConfigKey.self]
        }
        set {
            self.storage[RecommendConfigKey.self] = newValue
        }
    }

}

extension Request {

    public var recommend: Recommend {
        .init(request: self, config: application.storage[RecommendConfigKey.self] ?? RecommendConfig())
    }

}
