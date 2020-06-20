//
//  File.swift
//  
//
//  Created by Marcel Borsten on 20/06/2020.
//

import Vapor

public struct RecommendConfig {

    public enum Scheme: String {
        case http = "http"
        case https = "https"
    }

    ///
    let scheme: Scheme = .http

    ///
    let host = "0.0.0.0"

    ///
    let port = 5050

}

struct RecommendConfigKey: StorageKey {
    public typealias Value = RecommendConfig
}
