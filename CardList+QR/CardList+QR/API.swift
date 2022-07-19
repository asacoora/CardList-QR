//
//  API.swift
//  LINE Fintech
//

import Foundation

enum API {
    static let host: String = "https://ibxlhaajyj.execute-api.ap-northeast-2.amazonaws.com/challenge"

    /// QR String을 내려받습니다. UUID로 생성된 문자열이 객체에 담겨서 반환됩니다.
    /// 50%의 확률로 에러를 발생시킵니다.
    static let qrString = NetworkRequest<QRData>(path: "/qr-string")

    /// 사용자의 카드 리스트를 내려받습니다.
    static let cardList = NetworkRequest<CardData>(path: "/card")
}
