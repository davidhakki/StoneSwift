//
//  Stream.swift
//  SwiftScape
//
//  Created by David Hakki on 5/25/24.
//

import Foundation

class Stream {
    var buffer: [UInt8]
    var currentOffset: Int = 0
    var bitPosition: Int = 0
    
    static let bitMaskOut: [Int] = {
        (0..<32).map { (1 << $0) - 1 }
    }()
    
    init(buffer: [UInt8] = []) {
        self.buffer = buffer
    }
    
    func readSignedByteA() -> Int8 {
        let value = buffer[currentOffset] &+ 128
        currentOffset += 1
        return Int8(bitPattern: value)
    }

    func readSignedByteC() -> Int8 {
        let value = buffer[currentOffset]
        currentOffset += 1
        return -Int8(bitPattern: value)
    }

    func readSignedByteS() -> Int8 {
        let value = 128 &- buffer[currentOffset]
        currentOffset += 1
        return Int8(bitPattern: value)
    }

    func readUnsignedByteA() -> UInt8 {
        let value = Int(buffer[currentOffset]) &- 128
        currentOffset += 1
        return UInt8(truncatingIfNeeded: value & 0xff)
    }

    func readUnsignedByteC() -> UInt8 {
        let value = -Int(buffer[currentOffset])
        currentOffset += 1
        return UInt8(truncatingIfNeeded: value & 0xff)
    }

    func readUnsignedByteS() -> UInt8 {
        let value = 128 &- Int(buffer[currentOffset])
        currentOffset += 1
        return UInt8(truncatingIfNeeded: value & 0xff)
    }

    func writeByteA(_ i: Int) {
        buffer[currentOffset] = UInt8(i &+ 128)
        currentOffset += 1
    }

    func writeByteS(_ i: Int) {
        buffer[currentOffset] = UInt8(128 &- i)
        currentOffset += 1
    }

    func writeByteC(_ i: Int) {
        buffer[currentOffset] = UInt8(-i)
        currentOffset += 1
    }
    
    func readSignedWordBigEndian() -> Int {
        currentOffset += 2
        var i = Int(buffer[currentOffset - 1] & 0xff) << 8
        i += Int(buffer[currentOffset - 2] & 0xff)
        if i > 32767 {
            i -= 0x10000
        }
        return i
    }
    
    func readSignedWordA() -> Int {
        currentOffset += 2
        var i = Int(buffer[currentOffset - 2] & 0xff) << 8
        i += Int(buffer[currentOffset - 1] &- 128) & 0xff
        if i > 32767 {
            i -= 0x10000
        }
        return i
    }
    
    func readSignedWordBigEndianA() -> Int {
        currentOffset += 2
        var i = Int(buffer[currentOffset - 1] & 0xff) << 8
        i += Int(buffer[currentOffset - 2] &- 128) & 0xff
        if i > 32767 {
            i -= 0x10000
        }
        return i
    }
    
    func readUnsignedWordBigEndian() -> Int {
        currentOffset += 2
        return (Int(buffer[currentOffset - 1] & 0xff) << 8) + Int(buffer[currentOffset - 2] & 0xff)
    }
    
    func readUnsignedWordA() -> Int {
        currentOffset += 2
        return (Int(buffer[currentOffset - 2] & 0xff) << 8) + (Int(buffer[currentOffset - 1] &- 128) & 0xff)
    }
    
    func readUnsignedWordBigEndianA() -> Int {
        currentOffset += 2
        return (Int(buffer[currentOffset - 1] & 0xff) << 8) + (Int(buffer[currentOffset - 2] &- 128) & 0xff)
    }
    
    func writeWordBigEndianA(_ i: Int) {
        buffer[currentOffset] = UInt8(i &+ 128)
        currentOffset += 1
        buffer[currentOffset] = UInt8(i >> 8)
        currentOffset += 1
    }

    func writeWordA(_ i: Int) {
        buffer[currentOffset] = UInt8(i >> 8)
        currentOffset += 1
        buffer[currentOffset] = UInt8(i &+ 128)
        currentOffset += 1
    }

    func writeWordBigEndian_dup(_ i: Int) {
        buffer[currentOffset] = UInt8(i)
        currentOffset += 1
        buffer[currentOffset] = UInt8(i >> 8)
        currentOffset += 1
    }
    
    func readDWord_v1() -> Int {
        currentOffset += 4
        return (Int(buffer[currentOffset - 2] & 0xff) << 24) +
        (Int(buffer[currentOffset - 1] & 0xff) << 16) +
        (Int(buffer[currentOffset - 4] & 0xff) << 8) +
        Int(buffer[currentOffset - 3] & 0xff)
    }
    
    func readDWord_v2() -> Int {
        currentOffset += 4
        return (Int(buffer[currentOffset - 3] & 0xff) << 24) +
        (Int(buffer[currentOffset - 4] & 0xff) << 16) +
        (Int(buffer[currentOffset - 1] & 0xff) << 8) +
        Int(buffer[currentOffset - 2] & 0xff)
    }
    
    func writeDWord_v1(_ i: Int) {
        buffer[currentOffset] = UInt8(i >> 8)
        currentOffset += 1
        buffer[currentOffset] = UInt8(i)
        currentOffset += 1
        buffer[currentOffset] = UInt8(i >> 24)
        currentOffset += 1
        buffer[currentOffset] = UInt8(i >> 16)
        currentOffset += 1
    }

    func writeDWord_v2(_ i: Int) {
        buffer[currentOffset] = UInt8(i >> 16)
        currentOffset += 1
        buffer[currentOffset] = UInt8(i >> 24)
        currentOffset += 1
        buffer[currentOffset] = UInt8(i)
        currentOffset += 1
        buffer[currentOffset] = UInt8(i >> 8)
        currentOffset += 1
    }

    func readBytes_reverse(_ abyte0: inout [UInt8], _ i: Int, _ j: Int) {
        for k in stride(from: j + i - 1, through: j, by: -1) {
            abyte0[k] = buffer[currentOffset]
            currentOffset += 1
        }
    }

    func writeBytes_reverse(_ abyte0: [UInt8], _ i: Int, _ j: Int) {
        for k in stride(from: j + i - 1, through: j, by: -1) {
            buffer[currentOffset] = abyte0[k]
            currentOffset += 1
        }
    }

    func readBytes_reverseA(_ abyte0: inout [UInt8], _ i: Int, _ j: Int) {
        for k in stride(from: j + i - 1, through: j, by: -1) {
            abyte0[k] = UInt8(Int(buffer[currentOffset]) &- 128)
            currentOffset += 1
        }
    }

    func writeBytes_reverseA(_ abyte0: [UInt8], _ i: Int, _ j: Int) {
        for k in stride(from: j + i - 1, through: j, by: -1) {
            buffer[currentOffset] = UInt8(Int(abyte0[k]) &+ 128)
            currentOffset += 1
        }
    }

    func createFrame(_ id: Int) {
        buffer[currentOffset] = UInt8(id &+ packetEncryption.getNextKey())
        currentOffset += 1
    }
    
    // Add packet encryption placeholder
    var packetEncryption = Cryption()
    
    private static let frameStackSize = 10
    private var frameStackPtr = -1
    private var frameStack = [Int](repeating: 0, count: frameStackSize)
    
    func createFrameVarSize(_ id: Int) {
        buffer[currentOffset] = UInt8(id &+ packetEncryption.getNextKey())
        currentOffset += 1
        buffer[currentOffset] = 0
        currentOffset += 1
        if frameStackPtr >= Self.frameStackSize - 1 {
            fatalError("Stack overflow")
        } else {
            frameStack[frameStackPtr + 1] = currentOffset
            frameStackPtr += 1
        }
    }

    func createFrameVarSizeWord(_ id: Int) {
        buffer[currentOffset] = UInt8(id &+ packetEncryption.getNextKey())
        currentOffset += 1
        writeWord(0) // placeholder for size word
        if frameStackPtr >= Self.frameStackSize - 1 {
            fatalError("Stack overflow")
        } else {
            frameStack[frameStackPtr + 1] = currentOffset
            frameStackPtr += 1
        }
    }

    func endFrameVarSize() {
        if frameStackPtr < 0 {
            fatalError("Stack empty")
        } else {
            writeFrameSize(currentOffset - frameStack[frameStackPtr])
            frameStackPtr -= 1
        }
    }

    func endFrameVarSizeWord() {
        if frameStackPtr < 0 {
            fatalError("Stack empty")
        } else {
            writeFrameSizeWord(currentOffset - frameStack[frameStackPtr])
            frameStackPtr -= 1
        }
    }

    func writeByte(_ i: Int) {
        buffer[currentOffset] = UInt8(i)
        currentOffset += 1
    }

    func writeWord(_ i: Int) {
        buffer[currentOffset] = UInt8(i >> 8)
        currentOffset += 1
        buffer[currentOffset] = UInt8(i)
        currentOffset += 1
    }

    func writeWordBigEndian(_ i: Int) {
        buffer[currentOffset] = UInt8(i)
        currentOffset += 1
        buffer[currentOffset] = UInt8(i >> 8)
        currentOffset += 1
    }

    func write3Byte(_ i: Int) {
        buffer[currentOffset] = UInt8(i >> 16)
        currentOffset += 1
        buffer[currentOffset] = UInt8(i >> 8)
        currentOffset += 1
        buffer[currentOffset] = UInt8(i)
        currentOffset += 1
    }

    func writeDWord(_ i: Int) {
        buffer[currentOffset] = UInt8(i >> 24)
        currentOffset += 1
        buffer[currentOffset] = UInt8(i >> 16)
        currentOffset += 1
        buffer[currentOffset] = UInt8(i >> 8)
        currentOffset += 1
        buffer[currentOffset] = UInt8(i)
        currentOffset += 1
    }
    
    func writeDWordBigEndian(_ i: Int) {
        buffer[currentOffset] = UInt8(i)
        currentOffset += 1
        buffer[currentOffset] = UInt8(i >> 8)
        currentOffset += 1
        buffer[currentOffset] = UInt8(i >> 16)
        currentOffset += 1
        buffer[currentOffset] = UInt8(i >> 24)
        currentOffset += 1
    }

    func writeQWord(_ l: Int64) {
        buffer[currentOffset] = UInt8(l >> 56)
        currentOffset += 1
        buffer[currentOffset] = UInt8(l >> 48)
        currentOffset += 1
        buffer[currentOffset] = UInt8(l >> 40)
        currentOffset += 1
        buffer[currentOffset] = UInt8(l >> 32)
        currentOffset += 1
        buffer[currentOffset] = UInt8(l >> 24)
        currentOffset += 1
        buffer[currentOffset] = UInt8(l >> 16)
        currentOffset += 1
        buffer[currentOffset] = UInt8(l >> 8)
        currentOffset += 1
        buffer[currentOffset] = UInt8(l)
        currentOffset += 1
    }

    func writeString(_ s: String) {
        let data = s.data(using: .utf8)!
        data.copyBytes(to: &buffer[currentOffset], count: data.count)
        currentOffset += data.count
        buffer[currentOffset] = 10
        currentOffset += 1
    }

    func writeBytes(_ abyte0: [UInt8], _ i: Int, _ j: Int) {
        for k in j..<(j + i) {
            buffer[currentOffset] = abyte0[k]
            currentOffset += 1
        }
    }
    
    func writeFrameSize(_ i: Int) {
        buffer[currentOffset - i - 1] = UInt8(i)
    }
    
    func writeFrameSizeWord(_ i: Int) {
        buffer[currentOffset - i - 2] = UInt8(i >> 8)
        buffer[currentOffset - i - 1] = UInt8(i)
    }
    
    func readUnsignedByte() -> UInt8 {
        let value = buffer[currentOffset] & 0xff
        currentOffset += 1
        return value
    }

    func readSignedByte() -> Int8 {
        let value = Int8(bitPattern: buffer[currentOffset])
        currentOffset += 1
        return value
    }
    
    func readUnsignedWord() -> Int {
        currentOffset += 2
        return (Int(buffer[currentOffset - 2] & 0xff) << 8) + Int(buffer[currentOffset - 1] & 0xff)
    }
    
    func readSignedWord() -> Int {
        currentOffset += 2
        var i = (Int(buffer[currentOffset - 2] & 0xff) << 8)
        i += Int(buffer[currentOffset - 1] & 0xff)
        if i > 32767 {
            i -= 0x10000
        }
        return i
    }
    
    func readDWord() -> Int {
        currentOffset += 4
        return (Int(buffer[currentOffset - 4] & 0xff) << 24) +
        (Int(buffer[currentOffset - 3] & 0xff) << 16) +
        (Int(buffer[currentOffset - 2] & 0xff) << 8) +
        Int(buffer[currentOffset - 1] & 0xff)
    }
    
    func readQWord() -> Int64 {
        let l = Int64(readDWord()) & 0xffffffff
        let l1 = Int64(readDWord()) & 0xffffffff
        return (l << 32) + l1
    }
    
    func readQWord2() -> Int64 {
        currentOffset += 8
        return ((Int64(buffer[currentOffset - 8] & 0xff) << 56) +
                (Int64(buffer[currentOffset - 7] & 0xff) << 48) +
                (Int64(buffer[currentOffset - 6] & 0xff) << 40) +
                (Int64(buffer[currentOffset - 5] & 0xff) << 32) +
                (Int64(buffer[currentOffset - 4] & 0xff) << 24) +
                (Int64(buffer[currentOffset - 3] & 0xff) << 16) +
                (Int64(buffer[currentOffset - 2] & 0xff) << 8) +
                Int64(buffer[currentOffset - 1] & 0xff))
    }
    
    func readString() -> String {
        let start = currentOffset
        while buffer[currentOffset] != 10 {
            currentOffset += 1
        }
        let result = String(bytes: buffer[start..<currentOffset], encoding: .utf8)!
        currentOffset += 1 // Skip the newline character
        return result
    }
    
    func readBytes(_ abyte0: inout [UInt8], _ i: Int, _ j: Int) {
        for k in j..<(j + i) {
            abyte0[k] = buffer[currentOffset]
            currentOffset += 1
        }
    }
    
    func initBitAccess() {
        bitPosition = currentOffset * 8
    }
    
    func writeBits(_ numBits: Int, _ value: Int) {
        var numBits = numBits
        var value = value
        var bytePos = bitPosition >> 3
        var bitOffset = 8 - (bitPosition & 7)
        bitPosition += numBits
        while numBits > bitOffset {
            buffer[bytePos] &= ~UInt8(Stream.bitMaskOut[bitOffset])
            buffer[bytePos] |= UInt8((value >> (numBits - bitOffset)) & Stream.bitMaskOut[bitOffset])
            bytePos += 1
            numBits -= bitOffset
            bitOffset = 8
        }
        if numBits == bitOffset {
            buffer[bytePos] &= ~UInt8(Stream.bitMaskOut[bitOffset])
            buffer[bytePos] |= UInt8(value & Stream.bitMaskOut[bitOffset])
        } else {
            buffer[bytePos] &= ~UInt8(Stream.bitMaskOut[numBits] << (bitOffset - numBits))
            buffer[bytePos] |= UInt8((value & Stream.bitMaskOut[numBits]) << (bitOffset - numBits))
        }
    }
    
    func finishBitAccess() {
        currentOffset = (bitPosition + 7) / 8
    }
}
