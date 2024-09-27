//
//  YandexMobileMetrica.swift
//  Tracker
//
//  Created by Владислав Усачев on 27.09.2024.
//

import Foundation
import YandexMobileMetrica

struct YandexMobileMetrica {
    static func activate() {
      let configuration = YMMYandexMetricaConfiguration(apiKey: "5d06ee23-ab7f-406f-b81a-35f193087200")
      guard let validConfiguration = configuration else {
        print("Failed to create YMMYandexMetricaConfiguration")
        return
      }
      
      YMMYandexMetrica.activate(with: validConfiguration)
    }

    func report(event: String, params: [AnyHashable: Any]) {
      YMMYandexMetrica.reportEvent(event, parameters: params, onFailure: { error in
        print("REPORT ERROR: %@", error.localizedDescription)
      })
    }
}
