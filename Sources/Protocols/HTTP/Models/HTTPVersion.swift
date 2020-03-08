//
//  HTTPVersion.swift
//  Telegraph
//
//  Created by Yvo van Beek on 1/31/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public struct HTTPVersion {
  public let major: UInt
  public let minor: UInt

  public init(major: UInt, minor: UInt) {
    self.major = major
    self.minor = minor
  }

  public init(protocolName: String) {
    switch protocolName {
    case "h2":
      self.major = 2
      self.minor = 0
    case "http/1.1":
      self.major = 1
      self.minor = 1
    case "http/1.0":
      self.major = 1
      self.minor = 0
    default:
      self.major = 1
      self.minor = 1
    }
  }
}

public extension HTTPVersion {
  static let `default` = HTTPVersion(major: 1, minor: 1)
}

extension HTTPVersion: CustomStringConvertible {
  public var description: String {
    if major == 2 && minor == 0 {
      return "HTTP/2"
    }
    return "HTTP/\(major).\(minor)"
  }
}
