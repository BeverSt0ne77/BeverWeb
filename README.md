# 贝弗官网

Bever 信息科技官方网站（[bever.cn](https://bever.cn)）

零构建静态站点 — 单个 HTML 文件 + 内联 CSS，无 JavaScript、无打包工具。

## 目录结构

```
BeverWeb/
  index/
    index.html      # 单页静态网站（所有内容 + 内联 CSS）
    gongan.png      # 公网安备图标
  nginx/
    nginx.conf      # Nginx 反向代理配置
  deploy/
    Dockerfile      # 部署用 Docker 镜像
    deploy.sh       # 部署脚本（SCP 上传 + nginx reload）
  .env.example      # 部署环境变量模板
  README.md
```

## 部署

### 前置条件

- 本地安装 Docker 及 Docker Compose
- VPS 已安装 nginx，目录结构 `/var/www/bever/`

### 一键部署

```bash
# 1. 配置凭据
cp .env.example .env
# 编辑 .env，填入 VPS_HOST / VPS_USER / VPS_PORT

# 2. 复制 SSH 私钥
# 编辑 deploy/id_rsa，将 VPS 的 SSH 私钥粘贴进去（此文件已 git 忽略）

# 3. 一键构建 + 运行 + 部署
docker compose up --build
```

其他常用命令：

| 命令 | 作用 |
|---|---|
| `docker compose up --build` | 构建镜像并运行部署 |
| `docker compose build` | 仅构建镜像，不运行 |
| `docker compose run --rm deploy` | 仅运行部署（使用已有镜像） |
| `docker compose down --rmi local` | 清理容器及本地镜像 |

`deploy.sh` 脚本会自动完成：
1. 将 `index/` 和 `nginx/` 通过 SCP 上传到 VPS
2. SSH 登录 VPS 执行 `nginx -s reload` 使新配置生效

### 架构

```
用户浏览器 --> Nginx (80 端口)
                 |
                 +---> /（本仓库）            -- 静态 index/index.html
                 |
                 +---> /bconvert/（独立项目） -- Vue SPA
                 |
                 +---> /bconvert/api/（独立） -- Java 后端 (localhost:8080)
```
