#!/bin/bash

# 需要备份的文件夹路径
SOURCE_DIR="/opt/data/"

# 获取脚本所在目录路径
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# 备份文件临时存放路径
TEMP_DIR="$SCRIPT_DIR/temp"

# rclone配置名称和目标路径
RCLONE_REMOTES=(
    "r2:backup/data"
    "od:backup/data"
)

# 日志文件路径
LOG_FILE="$SCRIPT_DIR/backup.log"

# 保留的最大备份数量
MAX_BACKUPS=3

# 当前时间，用于备份文件命名
DATE=$(date +"%Y-%m-%d_%H-%M-%S")

# Telegram 配置
TELEGRAM_BOT_TOKEN="YOUR_BOT_TOKEN"
TELEGRAM_CHAT_ID="YOUR_CHAT_ID"

# 创建临时目录（如果不存在）
mkdir -p "$TEMP_DIR"

# 压缩并生成日志
ARCHIVE_NAME="${TEMP_DIR}/$(basename "$SOURCE_DIR")-${DATE}.tar.gz"
echo "[$(date +"%Y-%m-%d_%H-%M-%S")] Compression started" >> "$LOG_FILE"
tar -czf "$ARCHIVE_NAME" -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")" >> /dev/null 2>&1
echo "[$(date +"%Y-%m-%d_%H-%M-%S")] Compression completed" >> "$LOG_FILE"

# 删除云端最早的备份（超过最大保留数量）
for REMOTE in "${RCLONE_REMOTES[@]}"; do
    EXISTING_BACKUPS=$(rclone lsf "$REMOTE" | grep "$(basename "$SOURCE_DIR")-.*\.tar\.gz" | sort)
    NUM_BACKUPS=$(echo "$EXISTING_BACKUPS" | wc -l)

    if [ "$NUM_BACKUPS" -gt "$MAX_BACKUPS" ]; then
        NUM_TO_DELETE=$((NUM_BACKUPS - MAX_BACKUPS))
        BACKUPS_TO_DELETE=$(echo "$EXISTING_BACKUPS" | head -n "$NUM_TO_DELETE")
        
        for BACKUP in $BACKUPS_TO_DELETE; do
            echo "[$(date +"%Y-%m-%d_%H-%M-%S")] Deleting old backup: $BACKUP from $REMOTE" >> "$LOG_FILE"
            rclone delete "$REMOTE/$BACKUP" >> "$LOG_FILE" 2>&1
        done
    fi
done

# 上传新的备份
UPLOAD_STATUS=0
for REMOTE in "${RCLONE_REMOTES[@]}"; do
    echo "[$(date +"%Y-%m-%d_%H-%M-%S")] Starting upload of $ARCHIVE_NAME to $REMOTE" >> "$LOG_FILE"
    echo "本次运行的命令为：rclone copy \"$ARCHIVE_NAME\" \"$REMOTE/\" --log-file=\"$LOG_FILE\" --log-level INFO -–s3-no-check-bucket" >> "$LOG_FILE"
    rclone copy "$ARCHIVE_NAME" "$REMOTE/" --s3-no-check-bucket --log-file="$LOG_FILE" --log-level INFO
    UPLOAD_STATUS=$((UPLOAD_STATUS + $?))
done

# 添加发送 Telegram 消息的函数
send_telegram_message() {
    local message="$1"
    # 检查是否配置了 Telegram
    if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ] && [ "$TELEGRAM_BOT_TOKEN" != "YOUR_BOT_TOKEN" ] && [ "$TELEGRAM_CHAT_ID" != "YOUR_CHAT_ID" ]; then
        message=$(printf '%b' "$message")  # 正确处理转义字符
        curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
            -d chat_id="${TELEGRAM_CHAT_ID}" \
            -d text="${message}" >> /dev/null
    fi
}

# 检查上传是否成功
if [ $UPLOAD_STATUS -eq 0 ]; then
    success_message="✅ $(basename "$SOURCE_DIR") 备份成功完成！\n\n📁 文件名：$(basename "$ARCHIVE_NAME")\n⏱ 完成时间：$(date +"%Y-%m-%d %H:%M:%S")"
    send_telegram_message "$success_message"
    echo "[$(date +"%Y-%m-%d_%H-%M-%S")] Upload of $ARCHIVE_NAME completed successfully" >> "$LOG_FILE"
    rm "$ARCHIVE_NAME"  # 上传成功后删除本地文件
else
    error_message="❌ $(basename "$SOURCE_DIR") 备份失败！\n\n📁 文件名：$(basename "$ARCHIVE_NAME")\n⏱ 失败时间：$(date +"%Y-%m-%d %H:%M:%S")"
    send_telegram_message "$error_message"
    echo "[$(date +"%Y-%m-%d_%H-%M-%S")] Failed to upload $ARCHIVE_NAME" >> "$LOG_FILE"
fi

# 记录备份过程完成状态
if [ $UPLOAD_STATUS -eq 0 ]; then
    echo "[$(date +"%Y-%m-%d_%H-%M-%S")] Backup process completed successfully" >> "$LOG_FILE"
else
    echo "[$(date +"%Y-%m-%d_%H-%M-%S")] Backup process failed" >> "$LOG_FILE"
fi
