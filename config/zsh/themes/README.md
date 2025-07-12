# Tez ZSH Theme

A modern, feature-rich ZSH theme designed for developers working with Git, Kubernetes, and cloud technologies.

## Features

### 🎨 **Visual Design**
- **Multi-line prompt** with clear visual hierarchy
- **Dark terminal optimized** with carefully chosen 256-color palette
- **Unicode symbols** for better visual appeal
- **Consistent color scheme** throughout all components

### 🔧 **Core Functionality**
- **Smart path display** with intelligent truncation
- **Git-aware paths** showing relative paths within repositories
- **Git status integration** with branch name and dirty/clean indicators
- **Repository name display** for better context
- **Kubernetes context** integration for cluster management
- **Time display** in right prompt
- **Exit code display** for failed commands

### ⚡ **Performance Optimizations**
- **Efficient command checking** using ZSH built-ins
- **Safe command execution** with fallbacks
- **Conditional feature loading** based on configuration
- **Minimal git calls** to avoid slowdowns

## Configuration

### Feature Toggles

You can enable/disable specific features by setting these variables in your `.zshrc`:

```bash
# Disable specific features (set to 0)
TEZ_SHOW_KUBECTL=0      # Hide kubectl context
TEZ_SHOW_GIT_REPO=0     # Hide repository name
TEZ_SHOW_GIT_STATUS=0   # Hide git status
TEZ_SHOW_TIME=0         # Hide time in right prompt
```

### Customizable Symbols

Customize the appearance by changing symbols:

```bash
# Change symbols
TEZ_SYMBOL_GIT="⎇"           # Git branch symbol
TEZ_SYMBOL_KUBECTL="⎈"       # Kubernetes symbol
TEZ_SYMBOL_DIRTY="✘✘✘"      # Dirty repository indicator
TEZ_SYMBOL_CLEAN="✔"         # Clean repository indicator
TEZ_SYMBOL_PROMPT="➤"        # Main prompt symbol
```

### Color Customization

The theme uses a consistent color palette defined at the top of the theme file:

```bash
# Main colors (256-color codes)
COLOR_USERNAME=040        # Bright green for username
COLOR_HOSTNAME=033        # Blue for hostname
COLOR_PATH=226            # Bright yellow for path
COLOR_GIT_BRANCH=255      # White for git branch
COLOR_KUBECTL=081         # Cyan for kubectl context
# ... and more
```

## Prompt Layout

```
╭─username@hostname ⎈ kubernetes-context
├─o ⎇ branch-name [repo-name] /path/to/current/directory
╰─➤ 
```

**Right Prompt:**
```
14:30:25 ✗ 1
```

### Components Explained

1. **Username & Hostname**: Green username, blue hostname
2. **Kubernetes Context**: Cyan cluster context (if available)
3. **Git Information**: 
   - Branch name in white
   - Repository name in brackets
   - Dirty/clean status indicators
4. **Path Display**: 
   - Smart truncation for long paths
   - Git-aware relative paths
   - Home directory replacement with `~`
5. **Right Prompt**:
   - Current time
   - Exit code for failed commands

## Smart Path Display

The theme includes intelligent path handling:

### Git Repository Paths
- Shows relative path from repository root
- Displays repository name separately
- Falls back to full path if git commands fail

### Regular Paths
- Shows full path if ≤ 6 components
- Truncates to `first/three/.../last/three` for longer paths
- Replaces home directory with `~`

### Examples
```
# In git repo: ~/projects/my-app/src/components
# Shows: . [my-app] src/components

# Long path: /usr/local/share/doc/package/version/examples
# Shows: /usr/local/share/.../version/examples

# Home path: /home/user/documents/work
# Shows: ~/documents/work
```

## Dependencies

The theme works with minimal dependencies:

- **ZSH**: Required (obviously)
- **Git**: For git-related features
- **Kubectl**: For Kubernetes context (optional)
- **realpath**: For relative path calculation (with fallback)

## Installation

1. Copy the theme file to your ZSH themes directory:
   ```bash
   cp tez.zsh-theme ~/.oh-my-zsh/themes/
   ```

2. Set the theme in your `.zshrc`:
   ```bash
   ZSH_THEME="tez"
   ```

3. Reload your shell:
   ```bash
   source ~/.zshrc
   ```

## Troubleshooting

### Colors Not Displaying
- Ensure your terminal supports 256 colors
- Check that your terminal emulator supports color codes
- Verify ZSH is properly configured

### Slow Performance
- Disable unused features with configuration variables
- Check if you have many git repositories in your path
- Consider disabling kubectl context if not needed

### Missing Symbols
- Ensure your terminal font supports Unicode symbols
- Try a font like "Fira Code", "JetBrains Mono", or "Cascadia Code"

### Git Features Not Working
- Verify git is installed and in your PATH
- Check that you're in a git repository
- Ensure git commands work from command line

## Customization Examples

### Minimal Setup (Git only)
```bash
TEZ_SHOW_KUBECTL=0
TEZ_SHOW_TIME=0
```

### Kubernetes-Focused Setup
```bash
TEZ_SHOW_GIT_REPO=0
TEZ_SYMBOL_KUBECTL="☸"
```

### Custom Colors
```bash
# Add to your .zshrc before loading the theme
COLOR_USERNAME=196  # Bright red username
COLOR_PATH=51      # Cyan path
```

## Contributing

When contributing to the theme:

1. Maintain the existing color scheme consistency
2. Add configuration options for new features
3. Include proper error handling
4. Test on different terminal emulators
5. Update this documentation

## License

This theme is part of the workstation-scripts project and follows the same license terms. 