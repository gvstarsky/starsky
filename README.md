# starsky

Hello!!!

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