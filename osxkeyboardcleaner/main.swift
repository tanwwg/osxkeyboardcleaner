//
//  main.swift
//  osxkeyboardcleaner
//
//  Created by Tan Thor Jen on 19/9/16.
//  Copyright © 2016 Tan Thor Jen. All rights reserved.
//

import Foundation

print("osxkeyboardcleaner: Please run as root to trap keyboard")
print("⌘+Q to quit")

func myCGEventCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    if [.keyUp].contains(type) {
        let flags = event.flags
        
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
//        print("cb \(keyCode)")
        
        if keyCode == 12 && ((flags.rawValue & CGEventFlags.maskCommand.rawValue) == CGEventFlags.maskCommand.rawValue) {
            exit(0)
        }
    }
    return nil
}

//        let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue)
let eventMask =
    (1 << CGEventType.keyDown.rawValue) |
    (1 << CGEventType.keyUp.rawValue) |
    (1 << 14) |
    (1 <<  CGEventType.leftMouseUp.rawValue) |
    (1 <<  CGEventType.leftMouseDown.rawValue) |
    (1 <<  CGEventType.rightMouseDown.rawValue) |
    (1 <<  CGEventType.rightMouseUp.rawValue)

guard let eventTap = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                       place: .headInsertEventTap,
                                       options: .defaultTap,
                                       eventsOfInterest: CGEventMask(eventMask),
                                       callback: myCGEventCallback,
                                       userInfo: nil) else
{
    print("Failed to create event tap")
    exit(1)
}

let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
CGEvent.tapEnable(tap: eventTap, enable: true)
CFRunLoopRun()

