//
//  HTTPHeader.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/8/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public class HTTPHeaders {

  private var mapHeaders: [HTTPHeaderName: Int] = [:]
  public private(set) var orderHeaders: [(HTTPHeaderName, String)] = []

  public init(_ headers: [HTTPHeaderName: String]) {
    headers.forEach { key, value in
      self[key] = value
    }
  }

  public static var empty: HTTPHeaders {
    return HTTPHeaders.init([HTTPHeaderName: String](minimumCapacity: 3))
  }

  public var count: Int {
    return orderHeaders.count
  }

  public subscript(key: String) -> String? {
    get {
      if let index = mapHeaders[HTTPHeaderName(key)] {
        return orderHeaders[safe: index]?.1
      }
      return nil
    }
    set {
      let key = HTTPHeaderName(key)
      updateOrderHeader(with: key, newValue: newValue)
    }
  }

  public subscript(key: HTTPHeaderName) -> String? {
    get {
      if let index = mapHeaders[key] {
        return orderHeaders[safe: index]?.1
      }
      return nil
    }
    set {
      updateOrderHeader(with: key, newValue: newValue)
    }
  }

  private func updateOrderHeader(with key: HTTPHeaderName, newValue: String?) {
    // Append or remove
    if let newValue = newValue {
      orderHeaders.append((key, newValue))
      mapHeaders[key] = orderHeaders.count - 1
    } else {
      let index = orderHeaders.firstIndex { $0.0.nameInLowercase == key.nameInLowercase }
      if let removeIndex = index {
        orderHeaders.remove(at: removeIndex)
        mapHeaders[key] = nil
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
