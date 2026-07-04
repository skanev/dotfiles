#!/bin/bash

# Color theme: gray, orange, blue, teal, green, lavender, rose, gold, slate, cyan
COLOR="blue"

C_RESET='\033[0m'
C_GRAY='\033[38;5;245m'
C_TRACK='\033[38;5;238m'
C_TRACK_BG='\033[48;5;238m'
case "$COLOR" in
    orange)   C_ACCENT='\033[38;5;173m' ;;
    blue)     C_ACCENT='\033[38;5;74m' ;;
    teal)     C_ACCENT='\033[38;5;66m' ;;
    green)    C_ACCENT='\033[38;5;71m' ;;
    lavender) C_ACCENT='\033[38;5;139m' ;;
    rose)     C_ACCENT='\033[38;5;132m' ;;
    gold)     C_ACCENT='\033[38;5;136m' ;;
    slate)    C_ACCENT='\033[38;5;60m' ;;
    cyan)     C_ACCENT='\033[38;5;37m' ;;
    *)        C_ACCENT="$C_GRAY" ;;
esac

draw_bar() {
    local pct=$1 width=$2
    local partial=(▏ ▎ ▍ ▌ ▋ ▊ ▉) bar="" i e
    local eighths=$(( (pct * width * 8 + 50) / 100 ))
    for ((i = 0; i < width; i++)); do
        e=$(( eighths - i * 8 ))
        if   (( e >= 8 )); then bar+="${C_ACCENT}█${C_RESET}"
        elif (( e >= 1 )); then bar+="${C_TRACK_BG}${C_ACCENT}${partial[e-1]}${C_RESET}"
        else                    bar+="${C_TRACK}█${C_RESET}"
        fi
    done
    printf '%s' "$bar"
}

fmt_dur() {
    local s=$1
    if   (( s < 60 ));    then echo "<1m"
    elif (( s < 3600 ));  then echo "$((s / 60))m"
    elif (( s < 86400 )); then echo "$((s / 3600))h$(( (s % 3600) / 60 ))m"
    else                       echo "$((s / 86400))d"
    fi
}

input=$(cat)

{
    read -r model
    read -r effort
    read -r thinking
    read -r cwd
    read -r max_context
    read -r tokens
    read -r limit_used
    read -r limit_reset
} <<< "$(jq -r '
    (.model.display_name // .model.id // "?"),
    (.effort.level // ""),
    (.thinking.enabled // false),
    (.cwd // ""),
    (.context_window.context_window_size // 200000),
    ((.context_window.current_usage // {}) |
        (.input_tokens // 0) + (.cache_read_input_tokens // 0) + (.cache_creation_input_tokens // 0)),
    (.rate_limits.five_hour.used_percentage // -1 | round),
    (.rate_limits.five_hour.resets_at // 0)
' <<< "$input")"

# Model + thinking level
seg_model="${C_ACCENT}${model}"
[[ "$thinking" == "true" && -n "$effort" ]] && seg_model+=" ${C_GRAY}${effort}"

# Directory and git; in a linked worktree, show the main repo's folder instead
dir=$(basename "$cwd" 2>/dev/null || echo "?")
dir_icon="📁" branch_icon="🔀"
branch="" git_info=""
[[ -n "$cwd" && -d "$cwd" ]] && branch=$(git -C "$cwd" branch --show-current 2>/dev/null)

if [[ -n "$branch" ]]; then
    git_dir=$(git -C "$cwd" rev-parse --absolute-git-dir 2>/dev/null)
    common_dir=$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)

    if [[ -n "$common_dir" && "$git_dir" != "$common_dir" ]]; then
        dir_icon="🗂️" branch_icon="🌿"
        dir=$(basename "$(dirname "$common_dir")")
        branch=$(sed -E 's/worktrees?[-_/]//; s/[-_/]?worktrees?//' <<< "$branch")
    fi

    dirty=$(git -C "$cwd" --no-optional-locks status --porcelain -uall 2>/dev/null | wc -l | tr -d ' ')
    (( dirty > 0 )) && git_info+=" ✎${dirty}"

    counts=$(git -C "$cwd" rev-list --left-right --count 'HEAD...@{upstream}' 2>/dev/null)
    if [[ -n "$counts" ]]; then
        read -r ahead behind <<< "$counts"
        (( ahead > 0 ))  && git_info+=" ⇡${ahead}"
        (( behind > 0 )) && git_info+=" ⇣${behind}"
        if (( ahead == 0 && behind == 0 )); then
            sync="✓"
            fetch_time=$(stat -f %m "${common_dir:-$cwd/.git}/FETCH_HEAD" 2>/dev/null)
            [[ -n "$fetch_time" ]] && sync+=$(fmt_dur $(( $(date +%s) - fetch_time )))
            git_info+=" ${sync}"
        fi
    else
        git_info+=" ∅"
    fi
fi

# Context bar; at session start usage is 0 but ~20k (system prompt, tools,
# memory) is already loaded, so show an estimate
pct_prefix=""
if (( tokens == 0 )); then
    tokens=20000
    pct_prefix="~"
fi
pct=$(( tokens * 100 / max_context ))
(( pct > 100 )) && pct=100

bar=$(draw_bar "$pct" 10)

if (( max_context >= 1000000 )); then
    max_disp="$(( max_context / 1000000 ))M"
else
    max_disp="$(( max_context / 1000 ))k"
fi

# Five-hour usage window: percent used and time until reset
session=""
if (( limit_used >= 0 )); then
    left_secs=$(( limit_reset - $(date +%s) ))
    (( left_secs < 0 )) && left_secs=0
    filled=$(( (limit_used * 20 + 50) / 100 ))
    sbar=""
    for ((i = 0; i < 20; i++)); do
        (( i < filled )) && sbar+="${C_ACCENT}▰" || sbar+="${C_TRACK}▰"
    done
    session="⌛ ${sbar} ${C_GRAY}${limit_used}% ↻ $(fmt_dur $left_secs)"
fi

out="${seg_model}${C_GRAY} | ${dir_icon} ${dir}"
[[ -n "$branch" ]] && out+=" | ${branch_icon} ${branch}${git_info}"
out+=" | ${bar} ${C_GRAY}${pct_prefix}${pct}% of ${max_disp}"
[[ -n "$session" ]] && out+=" | ${session}"

printf '%b\n' "${out}${C_RESET}"
