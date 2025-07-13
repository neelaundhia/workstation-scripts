# tez.zsh-theme
# Based on fino
# Use with a dark background and 256-color terminal!

# =============================================================================
# CONFIGURATION
# =============================================================================

# Enable/disable features (set to 0 to disable)
: ${TEZ_SHOW_KUBECTL:=1}
: ${TEZ_SHOW_GIT_REPO:=1}
: ${TEZ_SHOW_GIT_STATUS:=1}
: ${TEZ_SHOW_TIME:=1}

# Symbols (customizable)
: ${TEZ_SYMBOL_GIT:="⎇"}
: ${TEZ_SYMBOL_KUBECTL:="⎈"}
: ${TEZ_SYMBOL_DIRTY:="✘✘✘"}
: ${TEZ_SYMBOL_CLEAN:="✔"}
: ${TEZ_SYMBOL_PROMPT:="➤"}

# =============================================================================
# COLOR DEFINITIONS
# =============================================================================

# Use consistent color syntax
local COLOR_USERNAME=040        # Bright green for username
local COLOR_AT_SYMBOL=239       # Dark gray for @ symbol
local COLOR_HOSTNAME=033        # Blue for hostname
local COLOR_PATH=226            # Bright yellow for path
local COLOR_GIT_PREFIX=239      # Dark gray for git prefix
local COLOR_GIT_BRANCH=255      # White for git branch
local COLOR_GIT_DIRTY=202       # Orange/red for dirty status
local COLOR_GIT_CLEAN=040       # Bright green for clean status
local COLOR_GIT_REPO=226        # Light blue for repository name
local COLOR_KUBECTL=081         # Cyan for kubectl context
local COLOR_TIME=240            # Dark gray for time
local COLOR_EXIT_CODE=202       # Red for non-zero exit codes

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Check if command exists (more efficient than command -v)
function _tez_cmd_exists {
  (( ${+commands[$1]} ))
}

# Safe command execution with fallback
function _tez_safe_cmd {
  local cmd="$1"
  local fallback="$2"
  
  if _tez_cmd_exists "$cmd"; then
    eval "$cmd"
  elif [[ -n "$fallback" ]]; then
    eval "$fallback"
  fi
}

# =============================================================================
# PROMPT COMPONENTS
# =============================================================================

function kubectl_prompt_info {
  [[ $TEZ_SHOW_KUBECTL -eq 0 ]] && return
  
  # Check if kubectl is available
  _tez_cmd_exists kubectl || return
  
  # Get current context (with error suppression)
  local context=$(kubectl config current-context 2>/dev/null)
  [[ -z "$context" ]] && return
  
  # Format the output
  echo "${ZSH_THEME_KUBECTL_PREFIX}${context}${ZSH_THEME_KUBECTL_SUFFIX}"
}

function git_repo_info {
  [[ $TEZ_SHOW_GIT_REPO -eq 0 ]] && return
  
  # Check if we're in a git repository
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    # Get the git repository root
    local git_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ -n "$git_root" ]]; then
      # Get repository name
      local repo_name=$(basename "$git_root")
      echo "${ZSH_THEME_GIT_REPO_PREFIX}${repo_name}${ZSH_THEME_GIT_REPO_SUFFIX}"
    fi
  fi
}

function custom_pwd {
  local current_path="$PWD"
  local home_path="$HOME"
  
  # Replace home directory with ~
  if [[ "$current_path" == "$home_path"* ]]; then
    current_path="~${current_path#$home_path}"
  fi
  
  # Check if we're in a git repository
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    # Get the git repository root
    local git_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ -n "$git_root" ]]; then
      # Get relative path from git root (with fallback)
      local relative_path=$(_tez_safe_cmd "realpath --relative-to=\"$git_root\" \"$PWD\" 2>/dev/null" "echo \".\"")
      
      # If we're at the root of the repository
      if [[ "$relative_path" == "." ]]; then
        echo "."
      else
        echo "$relative_path"
      fi
      return
    fi
  fi
  
  # Not in a git repository - show first three and last three elements
  # Split path into array
  local path_parts=("${(@s:/:)current_path}")
  local num_parts=${#path_parts}
  
  # If path has 6 or fewer parts, show all
  if [[ $num_parts -le 6 ]]; then
    echo "$current_path"
  else
    # Show first three and last three parts with ... in between
    local first_three="${path_parts[1]}/${path_parts[2]}/${path_parts[3]}"
    local last_three="${path_parts[-3]}/${path_parts[-2]}/${path_parts[-1]}"
    
    # Handle edge case where first part might be empty (absolute path)
    if [[ -z "${path_parts[1]}" ]]; then
      first_three="/${path_parts[2]}/${path_parts[3]}"
      if [[ $num_parts -gt 6 ]]; then
        first_three="${first_three}/${path_parts[4]}"
        last_three="${path_parts[-3]}/${path_parts[-2]}/${path_parts[-1]}"
      fi
    fi
    
    echo "${first_three}/.../${last_three}"
  fi
}

function exit_code_prompt {
  local exit_code=$?
  if [[ $exit_code -ne 0 ]]; then
    echo "%{$FG[$COLOR_EXIT_CODE]%}✗ $exit_code%{$reset_color%}"
  fi
}

function time_prompt {
  [[ $TEZ_SHOW_TIME -eq 0 ]] && return
  echo "%{$FG[$COLOR_TIME]%}%D{%H:%M:%S}%{$reset_color%}"
}

# =============================================================================
# PROMPT COMPOSITION
# =============================================================================

# Locals for composing the prompt
local git_info='$(git_prompt_info)'
local git_repo='$(git_repo_info)'
local kubectl_info='$(kubectl_prompt_info)'
local custom_path='$(custom_pwd)'
local exit_code='$(exit_code_prompt)'
local time_display='$(time_prompt)'

# Color helpers for readability
local user_host="%{$FG[$COLOR_USERNAME]%}%n%{$FG[$COLOR_AT_SYMBOL]%}@%{$FG[$COLOR_HOSTNAME]%}$HOST"
local path_display="%B%{$FG[$COLOR_PATH]%} ${custom_path}%b"
local reset="%{$reset_color%}"

# The glorious prompt! (Multi-line for readability)
PROMPT="╭─${user_host}${kubectl_info}${reset}
├─o ${git_info}${git_repo}${path_display}
╰─${TEZ_SYMBOL_PROMPT}${reset} "

# Right prompt with time and exit code
RPROMPT="${time_display} ${exit_code}"

# =============================================================================
# ENVIRONMENT VARIABLES
# =============================================================================

ZSH_THEME_GIT_PROMPT_PREFIX="%{$FG[$COLOR_GIT_PREFIX]%}${TEZ_SYMBOL_GIT} %{$reset_color%} %{$FG[$COLOR_GIT_BRANCH]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$FG[$COLOR_GIT_DIRTY]%} ${TEZ_SYMBOL_DIRTY}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$FG[$COLOR_GIT_CLEAN]%} ${TEZ_SYMBOL_CLEAN}"

ZSH_THEME_GIT_REPO_PREFIX="%{$FG[$COLOR_GIT_PREFIX]%} %{$FG[$COLOR_GIT_REPO]%}["
ZSH_THEME_GIT_REPO_SUFFIX="]%{$reset_color%}"

ZSH_THEME_KUBECTL_PREFIX="%{$FG[$COLOR_GIT_PREFIX]%} ${TEZ_SYMBOL_KUBECTL} %{$FG[$COLOR_KUBECTL]%}"
ZSH_THEME_KUBECTL_SUFFIX="%{$reset_color%}"