//
//  Message.swift
//  WebSocket
//
//  Created by Ion Socol on 3/9/25.
//

import Foundation
import MessageKit

public struct Message: MessageType {
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}

public struct Sender: SenderType {
    public let senderId: String
    public let displayName: String
}

