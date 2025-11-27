# DNS Automatic Traffic Splitting Service

![Build Status](https://github.com/Hamster-Prime/DNS_automatic_traffic_splitting/actions/workflows/release.yml/badge.svg)
![Docker Image](https://github.com/Hamster-Prime/DNS_automatic_traffic_splitting/actions/workflows/docker.yml/badge.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

这是一个高性能、支持多协议接入、自动根据Geo分流国内外的 DNS 代理服务，使用 Go 语言编写。

## ✨ 核心特性

*   **多协议接入**: 
    *   标准 UDP/TCP DNS (:53)
    *   DNS over TLS (DoT, :853)
    *   DNS over QUIC (DoQ, :853)
    *   DNS over HTTPS (DoH, :443, 支持 HTTP/2 和 HTTP/3)
*   **智能分流**: 
    *   基于 `GeoIP.dat` 和 `GeoSite.dat` 自动区分中国大陆和海外域名。
    *   支持自定义 Hosts 文件 (`hosts.txt`)。
    *   支持自定义分流规则文件 (`rule.txt`)。
    *   **ECS 支持**: 自动为国内/海外上游附加预配置的 ECS IP，优化 CDN 解析。
*   **高性能上游客户端**: 
    *   **并发竞速**: 海外查询支持并发向多个上游发起请求，最快者胜。
    *   **Bootstrap**: 自动使用 Bootstrap DNS 解析上游 DoH/DoT 域名。
    *   **连接复用 (RFC 7766)**: 支持 TCP/DoT 连接复用 (Pipelining)。
    *   **HTTP/3**: DoH 上游支持 HTTP/3 (QUIC)。
*   **自动证书管理**: 
    *   集成 Let's Encrypt，只需配置域名即可自动申请和续期 TLS 证书。
*   **自动资源更新**: 
    *   启动时自动检查并下载最新的 `GeoIP.dat` 和 `GeoSite.dat`。

## 🚀 快速开始 (Linux 一键安装)

使用 root 用户运行以下命令：

```bash
bash <(curl -sL https://raw.githubusercontent.com/Hamster-Prime/DNS_automatic_traffic_splitting/main/install.sh)
```

该脚本会自动：
1.  下载最新版本的二进制文件。
2.  配置 Systemd 服务实现开机自启。
3.  下载示例配置文件。

## 🛠️ 手动安装

### 1. 下载

前往 [Releases](https://github.com/Hamster-Prime/DNS_automatic_traffic_splitting/releases) 页面下载对应架构的二进制文件。

### 2. 准备文件

在程序运行目录下，确保有以下文件（首次运行会自动下载 Geo 数据）：

*   `config.yaml`: 配置文件 (参考 `config.yaml.example`)
*   `hosts.txt`: (可选) 自定义 Hosts
*   `rule.txt`: (可选) 自定义分流规则

### 3. 运行

```bash
# 赋予执行权限
chmod +x doh-autoproxy-linux-amd64

# 运行
./doh-autoproxy-linux-amd64
```

## 🐳 Docker 部署

镜像托管在 Docker Hub: `weijiaqaq/dns_automatic_traffic_splitting`

### 使用 Docker CLI

```bash
docker run -d \
  --name dns-proxy \
  --restart always \
  --network host \
  -v $(pwd)/config.yaml:/app/config.yaml \
  -v $(pwd)/certs:/app/certs \
  -v $(pwd)/hosts.txt:/app/hosts.txt \
  -v $(pwd)/rule.txt:/app/rule.txt \
  weijiaqaq/dns_automatic_traffic_splitting
```

*注意：建议使用 `--network host` 模式以获得最佳网络性能，特别是对于 UDP 服务。*

### 使用 Docker Compose

```yaml
version: '3' 
services:
  dns:
    image: weijiaqaq/dns_automatic_traffic_splitting:latest
    container_name: dns-proxy
    restart: always
    network_mode: "host"
    volumes:
      - ./config.yaml:/app/config.yaml
      - ./certs:/app/certs
      - ./hosts.txt:/app/hosts.txt
      - ./rule.txt:/app/rule.txt
```

## ⚙️ 配置说明

### 基础配置 (`config.yaml`)

```yaml
listen:
  dns_udp: ":53"
  doh: ":443"

upstreams:
  overseas:
    - address: "https://1.1.1.1/dns-query"
      protocol: "doh"
      http3: true
```

### 自定义规则

**`hosts.txt`**:
```text
192.168.1.1 myrouter.lan
0.0.0.0 ads.badsite.com
```

**`rule.txt`**:
```text
google.com overseas
baidu.com cn
```

## 📝 License

本项目采用 [MIT 许可协议](LICENSE)