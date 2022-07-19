//
//  Data.swift
//  LINE Fintech
//

import Foundation

protocol NetworkResponse {
    var statusCode: Int { get }
}

struct QRData: Codable, NetworkResponse {
    let statusCode: Int
    let qrString: String
}

struct CardData: Codable, NetworkResponse {
    let statusCode: Int
    let cardList: [Card]

    struct Card: Codable {
        let id: String
        let imgPath: String
        let name: String
    }
}
