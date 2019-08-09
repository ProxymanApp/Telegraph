//
//  HTTPRequest+Host.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/20/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public extension HTTPRequest {

  // Sets the host header to the specified host and port.
  func setHostHeader(host: String?, port: Int? = nil) {
    var value: String?
    var destinationPort = port ?? 80

    if let host = host {
      value = "\(host)"

      // The default port is 80, no need to send that
      if let port = port, port != 80 {
        destinationPort = port
        value?.append(":\(port)")
      }
    }

    headers.host = value
    self.destinationHost = host
    self.destinationPort = destinationPort
  }
}
