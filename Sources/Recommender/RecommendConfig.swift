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

    /// The scheme that should be used for the gorse service.
    /// Default is `http`
    let scheme: Scheme = .http

    /// The hostname of the gorse service. This can be a hostname
    /// or ip address. Default is "0.0.0.0"
    let host = "0.0.0.0"

    /// The port that should be used for the gorse service. Default
    /// is 5050
    let port = 5050

}

struct RecommendConfigKey: StorageKey {
    public typealias Value = RecommendConfig
}
