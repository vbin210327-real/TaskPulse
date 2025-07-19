#!/usr/bin/env python3
"""
应用选择的新logo设计到TaskPulse应用中
"""

import subprocess
import os
import sys

def apply_logo_design(design_number):
    """
    应用选择的logo设计
    """
    design_file = f"logo_design_{design_number}.png"
    
    if not os.path.exists(design_file):
        print(f"❌ 找不到设计文件: {design_file}")
        return False
    
    print(f"🎨 正在应用设计 {design_number}...")
    
    # 1. 更新应用图标
    print("📱 更新应用图标...")
    iconset_dir = "TaskPulse/Assets.xcassets/AppIcon.appiconset"
    sizes = [20, 29, 40, 58, 60, 76, 80, 87, 120, 152, 167, 180, 1024]
    
    for size in sizes:
        output_file = f"{iconset_dir}/Icon-{size}.png"
        cmd = f"sips -z {size} {size} '{design_file}' --out '{output_file}'"
        
        try:
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
            if result.returncode == 0:
                print(f"✅ 已生成: Icon-{size}.png")
            else:
                print(f"❌ 生成失败: Icon-{size}.png")
        except Exception as e:
            print(f"❌ 生成出错: Icon-{size}.png - {e}")
    
    # 2. 更新应用内logo
    print("🖼️  更新应用内logo...")
    logo_imageset_dir = "TaskPulse/Assets.xcassets/AppLogo.imageset"
    
    try:
        subprocess.run(f"sips -z 100 100 '{design_file}' --out '{logo_imageset_dir}/AppLogo.png'", shell=True)
        subprocess.run(f"sips -z 200 200 '{design_file}' --out '{logo_imageset_dir}/AppLogo@2x.png'", shell=True)
        subprocess.run(f"sips -z 300 300 '{design_file}' --out '{logo_imageset_dir}/AppLogo@3x.png'", shell=True)
        print("✅ 应用内logo已更新")
    except Exception as e:
        print(f"❌ 更新应用内logo失败: {e}")
        return False
    
    # 3. 备份当前logo
    backup_name = f"logo_backup_{design_number}.png"
    if os.path.exists("logo_no_bg.png"):
        os.rename("logo_no_bg.png", backup_name)
        print(f"💾 已备份当前logo为: {backup_name}")
    
    # 4. 设置新logo为当前logo
    subprocess.run(f"cp '{design_file}' logo_no_bg.png", shell=True)
    
    print(f"🎉 设计 {design_number} 已成功应用！")
    return True

def show_designs():
    """
    显示所有可用的设计
    """
    designs = {
        1: "增强版脉搏波 - 更流畅的曲线和蓝色渐变",
        2: "圆形脉搏 - 围绕圆周的脉搏波形",
        3: "分子结构脉搏 - 科技感的节点连接设计",
        4: "简约波形 - 极简但有力的粉色设计",
        5: "任务脉动融合 - 复选框与脉搏线的完美结合 ⭐",
        6: "列表心跳 - 任务列表呈现心跳形状 ⭐",
        7: "进度脉动 - 进度条呈现脉搏波形 ⭐"
    }
    
    print("🎨 可用的logo设计:")
    for num, desc in designs.items():
        file_exists = "✅" if os.path.exists(f"logo_design_{num}.png") else "❌"
        print(f"   {num}. {desc} {file_exists}")
    
    print("\n⭐ 标记的设计专门结合了任务管理和脉动元素")
    return designs

if __name__ == "__main__":
    print("🚀 TaskPulse Logo 应用工具\n")
    
    # 显示可用设计
    designs = show_designs()
    
    print("\n💡 使用方法:")
    print("   python3 apply_new_logo.py [设计编号]")
    print("   例如: python3 apply_new_logo.py 5")
    
    if len(sys.argv) != 2:
        print("\n❓ 请选择一个设计编号 (1-7)")
        sys.exit(1)
    
    try:
        design_num = int(sys.argv[1])
        if design_num not in designs:
            print(f"❌ 无效的设计编号: {design_num}")
            print("请选择 1-7 之间的数字")
            sys.exit(1)
        
        print(f"\n🎯 您选择了设计 {design_num}: {designs[design_num]}")
        
        if apply_logo_design(design_num):
            print("\n✨ Logo更新完成！")
            print("📱 请在Xcode中重新编译应用来查看新logo")
        else:
            print("\n❌ Logo更新失败")
            
    except ValueError:
        print("❌ 请输入有效的数字 (1-7)")
        sys.exit(1) 