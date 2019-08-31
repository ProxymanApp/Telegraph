//
//  URI.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/5/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public struct URI {
  private var components: URLComponents

  /// Creates a URI from the provided path, query string.
  public init(path: String = "/", query: String? = nil) {
    self.components = URLComponents()
    self.path = path
    self.query = query
  }

  /// Creates a URI from URLComponents. Takes only the path, query string.
  public init(components: URLComponents) {
    self.init(path: components.path, query: components.query)
  }

  /// Creates a URI from the provided URL. Takes only the path, query string and fragment.
  public init?(url: URL) {
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
    self.init(components: components)
  }

  /// Creates a URI from the provided string. Takes only the path, query string and fragment.
  public init?(_ string: String) {
    guard let components = URLComponents(string: string) else { return nil }
    self.init(components: components)
  }
}

public extension URI {
  /// The path of the URI (e.g. /index.html). Always starts with a slash.
  var path: String {
    get { return components.path }
    set { components.path = newValue.hasPrefix("/") ? newValue : "/\(newValue)" }
  }

  /// The query string of the URI (e.g. lang=en&page=home). Does not contain a question mark.
  var query: String? {
    get { return components.query }
    set { components.query = newValue }
  }

  /// The query string items of the URI as an array.
  var queryItems: [URLQueryItem]? {
    get { return components.queryItems }
    set { components.queryItems = newValue }
  }
}

public extension URI {
  /// Returns a URI indicating the root.
  static let root = URI(path: "/")

  /// Returns the part of the path that doesn't overlap.
  /// For example '/files/today' with argument '/files' returns 'today'.
  func relativePath(from path: String) -> String? {
    var result = self.path

    // Remove the part of the path that overlaps
    guard let range = result.range(of: path) else { return nil }
    result = result.replacingCharacters(in: range, with: "")

    // Remove leading slash
    if result.hasPrefix("/") { result.remove(at: result.startIndex) }

    return result
  }
}

extension URI: CustomStringConvertible {
  public var description: String {
    //
    var newComponents = components
    let queries = components.queryItems?.map({ (item) -> String in
      let name = item.name.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed) ?? ""
      let value = item.value?.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed) ?? ""
      return "\(name)=\(value)"
    })
    if let encodedQuery = queries {
      newComponents.percentEncodedQuery = encodedQuery.joined(separator: "&")
    }
    return newComponents.url?.absoluteString ?? components.url?.absoluteString ?? components.description
  }
}

extension CharacterSet {
  /// Creates a CharacterSet from RFC 3986 allowed characters.
  ///
  /// RFC 3986 states that the following characters are "reserved" characters.
  ///
  /// - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
  /// - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
  ///
  /// In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
  /// query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
  /// should be percent-escaped in the query string.
  public static let afURLQueryAllowed: CharacterSet = {
    let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
    let subDelimitersToEncode = "!$&'()*+,;="
    let encodableDelimiters = CharacterSet(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
    return CharacterSet.urlQueryAllowed.subtracting(encodableDelimiters)
  }()
}
