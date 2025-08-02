//
//  NetworkMonitor.swift
//  TrafficMonitoringApp
//
//  Created by 陶锐 on 2025/8/2.
//

import Foundation
import Network

protocol NetworkMonitorDelegate: AnyObject {
    func networkSpeedDidUpdate(upload: Double, download: Double)
}

class NetworkMonitor {
    weak var delegate: NetworkMonitorDelegate?
    private var timer: Timer?
    private var previousUpload: UInt64 = 0
    private var previousDownload: UInt64 = 0
    private var lastUpdate: Date = Date()
    
    func startMonitoring() {
        // 获取初始值
        updateInitialValues()
        
        // 每秒更新一次
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateNetworkSpeed()
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateInitialValues() {
        let stats = getNetworkStats()
        previousUpload = stats.upload
        previousDownload = stats.download
        lastUpdate = Date()
    }
    
    private func updateNetworkSpeed() {
        let currentStats = getNetworkStats()
        let currentTime = Date()
        let timeDiff = currentTime.timeIntervalSince(lastUpdate)
        
        guard timeDiff > 0 else { return }
        
        let uploadDiff = currentStats.upload > previousUpload ? currentStats.upload - previousUpload : 0
        let downloadDiff = currentStats.download > previousDownload ? currentStats.download - previousDownload : 0
        
        let uploadSpeed = Double(uploadDiff) / timeDiff
        let downloadSpeed = Double(downloadDiff) / timeDiff
        
        delegate?.networkSpeedDidUpdate(upload: uploadSpeed, download: downloadSpeed)
        
        previousUpload = currentStats.upload
        previousDownload = currentStats.download
        lastUpdate = currentTime
    }
    
    private func getNetworkStats() -> (upload: UInt64, download: UInt64) {
        var upload: UInt64 = 0
        var download: UInt64 = 0
        
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                let interface = ptr!.pointee
                let addrFamily = interface.ifa_addr.pointee.sa_family
                
                if addrFamily == UInt8(AF_LINK) {
                    let name = String(cString: interface.ifa_name)
                    
                    // 过滤网络接口，排除回环接口
                    if !name.hasPrefix("lo") && !name.hasPrefix("utun") && !name.hasPrefix("awdl") {
                        let networkData = unsafeBitCast(interface.ifa_data, to: UnsafeMutablePointer<if_data>.self)
                        
                        upload += UInt64(networkData.pointee.ifi_obytes)
                        download += UInt64(networkData.pointee.ifi_ibytes)
                    }
                }
                ptr = interface.ifa_next
            }
            freeifaddrs(ifaddr)
        }
        
        return (upload: upload, download: download)
    }
}