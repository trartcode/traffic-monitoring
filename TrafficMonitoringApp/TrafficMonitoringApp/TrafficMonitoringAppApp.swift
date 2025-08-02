//
//  TrafficMonitoringAppApp.swift
//  TrafficMonitoringApp
//
//  Created by 陶锐 on 2025/8/1.
//

import SwiftUI

@main
struct TrafficMonitoringAppApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var networkMonitor: NetworkMonitor?
    var eventMonitor: Any?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 隐藏dock图标
        NSApp.setActivationPolicy(.accessory)
        
        // 创建状态栏项
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.action = #selector(statusItemClicked)
            button.target = self
        }
        
        // 创建弹出窗口
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 220, height: 220)
        popover?.behavior = .transient
        popover?.delegate = self
        popover?.contentViewController = NSHostingController(rootView: SettingsView())
        
        // 初始化网络监控
        networkMonitor = NetworkMonitor()
        networkMonitor?.delegate = self
        networkMonitor?.startMonitoring()
        
        // 设置初始显示
        updateStatusItemTitle(upload: 0, download: 0)
    }
    
    @objc func statusItemClicked() {
        if let popover = popover {
            if popover.isShown {
                closePopover()
            } else {
                showPopover()
            }
        }
    }
    
    func showPopover() {
        if let popover = popover, let button = statusItem?.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            
            // 添加全局事件监听器来检测外部点击
            eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
                if let strongSelf = self, strongSelf.popover?.isShown == true {
                    strongSelf.closePopover()
                }
            }
        }
    }
    
    func closePopover() {
        popover?.performClose(nil)
        
        // 移除事件监听器
        if let eventMonitor = eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
            self.eventMonitor = nil
        }
    }
    
    func updateStatusItemTitle(upload: Double, download: Double) {
        DispatchQueue.main.async {
            let uploadText = self.formatSpeed(upload)
            let downloadText = self.formatSpeed(download)

            let image = self.drawStatusImage(uploadText: uploadText, downloadText: downloadText)
            self.statusItem?.button?.image = image
            self.statusItem?.button?.imagePosition = .imageOnly
        }
    }
    
    func drawStatusImage(uploadText: String, downloadText: String) -> NSImage {
        let imageWidth: CGFloat = 60
        let imageHeight: CGFloat = 22

        let image = NSImage(size: NSSize(width: imageWidth, height: imageHeight))
        image.lockFocus()

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right // 统一右对齐，避免对不齐

        let baseFont = NSFont.monospacedDigitSystemFont(ofSize: 9, weight: .regular)

        // 上行：黑色
        let uploadAttrs: [NSAttributedString.Key: Any] = [
            .font: baseFont,
            .foregroundColor: NSColor.black,
            .paragraphStyle: paragraphStyle
        ]

        // 下行：白色
        let downloadAttrs: [NSAttributedString.Key: Any] = [
            .font: baseFont,
            .foregroundColor: NSColor.white,
            .paragraphStyle: paragraphStyle
        ]

        let uploadString = "\(uploadText) ↑"
        let downloadString = "\(downloadText) ↓"

        let uploadRect = NSRect(x: 0, y: imageHeight / 2, width: imageWidth, height: imageHeight / 2)
        let downloadRect = NSRect(x: 0, y: 0, width: imageWidth, height: imageHeight / 2)

        uploadString.draw(in: uploadRect, withAttributes: uploadAttrs)
        downloadString.draw(in: downloadRect, withAttributes: downloadAttrs)

        image.unlockFocus()
        image.isTemplate = false
        return image
    }

    func formatSpeed(_ bytesPerSecond: Double) -> String {
        let value = bytesPerSecond // 直接使用字节值
        
        // 简化显示逻辑：只显示 B/s, K/s, M/s, G/s, T/s, P/s
        if value >= 1_000_000_000_000_000 {
            let pValue = value / 1_000_000_000_000_000
            if pValue >= 100 {
                return String(format: "%3.0f P/s", pValue)
            } else if pValue >= 10 {
                return String(format: "%4.1f P/s", pValue)
            } else {
                return String(format: "%5.2f P/s", pValue)
            }
        } else if value >= 1_000_000_000_000 {
            let tValue = value / 1_000_000_000_000
            if tValue >= 100 {
                return String(format: "%3.0f T/s", tValue)
            } else if tValue >= 10 {
                return String(format: "%4.1f T/s", tValue)
            } else {
                return String(format: "%5.2f T/s", tValue)
            }
        } else if value >= 1_000_000_000 {
            let gValue = value / 1_000_000_000
            if gValue >= 100 {
                return String(format: "%3.0f G/s", gValue)
            } else if gValue >= 10 {
                return String(format: "%4.1f G/s", gValue)
            } else {
                return String(format: "%5.2f G/s", gValue)
            }
        } else if value >= 1_000_000 {
            let mValue = value / 1_000_000
            if mValue >= 100 {
                return String(format: "%3.0f M/s", mValue)
            } else if mValue >= 10 {
                return String(format: "%4.1f M/s", mValue)
            } else {
                return String(format: "%5.2f M/s", mValue)
            }
        } else if value >= 1_000 {
            let kValue = value / 1_000
            if kValue >= 100 {
                return String(format: "%3.0f K/s", kValue)
            } else if kValue >= 10 {
                return String(format: "%4.1f K/s", kValue)
            } else {
                return String(format: "%5.2f K/s", kValue)
            }
        } else {
            if value >= 100 {
                return String(format: "%3.0f B/s", value)
            } else if value >= 10 {
                return String(format: "%4.1f B/s", value)
            } else {
                return String(format: "%5.2f B/s", value)
            }
        }
    }
}

extension AppDelegate: NetworkMonitorDelegate {
    func networkSpeedDidUpdate(upload: Double, download: Double) {
        updateStatusItemTitle(upload: upload, download: download)
    }
}

extension AppDelegate: NSPopoverDelegate {
    func popoverWillClose(_ notification: Notification) {
        // 弹出窗口即将关闭时，清理事件监听器
        if let eventMonitor = eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
            self.eventMonitor = nil
        }
    }
}
