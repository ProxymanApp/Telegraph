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

  private init(headers: [HTTPHeaderName: String], orderHeaders: [(HTTPHeaderName, String)]) {
      self.headers = headers
      self.orderHeaders = orderHeaders
  }

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
      updateOrderHeader(with: key, newValue: newValue, allowDuplicated: false) // Dont' allow duplicated header by default
    }
  }

  public subscript(key: HTTPHeaderName) -> String? {
    get { return headers[key] }
    set {
      updateOrderHeader(with: key, newValue: newValue, allowDuplicated: false)
    }
  }

  public func addHeader(with key: String, newValue: String?, allowDuplicated: Bool) {
    updateOrderHeader(with: HTTPHeaderName(key), newValue: newValue, allowDuplicated: allowDuplicated)
  }

  private func updateOrderHeader(with key: HTTPHeaderName, newValue: String?, allowDuplicated: Bool) {
    // Append or remove
    if let newValue = newValue {

      // No duplicated in Host
      if key == .host {
        orderHeaders.removeAll { $0.0 == .host }
      }

      // If NOT duplicated -> Just remove the previous one
      if !allowDuplicated {
        headers[key] = nil
        orderHeaders.removeAll { $0.0 == key }
      }

      // Allow duplicated key in orderHeaders
      // headers dict is private variables
      headers[key] = newValue
      orderHeaders.append((key, newValue))
    } else {
      headers[key] = nil
      orderHeaders.removeAll { $0.0.nameInLowercase == key.nameInLowercase }
    }
  }

  public func clone() -> HTTPHeaders {
    return HTTPHeaders(headers: self.headers, orderHeaders: self.orderHeaders)
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
