# Homebrew Tap for Semafor

This is the official Homebrew tap for [Semafor](https://github.com/rnavratil/homebrew-semafor) - a menu bar status indicator with CLI support.

## Installation

```bash
# Add the tap
brew tap rnavratil/semafor

# Install Semafor
brew install --cask semafor
```

## What is Semafor?

Semafor is a macOS menu bar application that displays status indicators (🟢 green or 🔴 red) and can be controlled via command line.

### Features
- Menu bar status indicator
- CLI tool for remote control
- Customizable emojis
- Perfect for CI/CD status, deployment indicators, or availability status

### CLI Usage

After installation, you can use the `semafor` command:

```bash
# Set status to red with a reason
semafor red "Deploying to production"

# Set status to green
semafor green

# Check current status
semafor status
```

## Updating

```bash
brew update
brew upgrade --cask semafor
```

## Uninstalling

```bash
brew uninstall --cask semafor
```

This will also remove the CLI tool from `/usr/local/bin/semafor`.

## Development

To test the cask locally:

```bash
brew install --cask --debug Casks/semafor.rb
```

## Issues

Report issues at: https://github.com/rnavratil/semafor/issues
