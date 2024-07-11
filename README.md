### 初次运行 Git 前的配置

#### 设置用户名和邮箱

```
git config --global user.name "用户名"
```

```
git config --global user.email <邮箱>
```

再次强调，如果使用了 `--global` 选项，那么该命令只需要运行一次，因为之后无论你在该系统上做任何事情， Git 都会使用那些信息。 当你想针对特定项目使用不同的用户名称与邮件地址时，可以在那个项目目录下运行没有 `--global` 选项的命令来配置。

你可以通过以下命令查看所有的配置以及它们所在的文件：

```
git config --list --show-origin
```

#### 生成新 SSH 密钥

粘贴以下文本，将示例中使用的电子邮件替换为 GitHub 电子邮件地址。

```
ssh-keygen -t ed25519 -C "your_email@example.com"
```

注意：如果你使用的是不支持 Ed25519 算法的旧系统，请使用以下命令：
```
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

#### 检查配置信息

如果想要检查你的配置，可以使用 `git config --list` 命令来列出所有 Git 当时能找到的配置：

```
git config --list
```

你可以通过输入 `git config <key>`： 来检查 Git 的某一项配置：

```
git config <key>
```

### Git 基础

#### 初始化仓库

```
git init
```

#### 文件追踪(添加到暂存区)

```
git add <文件或目录>
```

#### 提交更新

```
git commit -m '提交说明'
```

#### 跳过使用暂存区域

尽管使用暂存区域的方式可以精心准备要提交的细节，但有时候这么做略显繁琐。 Git 提供了一个跳过使用暂存区域的方式， 只要在提交的时候，给 `git commit` 加上 `-a` 选项，Git 就会自动把所有已经跟踪过的文件暂存起来一并提交，从而跳过 `git add` 步骤

```
git commit -a -m 'added new benchmarks'
```

#### 克隆现有的仓库

```
git clone <url>
```

#### 检查当前文件状态

```
git status
```

```
git diff
```

#### 移除文件

```
git rm
```

#### 移动文件

```console
git mv file_from file_to
```

#### 查看提交历史

```
git log
```

#### 查看远程仓库

```
git remote -v
```

#### 添加远程仓库

```
git remote add <shortname> <url>
```

#### 从远程仓库中抓取与拉取

```
git fetch <remote>
```

必须注意 `git fetch` 命令只会将数据下载到你的本地仓库——它并不会自动合并或修改你当前的工作。 当准备好时你必须手动将其合并入你的工作。

运行 `git pull` 通常会从最初克隆的服务器上抓取数据并自动尝试合并到当前所在的分支。

#### 推送到远程仓库

```
git push <remote> <branch>
```
将本地的 `master` 分支推送到 `origin` 远程仓库，并将本地的 `master` 分支设置为跟踪远程的 `origin/master` 分支。以后你只需使用 `git push` 或 `git pull`，而不必每次都指定远程仓库和分支名。

```
git push -u origin master
```

#### 查看某个远程仓库

```
git remote show <remote>
```

#### 远程仓库的重命名与移除

你可以运行 `git remote rename` 来修改一个远程仓库的简写名，想要将 `pb` 重命名为 `paul`，可以用 `git remote rename pb paul`

```
git remote rename
```

如果因为一些原因想要移除一个远程仓库——你已经从服务器上搬走了或不再想使用某一个特定的镜像了， 又或者某一个贡献者不再贡献了——可以使用 `git remote remove` 或 `git remote rm` ：

```
git remote remove
```

#### 分支创建

```
git branch <分支名>
```

#### 分支切换

```
git checkout <分支名>
```

想要新建一个分支并同时切换到那个分支上，你可以运行一个带有 `-b` 参数的 `git checkout` 命令

```
$ git checkout -b iss53
Switched to a new branch "iss53"
```

它是下面两条命令的简写：

```
$ git branch iss53
$ git checkout iss53
```

#### 分支查看

```
git branch
```

如果需要查看每一个分支的最后一次提交，可以运行 `git branch -v` 命令

```
git branch -v
```

#### 分支删除

```
git branch -d <分支名>
```

强制删除

```
git branch -D <分支名>
```

#### 跟踪分支

当克隆一个仓库时，它通常会自动地创建一个跟踪 `origin/master` 的 `master` 分支。 然而，如果你愿意的话可以设置其他的跟踪分支，或是一个在其他远程仓库上的跟踪分支，又或者不跟踪 `master` 分支。 最简单的实例就是像之前看到的那样，运行 `git checkout -b <branch> <remote>/<branch>`。

```
git checkout -b <branch> <remote>/<branch>
```

#### 删除远程分支

可以运行带有 `--delete` 选项的 `git push` 命令来删除一个远程分支。 如果想要从服务器上删除 `serverfix` 分支，运行下面的命令：

```
git push origin --delete <远程分支名>
```

