public protocol MapperProtocol {
    associatedtype Response
    associatedtype EntityModel: Entity

    func convert(response: Response) -> EntityModel
}

public struct EmptyMapper: Initializable {
    public init() {}
}
