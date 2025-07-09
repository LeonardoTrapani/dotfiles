# 🚀 Leonardo Trapani's Dotfiles

> **A complete, modern Arch Linux development environment with Hyprland, Neovim, and Tmux**

This repository contains my personal dotfiles and system configuration, providing a fully-featured development environment optimized for productivity and aesthetics. Built on top of [HyDE](HyDE.md) with extensive customizations and improvements.

---

## ✨ Features

### 🎨 **Wayland Desktop Environment**
- **Hyprland** - Modern tiling compositor with smooth animations
- **Waybar** - Highly customizable status bar
- **Rofi** - Application launcher and window switcher  
- **Dunst** - Notification daemon
- **SDDM** - Display manager with custom themes

### 💻 **Development Tools**
- **Neovim** - Feature-rich editor with LazyVim configuration
- **Tmux** - Terminal multiplexer with extensive plugin ecosystem
- **Kitty** - GPU-accelerated terminal emulator
- **Git** - Version control with optimized configuration
- **Zsh/Fish** - Modern shells with Starship prompt

### 🎯 **Productivity Enhancements**
- **Clipboard Management** - Persistent clipboard with cliphist
- **Screenshot Tools** - Grim, Slurp, and Satty for annotations
- **Color Picker** - Hyprpicker for design work
- **File Management** - Dolphin with enhanced thumbnails
- **Media Controls** - Playerctl for system-wide media management

### 🔐 **Environment Management**
- **Secure API Key Storage** - Private environment variables management
- **AWS Credentials Integration** - Automatic AWS credentials file generation from environment variables
- **Template System** - Pre-configured templates for common services
- **Automatic Loading** - Environment variables loaded on shell startup
- **Git Security** - Sensitive files automatically excluded from commits

### 🌈 **Theming System**
- **Dynamic Theming** - Wallpaper-based color generation with Wallbash
- **Multiple Themes** - Catppuccin, Rose Pine, Tokyo Night, and more
- **Font Collection** - JetBrains Mono, Cascadia Code, Maple Mono, and more
- **Icon Themes** - Material Design and custom icon sets
- **Browser Themes** - Firefox extensions and custom configurations

---

## 🏗️ Architecture

```
📁 dotfiles/
├── 🔧 Scripts/           # Installation and management scripts
│   ├── install.sh        # Main installation script with interactive prompts
│   ├── *.lst            # Package lists (core, extra, fonts, themes)
│   └── restore_*.sh     # Configuration restoration scripts
├── 📦 Stow/             # Dotfiles managed by GNU Stow
│   ├── nvim/            # Neovim configuration (LazyVim-based)
│   ├── tmux/            # Tmux configuration with plugins
│   └── git/             # Git configuration and aliases
├── ⚙️ Configs/          # System configuration files
│   ├── .config/         # Application configurations
│   │   ├── hypr/        # Hyprland compositor settings
│   │   ├── waybar/      # Status bar configuration
│   │   ├── rofi/        # Application launcher themes
│   │   └── ...          # Other app configs
│   └── .local/          # Local binaries and data
├── 🎨 Source/           # Assets and themes
│   ├── arcs/            # Compressed theme packages
│   └── assets/          # Images, icons, and media
└── 📋 trapani.sh        # Interactive setup script
```

---

## 🚀 Quick Start

### Prerequisites
- **Arch Linux** (or Arch-based distribution)
- **Git** installed
- **Internet connection** for package downloads

### Installation

1. **Clone the repository:**
```bash
git clone https://github.com/leonardotrapani/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

2. **Run the interactive setup:**
```bash
./trapani.sh
```

**Choose your installation method:**
- `1` - Stow dotfiles only  
- `2` - Run installation scripts only
- `3` - Setup environment variables (API keys)
- `4` - **Complete setup (recommended)**

### Alternative Installation Methods

**Automated (no prompts):**
```bash
./trapani.sh -d
```

**Selective installation:**
```bash
./trapani.sh -s     # Only Stow dotfiles
./trapani.sh -i     # Only installation scripts
./trapani.sh -e     # Only environment variables setup
```

**Test run (dry run):**
```bash
./trapani.sh -n
```

---

## 🛠️ Management

### **Environment Variables**
```bash
# Setup private environment (API keys, secrets)
./Scripts/manage_env.sh init         # Initialize environment management
./Scripts/manage_env.sh edit         # Edit your API keys
./Scripts/manage_env.sh show         # Show current environment status
./Scripts/manage_env.sh validate     # Validate configuration
./Scripts/manage_env.sh backup       # Backup environment files
./Scripts/manage_env.sh aws-creds    # Generate AWS credentials from environment variables
```

#### **AWS Credentials Management**
The environment manager now supports automatic AWS credentials file generation:

- **Environment Variables**: Set `AWS_ACCESS_KEY_ID_DEV`, `AWS_SECRET_ACCESS_KEY_DEV`, `AWS_ACCESS_KEY_ID_PROD`, `AWS_SECRET_ACCESS_KEY_PROD`
- **Profile Generation**: Automatically creates `~/.aws/credentials` with `leonardo-datapizza-dev` and `leonardo-trapani-prod` profiles
- **Secure Storage**: Uses environment variables instead of hardcoded credentials
- **Interactive Setup**: Prompts during setup to generate credentials file

### **Package Management**
- `Scripts/pkg_core.lst` - Essential system packages
- `Scripts/pkg_extra.lst` - Additional optional packages
- `Scripts/restore_fnt.lst` - Font packages
- Custom package lists supported via install scripts

---

## 📋 What Gets Installed

### **Core System Components**
- **Audio:** PipeWire, WirePlumber, PulseAudio compatibility
- **Network:** NetworkManager with GUI applet
- **Bluetooth:** Bluez with Blueman manager
- **Display:** Hyprland, SDDM, brightness controls

### **Development Environment**
- **Editors:** Neovim (LazyVim), VS Code, Vim
- **Terminals:** Kitty with custom themes
- **Shell:** Zsh with Oh-My-Zsh or Fish with modern tools
- **Version Control:** Git with enhanced configuration

### **Applications**
- **Browser:** Firefox with extensions and custom config
- **File Manager:** Dolphin with enhanced features
- **Media:** Screenshot tools, color picker, media controls
- **Utilities:** Archive manager, system monitors

---

## 🎨 Customization

### **Theming**
The system includes a powerful theming engine that automatically generates color schemes from wallpapers:

- **Wallbash Integration** - Dynamic color generation
- **Multi-app Support** - Themes apply to terminal, editor, bar, etc.
- **Theme Switching** - Hot-swappable themes without restart
- **Custom Themes** - Easy theme creation and sharing

### **Configuration Files**
All configuration files are organized and well-documented:
- Hyprland configs in `Configs/.config/hypr/`
- Application configs follow XDG Base Directory spec
- Easy to modify and extend

---

## 🔧 Advanced Usage

### **Environment Variables (API Keys)**
```bash
# Quick setup for API keys
./trapani.sh -e                        # Setup environment management
./Scripts/manage_env.sh edit          # Add your API keys

# Example: Adding Anthropic API key
export ANTHROPIC_API_KEY="your_actual_key_here"
export OPENAI_API_KEY="your_openai_key_here"
export GITHUB_TOKEN="your_github_token_here"

# AWS Profile-specific credentials
export AWS_ACCESS_KEY_ID_DEV="your_dev_access_key"
export AWS_SECRET_ACCESS_KEY_DEV="your_dev_secret_key"
export AWS_ACCESS_KEY_ID_PROD="your_prod_access_key"
export AWS_SECRET_ACCESS_KEY_PROD="your_prod_secret_key"
```

#### **AWS Credentials Integration**
```bash
# Generate AWS credentials file from environment variables
./Scripts/manage_env.sh aws-creds

# Use with AWS CLI
aws --profile leonardo-datapizza-dev s3 ls
aws --profile leonardo-trapani-prod ec2 describe-instances
```

### **Custom Package Installation**
```bash
# Add your packages to a custom list
echo "your-package" >> my-packages.lst

# Install with custom packages
./Scripts/install.sh my-packages.lst
```

### **Theme Development**
```bash
# Install theme development tools
./Scripts/themepatcher.sh

# Create custom themes in ~/.config/hyde/themes/
```

### **Dotfiles Management**
```bash
# Add new dotfiles to Stow
mkdir -p Stow/myapp/.config/myapp
# Add your configs...
stow -t ~ myapp
```

---

## 🛟 Troubleshooting

### **Common Issues**

**Installation fails:**
```bash
# Check logs
less ~/.cache/hyde/logs/$(ls -t ~/.cache/hyde/logs/ | head -1)

# Retry with verbose output
./trapani.sh -n  # Dry run first
```

**Environment variables not loading:**
```bash
# Check if private environment file exists
ls ~/.config/environment/private.env

# Validate configuration
./Scripts/manage_env.sh validate

# Restart shell to reload environment
exec $SHELL
```
---

## 🗺️ Roadmap

- [x] Complete HyDE customization and branding
- [x] Interactive setup system with options
- [x] Improved documentation and README
- [ ] Move most of the files into the Stow directory and symlinked
- [ ] Make a cli package or command that I can use so I don't run ./trapani.sh (maybe installable from yay)
- [ ] Neovim and Tmux theme integration with system theme changes

---

## 🤝 Contributing

Feel free to:
- Report issues or bugs
- Suggest improvements
- Submit theme contributions
- Share configuration tweaks

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **HyDE Project** - Base architecture and theming system
- **LazyVim** - Neovim configuration framework  
- **Catppuccin** - Beautiful color palette
- **Arch Linux Community** - Package ecosystem and support

---

<div align="center">

**Made with ❤️ by Leonardo Trapani**

*Transform your Arch Linux into a beautiful, productive development environment*

</div>
