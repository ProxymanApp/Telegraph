//
//  HTTPHeader.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/8/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public class HTTPHeaders {

  private var headers: [HTTPHeaderName: String] = [:]
  public private(set) var orderHeaders: [(HTTPHeaderName, String)] = []

  public init(_ headers: [HTTPHeaderName: String]) {
    self.headers = headers
    headers.forEach { key, value in
      self[key] = value
    }
  }

  public static var empty: HTTPHeaders {
    return HTTPHeaders([HTTPHeaderName: String](minimumCapacity: 3))
  }

  public var count: Int {
    return headers.count
  }

  public subscript(key: String) -> String? {
    get { return headers[HTTPHeaderName(key)] }
    set {
      let key = HTTPHeaderName(key)
      updateOrderHeader(with: key, newValue: newValue)
    }
  }

  public subscript(key: HTTPHeaderName) -> String? {
    get { return headers[key] }
    set {
      updateOrderHeader(with: key, newValue: newValue)
    }
  }

  private func updateOrderHeader(with key: HTTPHeaderName, newValue: String?) {
    // Append or remove
    if let newValue = newValue {
      let isContain = headers[key] != nil

      // Remove duplicated key except set-cookie
      if isContain && key != .setCookie {
        if let index = orderHeaders.firstIndex (where: { $0.0 == key }) {
          orderHeaders.remove(at: index)
        }
      }
      headers[key] = newValue
      orderHeaders.append((key, newValue))
    } else {
      headers[key] = nil
      let index = orderHeaders.firstIndex { $0.0.nameInLowercase == key.nameInLowercase }
      if let removeIndex = index {
        orderHeaders.remove(at: removeIndex)
      }
    }
  }
}

public struct HTTPHeaderName: Hashable {
  public let name: String
  public let nameInLowercase: String

  /// Creates a HTTPHeader name. Header names are case insensitive according to RFC7230.
  init(_ name: String) {
    self.name = name
    self.nameInLowercase = name.lowercased()
  }

  /// Returns a Boolean value indicating whether two names are equal.
  public static func == (lhs: HTTPHeaderName, rhs: HTTPHeaderName) -> Bool {
    return lhs.nameInLowercase == rhs.nameInLowercase
  }

  /// Hashes the name by feeding it into the given hasher.
  public func hash(into hasher: inout Hasher) {
    nameInLowercase.hash(into: &hasher)
  }
}

// MARK: CustomStringConvertible implementation

extension HTTPHeaderName: CustomStringConvertible {
  public var description: String {
    return name
  }
}

// MARK: ExpressibleByStringLiteral implementation

extension HTTPHeaderName: ExpressibleByStringLiteral {
  public init(stringLiteral string: String) {
    self.init(string)
  }
}

// MARK: Convenience methods

public extension Dictionary where Key == HTTPHeaderName, Value == String {
  static var empty: HTTPHeaders {
    return HTTPHeaders.empty
  }

  subscript(key: String) -> String? {
    get { return self[HTTPHeaderName(key)] }
    set { self[HTTPHeaderName(key)] = newValue }
  }
}

extension Collection {

  /// Returns the element at the specified index if it is within bounds, otherwise nil.
  subscript (safe index: Index) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
}
