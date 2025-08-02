//
//  ContentView.swift
//  TrafficMonitoringApp
//
//  Created by 陶锐 on 2025/8/1.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        SettingsView()
    }
}

struct SettingsView: View {
    @StateObject private var settings = SettingsManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题
            HStack {
                Image(systemName: "network")
                    .foregroundColor(.blue)
                Text("网速监控")
                    .font(.headline)
                    .fontWeight(.medium)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // 设置列表
            VStack(spacing: 0) {
                // 自启动设置
                SettingRow(
                    icon: "power",
                    title: "开机自启动",
                    subtitle: settings.launchAtLogin ? "已启用" : "已禁用"
                ) {
                    Toggle("", isOn: $settings.launchAtLogin)
                        .toggleStyle(SwitchToggleStyle())
                }
                
                Divider()
                    .padding(.leading, 48)
                
                // 关于
                SettingRow(
                    icon: "info.circle",
                    title: "关于",
                    subtitle: "版本 1.0.0"
                ) {
                    Button("查看") {
                        showAbout()
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.blue)
                }
                
                Divider()
                    .padding(.leading, 48)
                
                // 退出应用 - 修改为统一样式
                SettingRow(
                    icon: "power.circle",
                    title: "退出应用",
                    subtitle: "关闭网速监控"
                ) {
                    Button("退出") {
                        NSApplication.shared.terminate(nil)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.blue)
                }
            }
//            .padding(.vertical, 8)
            
            Spacer()
        }
        .frame(width: 220, height: 200)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "网速监控"
        alert.informativeText = "版本 1.0.0\n\n一个简洁的网速监控工具，显示实时上传和下载速度。\n\n单位说明：\n• B/s = 字节每秒\n• K/s = 千字节每秒\n• M/s = 兆字节每秒\n• G/s = 吉字节每秒"
        alert.addButton(withTitle: "确定")
        alert.runModal()
    }
}

struct SettingRow<Content: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    let content: Content
    
    init(icon: String, title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // 图标
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 20, height: 20)
            
            // 文本内容
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 控件
            content
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

#Preview {
    SettingsView()
}
