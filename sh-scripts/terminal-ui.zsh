# ==========================================
# Terminal UI & Prompt Customizer
#
# [目的]
# カレントディレクトリの階層構造や Git の詳細なステータスを可視化し、
# 開発コンテキストを瞬時に把握できるようにする。
#
# [機能]
# 1. 親ディレクトリを含めたインテリジェントなパス表示
# 2. Git ブランチ名と状態 (Synced/Ahead/Behind/Stashed/Dirty) の判別
# 3. 状態に応じたカラーコーディングによる視認性の向上
# ==========================================

# Git補完とプロンプトスクリプトの読み込み
if [[ -f /opt/homebrew/share/zsh/site-functions/_git ]]; then
  fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
fi
autoload -Uz compinit && compinit

# プロンプトのデザイン設定
setopt PROMPT_SUBST

_update_terminal_ui() {
  # 親ディレクトリの取得
  local parent=$(basename "$(dirname "$PWD")")
  if [[ "$PWD" == "$HOME" || "$parent" == "." || "$parent" == "/" ]]; then
    PARENT_DIR=""
  else
    PARENT_DIR="$parent/"
  fi

  # Git情報の取得とカスタマイズ
  local branch=$(git branch --show-current 2> /dev/null)
  if [[ -n "$branch" ]]; then
    local status_text="Synced"
    local s_color="121" # 同期済み
    
    local git_status=$(git status --branch --porcelain 2> /dev/null)
    
    # 状態の判定（優先順位順）
    if [[ "$git_status" =~ "behind" ]]; then
        status_text="Behind"
        s_color="203" # リモートに更新あり
    elif [[ "$git_status" =~ "ahead" ]]; then
        status_text="Ahead"
        s_color="117" # 未プッシュあり
    elif [[ -n $(git stash list 2> /dev/null) ]]; then
        status_text="Stashed"
        s_color="211" # スタッシュ
    elif [[ -n $(echo "$git_status" | grep '^??') ]]; then
        status_text="Untracked"
        s_color="211" # 未追跡
    elif [[ -n $(echo "$git_status" | grep '^.[MARC]') ]]; then
        status_text="Unstaged"
        s_color="215" # 変更あり
    elif [[ -n $(echo "$git_status" | grep '^[MARC]') ]]; then
        status_text="Staged"
        s_color="117" # ステージ済
    fi
    
    # 表示の組み立て
    GIT_INFO=" %F{215}${branch}%f%F{242}(%f%F{${s_color}}${status_text}%f%F{242})%f"
  else
    # Git管理外
    GIT_INFO=" %F{242}(Not Git)%f"
  fi
}

# ターミナル起動フックに登録
autoload -U add-zsh-hook
add-zsh-hook precmd _update_terminal_ui

# 配色の定義：
PS1='%F{242}%n%f %F{181}${PARENT_DIR}%f%F{211}%1~%f${GIT_INFO}
%F{121}$%f '