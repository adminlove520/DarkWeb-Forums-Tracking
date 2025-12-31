#!/bin/bash
# 自动创建 4GB Swap 分区脚本

echo "📉 检测当前 Swap..."
free -h

if [ -f /swapfile ]; then
    echo "⚠️ /swapfile 已存在，跳过创建。"
else
    echo "📦 创建 4GB Swap 文件..."
    fallocate -l 4G /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=4096
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    ls -lh /swapfile
    
    echo "💾 写入 /etc/fstab 以便重启生效..."
    echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
    
    echo "✅ Swap 创建完成！"
fi

echo "📉 优化系统内存参数..."
sysctl vm.swappiness=10
echo 'vm.swappiness=10' | tee -a /etc/sysctl.conf

echo "🎉 最终内存状态："
free -h
