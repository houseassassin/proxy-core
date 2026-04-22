# 🚀 Proxy-Core v2.1.0 Release Notes

**Release Date:** April 22, 2026  
**Author:** houseassassin  
**Repository:** https://github.com/houseassassin/proxy-core

---

## 📦 What's New in v2.1.0

### ✨ Major Features

#### 1. MTProxy Support for Telegram
- Full MTProxy installation and configuration
- Interactive management interface (`mtproxy-manager.sh`)
- QR code generation for mobile devices
- Connection link generation
- Secret regeneration
- Port management
- Statistics and monitoring
- Service logs viewer

#### 2. Reverse Proxy Selection
- Choose between **Nginx** or **Caddy**
- Nginx: High performance, production-ready
- Caddy: Automatic HTTPS, simple configuration
- Interactive selection during installation
- Optimized configurations for each

#### 3. Selfsteal Traffic Masking
- Mask proxy server as regular website
- Three template options:
  - Random popular site (Wikipedia, GitHub, etc.)
  - Custom URL
  - Local HTML file
- Automatic Nginx configuration
- Perfect for bypassing censorship

### 🔧 Improvements

- **Enhanced Menu System**: Better component selection and navigation
- **Multi-language Support**: English and Russian interfaces
- **Better Error Handling**: Improved logging and error messages
- **SSL Management**: Support for Let's Encrypt, Cloudflare DNS, Gcore DNS
- **BBR Optimization**: Automatic TCP BBR configuration
- **Swap Management**: Auto-creation for low-memory systems
- **Firewall Configuration**: Automatic UFW/firewalld setup

### 📖 Documentation

- **README-v2.md**: Comprehensive documentation with:
  - Beautiful ASCII art header
  - Installation guides for all panels
  - MTProxy management instructions
  - Reverse proxy comparison
  - Selfsteal setup guide
  - Security recommendations
  - Troubleshooting section

- **CONTRIBUTING.md**: Guidelines for contributors
- **PUBLISH.md**: Step-by-step GitHub publication guide

---

## 🎯 Supported Panels

| Panel | Protocols | Status |
|-------|-----------|--------|
| **WireGuard** | WireGuard | ✅ Full support |
| **3x-ui** | VLESS, VMess, Trojan, Shadowsocks, XTLS | ✅ Full support |
| **Remnawave** | Multi-protocol | ✅ Full support |
| **Hysteria2** | Hysteria2 | ✅ Full support |
| **MTProxy** | MTProxy | ✨ NEW in v2.1.0 |

---

## 💻 Supported Operating Systems

- Ubuntu 18.04, 20.04, 22.04, 24.04
- Debian 10, 11, 12
- CentOS 7, 8, 9
- RHEL 7, 8, 9
- Fedora 35+

---

## 📥 Installation

### Quick Install (One Command)

```bash
bash <(curl -Ls https://raw.githubusercontent.com/houseassassin/proxy-core/main/install-advanced-v2.sh)
```

### Manual Install

```bash
git clone https://github.com/houseassassin/proxy-core.git
cd proxy-core
chmod +x *.sh
sudo ./install-advanced-v2.sh
```

---

## 🔒 Security Features

- ✅ Automatic firewall configuration (UFW/firewalld)
- ✅ SSL/TLS certificates (Let's Encrypt, Cloudflare, Gcore)
- ✅ BBR TCP optimization
- ✅ Secure password generation
- ✅ Selfsteal traffic masking
- ✅ Regular security updates support

---

## 📊 Project Statistics

- **Total Files**: 11 scripts + documentation
- **Lines of Code**: ~2,500+ lines of Bash
- **Languages**: English, Russian
- **License**: MIT

---

## 🎮 Management Tools

### Main Installer
```bash
sudo ./install-advanced-v2.sh
```

### MTProxy Manager
```bash
sudo ./mtproxy-manager.sh
```

### WireGuard Manager
```bash
sudo ./wg-manager.sh
```

### General Panel Manager
```bash
sudo ./manage.sh
```

---

## 🚀 Ready to Publish

### Git Status
- ✅ All files committed
- ✅ Version tagged (v2.1.0)
- ✅ Documentation complete
- ✅ License included (MIT)
- ✅ .gitignore configured

### Next Steps

1. **Push to GitHub**:
   ```bash
   git push origin main
   git push origin v2.1.0
   ```

2. **Create GitHub Release**:
   - Go to: https://github.com/houseassassin/proxy-core/releases/new
   - Select tag: v2.1.0
   - Title: "Proxy-Core v2.1.0 - MTProxy, Reverse Proxy, Selfsteal"
   - Copy description from this file

3. **Configure Repository**:
   - Add topics: `vpn`, `proxy`, `wireguard`, `xray`, `3x-ui`, `remnawave`, `hysteria2`, `mtproxy`, `docker`, `bash`, `automation`, `installer`, `linux`
   - Enable Issues and Wiki
   - Add description and website URL

4. **Promote**:
   - Share on Reddit (r/selfhosted, r/VPN, r/linux)
   - Post on Telegram channels
   - Submit to Awesome Lists

---

## 🤝 Credits

Based on best practices from:
- [3dp-manager](https://github.com/denpiligrim/3dp-manager)
- [remnawave-reverse-proxy](https://github.com/eGamesAPI/remnawave-reverse-proxy)
- [remnawave-scripts](https://github.com/DigneZzZ/remnawave-scripts)
- [RemnaSetup](https://github.com/Capybara-z/RemnaSetup)

---

## 📝 License

MIT License - Free to use and modify

---

## 💬 Support

- **GitHub Issues**: https://github.com/houseassassin/proxy-core/issues
- **Telegram**: [@houseassassin](https://t.me/houseassassin)

---

**Made with ❤️ by houseassassin**

If this project helped you, please ⭐ star it on GitHub!
