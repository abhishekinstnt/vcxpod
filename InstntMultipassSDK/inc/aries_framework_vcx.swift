// This file was autogenerated by some hot garbage in the `uniffi` crate.
// Trust me, you don't want to mess with it!

// swiftlint:disable all
import Foundation

// Depending on the consumer's build setup, the low-level FFI code
// might be in a separate module, or it might be compiled inline into
// this module. This is a bit of light hackery to work with both.
#if canImport(aries_framework_vcxFFI)
import aries_framework_vcxFFI
#endif

fileprivate extension RustBuffer {
    // Allocate a new buffer, copying the contents of a `UInt8` array.
    init(bytes: [UInt8]) {
        let rbuf = bytes.withUnsafeBufferPointer { ptr in
            RustBuffer.from(ptr)
        }
        self.init(capacity: rbuf.capacity, len: rbuf.len, data: rbuf.data)
    }

    static func empty() -> RustBuffer {
        RustBuffer(capacity: 0, len:0, data: nil)
    }

    static func from(_ ptr: UnsafeBufferPointer<UInt8>) -> RustBuffer {
        try! rustCall { ffi_uniffi_vcx_rustbuffer_from_bytes(ForeignBytes(bufferPointer: ptr), $0) }
    }

    // Frees the buffer in place.
    // The buffer must not be used after this is called.
    func deallocate() {
        try! rustCall { ffi_uniffi_vcx_rustbuffer_free(self, $0) }
    }
}

fileprivate extension ForeignBytes {
    init(bufferPointer: UnsafeBufferPointer<UInt8>) {
        self.init(len: Int32(bufferPointer.count), data: bufferPointer.baseAddress)
    }
}

// For every type used in the interface, we provide helper methods for conveniently
// lifting and lowering that type from C-compatible data, and for reading and writing
// values of that type in a buffer.

// Helper classes/extensions that don't change.
// Someday, this will be in a library of its own.

fileprivate extension Data {
    init(rustBuffer: RustBuffer) {
        self.init(
            bytesNoCopy: rustBuffer.data!,
            count: Int(rustBuffer.len),
            deallocator: .none
        )
    }
}

// Define reader functionality.  Normally this would be defined in a class or
// struct, but we use standalone functions instead in order to make external
// types work.
//
// With external types, one swift source file needs to be able to call the read
// method on another source file's FfiConverter, but then what visibility
// should Reader have?
// - If Reader is fileprivate, then this means the read() must also
//   be fileprivate, which doesn't work with external types.
// - If Reader is internal/public, we'll get compile errors since both source
//   files will try define the same type.
//
// Instead, the read() method and these helper functions input a tuple of data

fileprivate func createReader(data: Data) -> (data: Data, offset: Data.Index) {
    (data: data, offset: 0)
}

// Reads an integer at the current offset, in big-endian order, and advances
// the offset on success. Throws if reading the integer would move the
// offset past the end of the buffer.
fileprivate func readInt<T: FixedWidthInteger>(_ reader: inout (data: Data, offset: Data.Index)) throws -> T {
    let range = reader.offset..<reader.offset + MemoryLayout<T>.size
    guard reader.data.count >= range.upperBound else {
        throw UniffiInternalError.bufferOverflow
    }
    if T.self == UInt8.self {
        let value = reader.data[reader.offset]
        reader.offset += 1
        return value as! T
    }
    var value: T = 0
    let _ = withUnsafeMutableBytes(of: &value, { reader.data.copyBytes(to: $0, from: range)})
    reader.offset = range.upperBound
    return value.bigEndian
}

// Reads an arbitrary number of bytes, to be used to read
// raw bytes, this is useful when lifting strings
fileprivate func readBytes(_ reader: inout (data: Data, offset: Data.Index), count: Int) throws -> Array<UInt8> {
    let range = reader.offset..<(reader.offset+count)
    guard reader.data.count >= range.upperBound else {
        throw UniffiInternalError.bufferOverflow
    }
    var value = [UInt8](repeating: 0, count: count)
    value.withUnsafeMutableBufferPointer({ buffer in
        reader.data.copyBytes(to: buffer, from: range)
    })
    reader.offset = range.upperBound
    return value
}

// Reads a float at the current offset.
fileprivate func readFloat(_ reader: inout (data: Data, offset: Data.Index)) throws -> Float {
    return Float(bitPattern: try readInt(&reader))
}

// Reads a float at the current offset.
fileprivate func readDouble(_ reader: inout (data: Data, offset: Data.Index)) throws -> Double {
    return Double(bitPattern: try readInt(&reader))
}

// Indicates if the offset has reached the end of the buffer.
fileprivate func hasRemaining(_ reader: (data: Data, offset: Data.Index)) -> Bool {
    return reader.offset < reader.data.count
}

// Define writer functionality.  Normally this would be defined in a class or
// struct, but we use standalone functions instead in order to make external
// types work.  See the above discussion on Readers for details.

fileprivate func createWriter() -> [UInt8] {
    return []
}

fileprivate func writeBytes<S>(_ writer: inout [UInt8], _ byteArr: S) where S: Sequence, S.Element == UInt8 {
    writer.append(contentsOf: byteArr)
}

// Writes an integer in big-endian order.
//
// Warning: make sure what you are trying to write
// is in the correct type!
fileprivate func writeInt<T: FixedWidthInteger>(_ writer: inout [UInt8], _ value: T) {
    var value = value.bigEndian
    withUnsafeBytes(of: &value) { writer.append(contentsOf: $0) }
}

fileprivate func writeFloat(_ writer: inout [UInt8], _ value: Float) {
    writeInt(&writer, value.bitPattern)
}

fileprivate func writeDouble(_ writer: inout [UInt8], _ value: Double) {
    writeInt(&writer, value.bitPattern)
}

// Protocol for types that transfer other types across the FFI. This is
// analogous to the Rust trait of the same name.
fileprivate protocol FfiConverter {
    associatedtype FfiType
    associatedtype SwiftType

    static func lift(_ value: FfiType) throws -> SwiftType
    static func lower(_ value: SwiftType) -> FfiType
    static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> SwiftType
    static func write(_ value: SwiftType, into buf: inout [UInt8])
}

// Types conforming to `Primitive` pass themselves directly over the FFI.
fileprivate protocol FfiConverterPrimitive: FfiConverter where FfiType == SwiftType { }

extension FfiConverterPrimitive {
    public static func lift(_ value: FfiType) throws -> SwiftType {
        return value
    }

    public static func lower(_ value: SwiftType) -> FfiType {
        return value
    }
}

// Types conforming to `FfiConverterRustBuffer` lift and lower into a `RustBuffer`.
// Used for complex types where it's hard to write a custom lift/lower.
fileprivate protocol FfiConverterRustBuffer: FfiConverter where FfiType == RustBuffer {}

extension FfiConverterRustBuffer {
    public static func lift(_ buf: RustBuffer) throws -> SwiftType {
        var reader = createReader(data: Data(rustBuffer: buf))
        let value = try read(from: &reader)
        if hasRemaining(reader) {
            throw UniffiInternalError.incompleteData
        }
        buf.deallocate()
        return value
    }

    public static func lower(_ value: SwiftType) -> RustBuffer {
          var writer = createWriter()
          write(value, into: &writer)
          return RustBuffer(bytes: writer)
    }
}
// An error type for FFI errors. These errors occur at the UniFFI level, not
// the library level.
fileprivate enum UniffiInternalError: LocalizedError {
    case bufferOverflow
    case incompleteData
    case unexpectedOptionalTag
    case unexpectedEnumCase
    case unexpectedNullPointer
    case unexpectedRustCallStatusCode
    case unexpectedRustCallError
    case unexpectedStaleHandle
    case rustPanic(_ message: String)

    public var errorDescription: String? {
        switch self {
        case .bufferOverflow: return "Reading the requested value would read past the end of the buffer"
        case .incompleteData: return "The buffer still has data after lifting its containing value"
        case .unexpectedOptionalTag: return "Unexpected optional tag; should be 0 or 1"
        case .unexpectedEnumCase: return "Raw enum value doesn't match any cases"
        case .unexpectedNullPointer: return "Raw pointer value was null"
        case .unexpectedRustCallStatusCode: return "Unexpected RustCallStatus code"
        case .unexpectedRustCallError: return "CALL_ERROR but no errorClass specified"
        case .unexpectedStaleHandle: return "The object in the handle map has been dropped already"
        case let .rustPanic(message): return message
        }
    }
}

fileprivate extension NSLock {
    func withLock<T>(f: () throws -> T) rethrows -> T {
        self.lock()
        defer { self.unlock() }
        return try f()
    }
}

fileprivate let CALL_SUCCESS: Int8 = 0
fileprivate let CALL_ERROR: Int8 = 1
fileprivate let CALL_UNEXPECTED_ERROR: Int8 = 2
fileprivate let CALL_CANCELLED: Int8 = 3

fileprivate extension RustCallStatus {
    init() {
        self.init(
            code: CALL_SUCCESS,
            errorBuf: RustBuffer.init(
                capacity: 0,
                len: 0,
                data: nil
            )
        )
    }
}

private func rustCall<T>(_ callback: (UnsafeMutablePointer<RustCallStatus>) -> T) throws -> T {
    let neverThrow: ((RustBuffer) throws -> Never)? = nil
    return try makeRustCall(callback, errorHandler: neverThrow)
}

private func rustCallWithError<T, E: Swift.Error>(
    _ errorHandler: @escaping (RustBuffer) throws -> E,
    _ callback: (UnsafeMutablePointer<RustCallStatus>) -> T) throws -> T {
    try makeRustCall(callback, errorHandler: errorHandler)
}

private func makeRustCall<T, E: Swift.Error>(
    _ callback: (UnsafeMutablePointer<RustCallStatus>) -> T,
    errorHandler: ((RustBuffer) throws -> E)?
) throws -> T {
    uniffiEnsureInitialized()
    var callStatus = RustCallStatus.init()
    let returnedVal = callback(&callStatus)
    try uniffiCheckCallStatus(callStatus: callStatus, errorHandler: errorHandler)
    return returnedVal
}

private func uniffiCheckCallStatus<E: Swift.Error>(
    callStatus: RustCallStatus,
    errorHandler: ((RustBuffer) throws -> E)?
) throws {
    switch callStatus.code {
        case CALL_SUCCESS:
            return

        case CALL_ERROR:
            if let errorHandler = errorHandler {
                throw try errorHandler(callStatus.errorBuf)
            } else {
                callStatus.errorBuf.deallocate()
                throw UniffiInternalError.unexpectedRustCallError
            }

        case CALL_UNEXPECTED_ERROR:
            // When the rust code sees a panic, it tries to construct a RustBuffer
            // with the message.  But if that code panics, then it just sends back
            // an empty buffer.
            if callStatus.errorBuf.len > 0 {
                throw UniffiInternalError.rustPanic(try FfiConverterString.lift(callStatus.errorBuf))
            } else {
                callStatus.errorBuf.deallocate()
                throw UniffiInternalError.rustPanic("Rust panic")
            }

        case CALL_CANCELLED:
            fatalError("Cancellation not supported yet")

        default:
            throw UniffiInternalError.unexpectedRustCallStatusCode
    }
}

private func uniffiTraitInterfaceCall<T>(
    callStatus: UnsafeMutablePointer<RustCallStatus>,
    makeCall: () throws -> T,
    writeReturn: (T) -> ()
) {
    do {
        try writeReturn(makeCall())
    } catch let error {
        callStatus.pointee.code = CALL_UNEXPECTED_ERROR
        callStatus.pointee.errorBuf = FfiConverterString.lower(String(describing: error))
    }
}

private func uniffiTraitInterfaceCallWithError<T, E>(
    callStatus: UnsafeMutablePointer<RustCallStatus>,
    makeCall: () throws -> T,
    writeReturn: (T) -> (),
    lowerError: (E) -> RustBuffer
) {
    do {
        try writeReturn(makeCall())
    } catch let error as E {
        callStatus.pointee.code = CALL_ERROR
        callStatus.pointee.errorBuf = lowerError(error)
    } catch {
        callStatus.pointee.code = CALL_UNEXPECTED_ERROR
        callStatus.pointee.errorBuf = FfiConverterString.lower(String(describing: error))
    }
}
fileprivate class UniffiHandleMap<T> {
    private var map: [UInt64: T] = [:]
    private let lock = NSLock()
    private var currentHandle: UInt64 = 1

    func insert(obj: T) -> UInt64 {
        lock.withLock {
            let handle = currentHandle
            currentHandle += 1
            map[handle] = obj
            return handle
        }
    }

     func get(handle: UInt64) throws -> T {
        try lock.withLock {
            guard let obj = map[handle] else {
                throw UniffiInternalError.unexpectedStaleHandle
            }
            return obj
        }
    }

    @discardableResult
    func remove(handle: UInt64) throws -> T {
        try lock.withLock {
            guard let obj = map.removeValue(forKey: handle) else {
                throw UniffiInternalError.unexpectedStaleHandle
            }
            return obj
        }
    }

    var count: Int {
        get {
            map.count
        }
    }
}


// Public interface members begin here.


fileprivate struct FfiConverterBool : FfiConverter {
    typealias FfiType = Int8
    typealias SwiftType = Bool

    public static func lift(_ value: Int8) throws -> Bool {
        return value != 0
    }

    public static func lower(_ value: Bool) -> Int8 {
        return value ? 1 : 0
    }

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> Bool {
        return try lift(readInt(&buf))
    }

    public static func write(_ value: Bool, into buf: inout [UInt8]) {
        writeInt(&buf, lower(value))
    }
}

fileprivate struct FfiConverterString: FfiConverter {
    typealias SwiftType = String
    typealias FfiType = RustBuffer

    public static func lift(_ value: RustBuffer) throws -> String {
        defer {
            value.deallocate()
        }
        if value.data == nil {
            return String()
        }
        let bytes = UnsafeBufferPointer<UInt8>(start: value.data!, count: Int(value.len))
        return String(bytes: bytes, encoding: String.Encoding.utf8)!
    }

    public static func lower(_ value: String) -> RustBuffer {
        return value.utf8CString.withUnsafeBufferPointer { ptr in
            // The swift string gives us int8_t, we want uint8_t.
            ptr.withMemoryRebound(to: UInt8.self) { ptr in
                // The swift string gives us a trailing null byte, we don't want it.
                let buf = UnsafeBufferPointer(rebasing: ptr.prefix(upTo: ptr.count - 1))
                return RustBuffer.from(buf)
            }
        }
    }

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> String {
        let len: Int32 = try readInt(&buf)
        return String(bytes: try readBytes(&buf, count: Int(len)), encoding: String.Encoding.utf8)!
    }

    public static func write(_ value: String, into buf: inout [UInt8]) {
        let len = Int32(value.utf8.count)
        writeInt(&buf, len)
        writeBytes(&buf, value.utf8)
    }
}




public protocol AriesFrameworkVcxProtocol : AnyObject {
    
}

open class AriesFrameworkVcx:
    AriesFrameworkVcxProtocol {
    fileprivate let pointer: UnsafeMutableRawPointer!

    /// Used to instantiate a [FFIObject] without an actual pointer, for fakes in tests, mostly.
    public struct NoPointer {
        public init() {}
    }

    // TODO: We'd like this to be `private` but for Swifty reasons,
    // we can't implement `FfiConverter` without making this `required` and we can't
    // make it `required` without making it `public`.
    required public init(unsafeFromRawPointer pointer: UnsafeMutableRawPointer) {
        self.pointer = pointer
    }

    /// This constructor can be used to instantiate a fake object.
    /// - Parameter noPointer: Placeholder value so we can have a constructor separate from the default empty one that may be implemented for classes extending [FFIObject].
    ///
    /// - Warning:
    ///     Any object instantiated with this constructor cannot be passed to an actual Rust-backed object. Since there isn't a backing [Pointer] the FFI lower functions will crash.
    public init(noPointer: NoPointer) {
        self.pointer = nil
    }

    public func uniffiClonePointer() -> UnsafeMutableRawPointer {
        return try! rustCall { uniffi_uniffi_vcx_fn_clone_ariesframeworkvcx(self.pointer, $0) }
    }
public convenience init(frameworkConfig: FrameworkConfig) {
    let pointer =
        try! rustCall() {
    uniffi_uniffi_vcx_fn_constructor_ariesframeworkvcx_new(
        FfiConverterTypeFrameworkConfig.lower(frameworkConfig),$0
    )
}
    self.init(unsafeFromRawPointer: pointer)
}

    deinit {
        guard let pointer = pointer else {
            return
        }

        try! rustCall { uniffi_uniffi_vcx_fn_free_ariesframeworkvcx(pointer, $0) }
    }

    

    

}

public struct FfiConverterTypeAriesFrameworkVCX: FfiConverter {

    typealias FfiType = UnsafeMutableRawPointer
    typealias SwiftType = AriesFrameworkVcx

    public static func lift(_ pointer: UnsafeMutableRawPointer) throws -> AriesFrameworkVcx {
        return AriesFrameworkVcx(unsafeFromRawPointer: pointer)
    }

    public static func lower(_ value: AriesFrameworkVcx) -> UnsafeMutableRawPointer {
        return value.uniffiClonePointer()
    }

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> AriesFrameworkVcx {
        let v: UInt64 = try readInt(&buf)
        // The Rust code won't compile if a pointer won't fit in a UInt64.
        // We have to go via `UInt` because that's the thing that's the size of a pointer.
        let ptr = UnsafeMutableRawPointer(bitPattern: UInt(truncatingIfNeeded: v))
        if (ptr == nil) {
            throw UniffiInternalError.unexpectedNullPointer
        }
        return try lift(ptr!)
    }

    public static func write(_ value: AriesFrameworkVcx, into buf: inout [UInt8]) {
        // This fiddling is because `Int` is the thing that's the same size as a pointer.
        // The Rust code won't compile if a pointer won't fit in a `UInt64`.
        writeInt(&buf, UInt64(bitPattern: Int64(Int(bitPattern: lower(value)))))
    }
}




public func FfiConverterTypeAriesFrameworkVCX_lift(_ pointer: UnsafeMutableRawPointer) throws -> AriesFrameworkVcx {
    return try FfiConverterTypeAriesFrameworkVCX.lift(pointer)
}

public func FfiConverterTypeAriesFrameworkVCX_lower(_ value: AriesFrameworkVcx) -> UnsafeMutableRawPointer {
    return FfiConverterTypeAriesFrameworkVCX.lower(value)
}


public struct AskarWalletConfig {
    public var dbUrl: String
    public var keyMethod: KeyMethod
    public var passKey: String
    public var profile: String

    // Default memberwise initializers are never public by default, so we
    // declare one manually.
    public init(dbUrl: String, keyMethod: KeyMethod, passKey: String, profile: String) {
        self.dbUrl = dbUrl
        self.keyMethod = keyMethod
        self.passKey = passKey
        self.profile = profile
    }
}



extension AskarWalletConfig: Equatable, Hashable {
    public static func ==(lhs: AskarWalletConfig, rhs: AskarWalletConfig) -> Bool {
        if lhs.dbUrl != rhs.dbUrl {
            return false
        }
        if lhs.keyMethod != rhs.keyMethod {
            return false
        }
        if lhs.passKey != rhs.passKey {
            return false
        }
        if lhs.profile != rhs.profile {
            return false
        }
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(dbUrl)
        hasher.combine(keyMethod)
        hasher.combine(passKey)
        hasher.combine(profile)
    }
}


public struct FfiConverterTypeAskarWalletConfig: FfiConverterRustBuffer {
    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> AskarWalletConfig {
        return
            try AskarWalletConfig(
                dbUrl: FfiConverterString.read(from: &buf), 
                keyMethod: FfiConverterTypeKeyMethod.read(from: &buf), 
                passKey: FfiConverterString.read(from: &buf), 
                profile: FfiConverterString.read(from: &buf)
        )
    }

    public static func write(_ value: AskarWalletConfig, into buf: inout [UInt8]) {
        FfiConverterString.write(value.dbUrl, into: &buf)
        FfiConverterTypeKeyMethod.write(value.keyMethod, into: &buf)
        FfiConverterString.write(value.passKey, into: &buf)
        FfiConverterString.write(value.profile, into: &buf)
    }
}


public func FfiConverterTypeAskarWalletConfig_lift(_ buf: RustBuffer) throws -> AskarWalletConfig {
    return try FfiConverterTypeAskarWalletConfig.lift(buf)
}

public func FfiConverterTypeAskarWalletConfig_lower(_ value: AskarWalletConfig) -> RustBuffer {
    return FfiConverterTypeAskarWalletConfig.lower(value)
}


public struct ConnectionServiceConfig {
    public var autoCompleteRequests: Bool
    public var autoRespondToRequests: Bool
    public var autoHandleRequests: Bool

    // Default memberwise initializers are never public by default, so we
    // declare one manually.
    public init(autoCompleteRequests: Bool, autoRespondToRequests: Bool, autoHandleRequests: Bool) {
        self.autoCompleteRequests = autoCompleteRequests
        self.autoRespondToRequests = autoRespondToRequests
        self.autoHandleRequests = autoHandleRequests
    }
}



extension ConnectionServiceConfig: Equatable, Hashable {
    public static func ==(lhs: ConnectionServiceConfig, rhs: ConnectionServiceConfig) -> Bool {
        if lhs.autoCompleteRequests != rhs.autoCompleteRequests {
            return false
        }
        if lhs.autoRespondToRequests != rhs.autoRespondToRequests {
            return false
        }
        if lhs.autoHandleRequests != rhs.autoHandleRequests {
            return false
        }
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(autoCompleteRequests)
        hasher.combine(autoRespondToRequests)
        hasher.combine(autoHandleRequests)
    }
}


public struct FfiConverterTypeConnectionServiceConfig: FfiConverterRustBuffer {
    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> ConnectionServiceConfig {
        return
            try ConnectionServiceConfig(
                autoCompleteRequests: FfiConverterBool.read(from: &buf), 
                autoRespondToRequests: FfiConverterBool.read(from: &buf), 
                autoHandleRequests: FfiConverterBool.read(from: &buf)
        )
    }

    public static func write(_ value: ConnectionServiceConfig, into buf: inout [UInt8]) {
        FfiConverterBool.write(value.autoCompleteRequests, into: &buf)
        FfiConverterBool.write(value.autoRespondToRequests, into: &buf)
        FfiConverterBool.write(value.autoHandleRequests, into: &buf)
    }
}


public func FfiConverterTypeConnectionServiceConfig_lift(_ buf: RustBuffer) throws -> ConnectionServiceConfig {
    return try FfiConverterTypeConnectionServiceConfig.lift(buf)
}

public func FfiConverterTypeConnectionServiceConfig_lower(_ value: ConnectionServiceConfig) -> RustBuffer {
    return FfiConverterTypeConnectionServiceConfig.lower(value)
}


public struct FrameworkConfig {
    public var walletConfig: AskarWalletConfig
    public var connectionServiceConfig: ConnectionServiceConfig
    public var agentEndpoint: Url
    public var agentLabel: String

    // Default memberwise initializers are never public by default, so we
    // declare one manually.
    public init(walletConfig: AskarWalletConfig, connectionServiceConfig: ConnectionServiceConfig, agentEndpoint: Url, agentLabel: String) {
        self.walletConfig = walletConfig
        self.connectionServiceConfig = connectionServiceConfig
        self.agentEndpoint = agentEndpoint
        self.agentLabel = agentLabel
    }
}



extension FrameworkConfig: Equatable, Hashable {
    public static func ==(lhs: FrameworkConfig, rhs: FrameworkConfig) -> Bool {
        if lhs.walletConfig != rhs.walletConfig {
            return false
        }
        if lhs.connectionServiceConfig != rhs.connectionServiceConfig {
            return false
        }
        if lhs.agentEndpoint != rhs.agentEndpoint {
            return false
        }
        if lhs.agentLabel != rhs.agentLabel {
            return false
        }
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(walletConfig)
        hasher.combine(connectionServiceConfig)
        hasher.combine(agentEndpoint)
        hasher.combine(agentLabel)
    }
}


public struct FfiConverterTypeFrameworkConfig: FfiConverterRustBuffer {
    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> FrameworkConfig {
        return
            try FrameworkConfig(
                walletConfig: FfiConverterTypeAskarWalletConfig.read(from: &buf), 
                connectionServiceConfig: FfiConverterTypeConnectionServiceConfig.read(from: &buf), 
                agentEndpoint: FfiConverterTypeUrl.read(from: &buf), 
                agentLabel: FfiConverterString.read(from: &buf)
        )
    }

    public static func write(_ value: FrameworkConfig, into buf: inout [UInt8]) {
        FfiConverterTypeAskarWalletConfig.write(value.walletConfig, into: &buf)
        FfiConverterTypeConnectionServiceConfig.write(value.connectionServiceConfig, into: &buf)
        FfiConverterTypeUrl.write(value.agentEndpoint, into: &buf)
        FfiConverterString.write(value.agentLabel, into: &buf)
    }
}


public func FfiConverterTypeFrameworkConfig_lift(_ buf: RustBuffer) throws -> FrameworkConfig {
    return try FfiConverterTypeFrameworkConfig.lift(buf)
}

public func FfiConverterTypeFrameworkConfig_lower(_ value: FrameworkConfig) -> RustBuffer {
    return FfiConverterTypeFrameworkConfig.lower(value)
}

// Note that we don't yet support `indirect` for enums.
// See https://github.com/mozilla/uniffi-rs/issues/396 for further discussion.

public enum ArgonLevel {
    
    case interactive
    case moderate
}


public struct FfiConverterTypeArgonLevel: FfiConverterRustBuffer {
    typealias SwiftType = ArgonLevel

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> ArgonLevel {
        let variant: Int32 = try readInt(&buf)
        switch variant {
        
        case 1: return .interactive
        
        case 2: return .moderate
        
        default: throw UniffiInternalError.unexpectedEnumCase
        }
    }

    public static func write(_ value: ArgonLevel, into buf: inout [UInt8]) {
        switch value {
        
        
        case .interactive:
            writeInt(&buf, Int32(1))
        
        
        case .moderate:
            writeInt(&buf, Int32(2))
        
        }
    }
}


public func FfiConverterTypeArgonLevel_lift(_ buf: RustBuffer) throws -> ArgonLevel {
    return try FfiConverterTypeArgonLevel.lift(buf)
}

public func FfiConverterTypeArgonLevel_lower(_ value: ArgonLevel) -> RustBuffer {
    return FfiConverterTypeArgonLevel.lower(value)
}



extension ArgonLevel: Equatable, Hashable {}



// Note that we don't yet support `indirect` for enums.
// See https://github.com/mozilla/uniffi-rs/issues/396 for further discussion.

public enum AskarKdfMethod {
    
    case argon2i(inner: ArgonLevel
    )
}


public struct FfiConverterTypeAskarKdfMethod: FfiConverterRustBuffer {
    typealias SwiftType = AskarKdfMethod

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> AskarKdfMethod {
        let variant: Int32 = try readInt(&buf)
        switch variant {
        
        case 1: return .argon2i(inner: try FfiConverterTypeArgonLevel.read(from: &buf)
        )
        
        default: throw UniffiInternalError.unexpectedEnumCase
        }
    }

    public static func write(_ value: AskarKdfMethod, into buf: inout [UInt8]) {
        switch value {
        
        
        case let .argon2i(inner):
            writeInt(&buf, Int32(1))
            FfiConverterTypeArgonLevel.write(inner, into: &buf)
            
        }
    }
}


public func FfiConverterTypeAskarKdfMethod_lift(_ buf: RustBuffer) throws -> AskarKdfMethod {
    return try FfiConverterTypeAskarKdfMethod.lift(buf)
}

public func FfiConverterTypeAskarKdfMethod_lower(_ value: AskarKdfMethod) -> RustBuffer {
    return FfiConverterTypeAskarKdfMethod.lower(value)
}



extension AskarKdfMethod: Equatable, Hashable {}



// Note that we don't yet support `indirect` for enums.
// See https://github.com/mozilla/uniffi-rs/issues/396 for further discussion.

public enum KeyMethod {
    
    case deriveKey(inner: AskarKdfMethod
    )
    case rawKey
    case unprotected
}


public struct FfiConverterTypeKeyMethod: FfiConverterRustBuffer {
    typealias SwiftType = KeyMethod

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> KeyMethod {
        let variant: Int32 = try readInt(&buf)
        switch variant {
        
        case 1: return .deriveKey(inner: try FfiConverterTypeAskarKdfMethod.read(from: &buf)
        )
        
        case 2: return .rawKey
        
        case 3: return .unprotected
        
        default: throw UniffiInternalError.unexpectedEnumCase
        }
    }

    public static func write(_ value: KeyMethod, into buf: inout [UInt8]) {
        switch value {
        
        
        case let .deriveKey(inner):
            writeInt(&buf, Int32(1))
            FfiConverterTypeAskarKdfMethod.write(inner, into: &buf)
            
        
        case .rawKey:
            writeInt(&buf, Int32(2))
        
        
        case .unprotected:
            writeInt(&buf, Int32(3))
        
        }
    }
}


public func FfiConverterTypeKeyMethod_lift(_ buf: RustBuffer) throws -> KeyMethod {
    return try FfiConverterTypeKeyMethod.lift(buf)
}

public func FfiConverterTypeKeyMethod_lower(_ value: KeyMethod) -> RustBuffer {
    return FfiConverterTypeKeyMethod.lower(value)
}



extension KeyMethod: Equatable, Hashable {}




/**
 * Typealias from the type name used in the UDL file to the builtin type.  This
 * is needed because the UDL type name is used in function/method signatures.
 */
public typealias Url = String
public struct FfiConverterTypeUrl: FfiConverter {
    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> Url {
        return try FfiConverterString.read(from: &buf)
    }

    public static func write(_ value: Url, into buf: inout [UInt8]) {
        return FfiConverterString.write(value, into: &buf)
    }

    public static func lift(_ value: RustBuffer) throws -> Url {
        return try FfiConverterString.lift(value)
    }

    public static func lower(_ value: Url) -> RustBuffer {
        return FfiConverterString.lower(value)
    }
}


public func FfiConverterTypeUrl_lift(_ value: RustBuffer) throws -> Url {
    return try FfiConverterTypeUrl.lift(value)
}

public func FfiConverterTypeUrl_lower(_ value: Url) -> RustBuffer {
    return FfiConverterTypeUrl.lower(value)
}


private enum InitializationResult {
    case ok
    case contractVersionMismatch
    case apiChecksumMismatch
}
// Use a global variable to perform the versioning checks. Swift ensures that
// the code inside is only computed once.
private var initializationResult: InitializationResult = {
    // Get the bindings contract version from our ComponentInterface
    let bindings_contract_version = 26
    // Get the scaffolding contract version by calling the into the dylib
    let scaffolding_contract_version = ffi_uniffi_vcx_uniffi_contract_version()
    if bindings_contract_version != scaffolding_contract_version {
        return InitializationResult.contractVersionMismatch
    }
    if (uniffi_uniffi_vcx_checksum_constructor_ariesframeworkvcx_new() != 19769) {
        return InitializationResult.apiChecksumMismatch
    }

    return InitializationResult.ok
}()

private func uniffiEnsureInitialized() {
    switch initializationResult {
    case .ok:
        break
    case .contractVersionMismatch:
        fatalError("UniFFI contract version mismatch: try cleaning and rebuilding your project")
    case .apiChecksumMismatch:
        fatalError("UniFFI API checksum mismatch: try cleaning and rebuilding your project")
    }
}

// swiftlint:enable all