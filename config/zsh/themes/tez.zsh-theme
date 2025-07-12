# tez.zsh-theme
# Based on fino
# Use with a dark background and 256-color terminal!

# Color variables for easy customization
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

function kubectl_prompt_info {
  # Check if kubectl is available.
  command -v kubectl &>/dev/null || return
  
  # Get current context.
  local context=$(kubectl config current-context 2>/dev/null)
  [[ -z "$context" ]] && return
  
  # Format the output
  echo "${ZSH_THEME_KUBECTL_PREFIX}${context}${ZSH_THEME_KUBECTL_SUFFIX}"
}

function git_repo_info {
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
      # Get relative path from git root
      local relative_path=$(realpath --relative-to="$git_root" "$PWD" 2>/dev/null)
      
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

# Locals for composing the prompt.
local git_info='$(git_prompt_info)'
local git_repo='$(git_repo_info)'
local kubectl_info='$(kubectl_prompt_info)'
local custom_path='$(custom_pwd)'

# Color helpers for readability
local user_host="${FG[$COLOR_USERNAME]}%n${FG[$COLOR_AT_SYMBOL]}@${FG[$COLOR_HOSTNAME]}$HOST"
local path_display="%B${FG[$COLOR_PATH]} ${custom_path}%b"
local reset="%{$reset_color%}"

# The glorious prompt! (Multi-line for readability)
PROMPT="╭─${user_host}${kubectl_info}${reset}
├─o ${git_info}${git_repo}${path_display}
╰─➤${reset} "

# Environment Variables
ZSH_THEME_GIT_PROMPT_PREFIX="${FG[$COLOR_GIT_PREFIX]}⎇ %{$reset_color%} ${FG[$COLOR_GIT_BRANCH]}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="${FG[$COLOR_GIT_DIRTY]} ✘✘✘"
ZSH_THEME_GIT_PROMPT_CLEAN="${FG[$COLOR_GIT_CLEAN]} ✔"

ZSH_THEME_GIT_REPO_PREFIX="${FG[$COLOR_GIT_PREFIX]} ${FG[$COLOR_GIT_REPO]}["
ZSH_THEME_GIT_REPO_SUFFIX="]%{$reset_color%}"

ZSH_THEME_KUBECTL_PREFIX="${FG[$COLOR_GIT_PREFIX]} ⎈ ${FG[$COLOR_KUBECTL]}"
ZSH_THEME_KUBECTL_SUFFIX="%{$reset_color%}"