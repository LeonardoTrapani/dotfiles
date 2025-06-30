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
│   ├── restore_*.sh     # Configuration restoration scripts
│   └── themepatcher.sh  # Theme management system
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
└── 📋 setup.sh          # Interactive setup script
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
./setup.sh
```

**Choose your installation method:**
- `1` - Stow dotfiles only  
- `2` - Run installation scripts only
- `3` - **Complete setup (recommended)**

### Alternative Installation Methods

**Automated (no prompts):**
```bash
./setup.sh -d
```

**Selective installation:**
```bash
./setup.sh -s     # Only Stow dotfiles
./setup.sh -i     # Only installation scripts
```

**Test run (dry run):**
```bash
./setup.sh -n
```

---

## 🛠️ Management

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
./setup.sh -n  # Dry run first
```
---

## 🗺️ Roadmap

- [x] Complete HyDE customization and branding
- [x] Interactive setup system with options
- [x] Improved documentation and README
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
