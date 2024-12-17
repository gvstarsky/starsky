### 安装rclone  
```bash
curl https://rclone.org/install.sh | sudo bash
```  
### 配置rclone  
#### 1.直接编辑配置文件  
```bash
mkdir -p ~/.config/rclone
vim ~/.config/rclone/rclone.conf
```  
#### 2.通过命令行配置  
```bash
rclone config
```  
输入`n`然后按照需要一步步配置  
### 上传脚本  
https://raw.githubusercontent.com/gvstarsky/starsky/main/rclone/backup.sh  
替换掉脚本中的SOURCE_DIR和RCLONE_REMOTE文件夹等参数  
### 定时脚本  
打开定时配置  
```bash
crontab -e
```  
写入定时配置，例  
```bash
0 2 * * * /root/bash/backup.sh
```  
这会在每天凌晨 2 点运行位于/root/bash/backup.sh的上传脚本  
