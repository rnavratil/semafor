# 🚦 Semafor

A macOS menu bar status indicator with CLI support. Perfect for showing your availability, deployment status, or any binary state.

## Features

- 🟢 **Menu Bar Indicator** - Shows green (available) or red (busy) status
- 🖥️ **CLI Control** - Control status from command line or scripts
- 🎨 **Customizable Emojis** - Choose your own status indicators
- ⚡ **Lightweight** - Native macOS app, minimal resource usage

## Installation

### Homebrew (Recommended)

```bash
brew tap rnavratil/semafor
brew install --cask semafor
```

### Manual Installation

1. Download the latest release from [Releases](https://github.com/rnavratil/semafor/releases)
2. Unzip and move `Semafor.app` to `/Applications`
3. Open Semafor
4. Install CLI tool when prompted (optional)

## CLI Usage

```bash
# Set status to red with a reason
semafor red "Deploying to production"

# Set status to green
semafor green

# Set status to green with a reason
semafor green "All systems operational"

# Check current status
semafor status
```

## Use Cases

- 🚀 **Deployment Status** - Show when deployments are running
- 💬 **Availability Indicator** - Let teammates know you're busy
- 🔧 **CI/CD Integration** - Reflect build/test status
- 📊 **Service Monitoring** - Show health of your services

## Requirements

- macOS 14.0 (Sonoma) or later
- Apple Silicon or Intel Mac

## Building from Source

```bash
git clone https://github.com/rnavratil/semafor.git
cd semafor
open Semafor.xcodeproj
```

Build and run in Xcode (⌘R)

## How It Works

The CLI tool communicates with the menu bar app using:
- URL schemes for simple commands
- Distributed Notifications for status updates
- User Defaults for persistent state

## License

MIT License - see [LICENSE](LICENSE) file

## Author

Rostislav Navrátil ([@rnavratil](https://github.com/rnavratil))

## Contributing

Issues and pull requests welcome!

