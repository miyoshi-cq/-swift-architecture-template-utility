# Use Usecase

introduce Usecase Usage

## Overview

Usecase has some roles.

- convert response to domain model
- use repository
- manage paging info 
- input and output storage
- ...

### Definition

```swift
public typealias SampleGet = UsecaseImpl<
    Repos.Sample.Get,
    SampleMapper,
    EmptyInput,
    SampleEntity
>

```

```swift
public struct SampleMapper: MapperProtocol, Initializable {
    public init() {}

    public func convert(response: [SampleResponse]) -> [SampleEntity] {
        response.map { response in
            SampleEntity(
                userId: response.userId,
                id: response.id,
                title: response.title,
                body: response.body
            )
        }
    }
}

```

```swift
public struct SampleEntity: Entity {
    public let userId: Int
    public let id: Int
    public let title: String
    public let body: String
}

```

### Usage

```swift
Task {
    let result = await SampleGet.shared().execute()

    switch result {
    case let .success(value):
        print(value)

    case let .failure(error):
        print(error)
    }
}
```
