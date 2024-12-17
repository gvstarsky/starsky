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

# 创建临时目录（如果不存在）
mkdir -p "$TEMP_DIR"

# 压缩并生成日志
ARCHIVE_NAME="${TEMP_DIR}/$(basename "$SOURCE_DIR")-${DATE}.tar.gz"
echo "[$(date +"%Y-%m-%d_%H-%M-%S")] Compression started" >> "$LOG_FILE"
tar -czf "$ARCHIVE_NAME" "$SOURCE_DIR" >> /dev/null 2>&1
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

# 检查上传是否成功
if [ $UPLOAD_STATUS -eq 0 ]; then
    echo "[$(date +"%Y-%m-%d_%H-%M-%S")] Upload of $ARCHIVE_NAME completed successfully" >> "$LOG_FILE"
    rm "$ARCHIVE_NAME"  # 上传成功后删除本地文件
else
    echo "[$(date +"%Y-%m-%d_%H-%M-%S")] Failed to upload $ARCHIVE_NAME" >> "$LOG_FILE"
fi

# 记录备份过程完成状态
if [ $UPLOAD_STATUS -eq 0 ]; then
    echo "[$(date +"%Y-%m-%d_%H-%M-%S")] Backup process completed successfully" >> "$LOG_FILE"
else
    echo "[$(date +"%Y-%m-%d_%H-%M-%S")] Backup process failed" >> "$LOG_FILE"
fi
