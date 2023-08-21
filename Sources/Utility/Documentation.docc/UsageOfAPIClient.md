# Use APIClient

Usage of APIClient.

## Overview

Introduction of APIClient usage.

### Definition

```swift
import Foundation
import Utility

public struct SampleGetRequest: Request {
    public typealias Response = [SampleResponse]
    public typealias PathComponent = EmptyPathComponent

    public struct Parameters: Codable {
        let userId: Int?

        public init(userId: Int?) {
            self.userId = userId
        }
    }

    public let parameters: Parameters
    public var baseURL: String { "baseURL" }
    public var method: HTTPMethod { .get }
    public var path: String { "/posts" }
    public var body: Data?
    public var wantCache: Bool { false }

    public init(
        parameters: Parameters,
        pathComponent: EmptyPathComponent = .init()
    ) {
        self.parameters = parameters
    }
}
```

```swift
public struct Repos {
    public struct Sample {
        public typealias Get = Repository<SampleGetRequest, APIClient>
    }
}
```

### Usage

```swift
Task {
    let result = await Repos.Sample.Get().request(parameters: .init(userId: userId))
}
```
