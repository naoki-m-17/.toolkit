# ==========================================
# Claude Code Session Manager
#
# [目的]
# 使用量制限の枠を最大限活用するため、ターミナル起動時に可能な限り早く 
# 5時間の Claude セッションを開始・維持することを主目的とする。
#
# [機能]
# 1. ターミナル起動時の自動セッション開始による、利用枠の早期確保
# 2. セッションの有効期限チェックと残り時間の表示
# ==========================================

CLAUDE_SESSION_FILE="$HOME/.claude_session"
CLAUDE_SESSION_DURATION=$((5 * 60 * 60))  # 5時間（秒）

check_claude_session() {
  if [[ -f "$CLAUDE_SESSION_FILE" ]]; then
    local session_start=$(cat "$CLAUDE_SESSION_FILE")
    local current_time=$(date +%s)
    local elapsed=$((current_time - session_start))
    
    if [[ $elapsed -lt $CLAUDE_SESSION_DURATION ]]; then
      local remaining=$(($CLAUDE_SESSION_DURATION - $elapsed))
      local hours=$((remaining / 3600))
      local minutes=$(((remaining % 3600) / 60))
      echo "🧠 Claude セッション継続中 (残り${hours}時間${minutes}分)"
      return 0
    fi
  fi
  return 1
}

start_claude_session() {
  if ! check_claude_session; then
    echo "🚀 Claude Code セッション開始中..."
    
    # claudeコマンドを実行して記録
    if claude -p "ping" 2>/dev/null; then
      # 成功した場合のみ記録
      date +%s > "$CLAUDE_SESSION_FILE"
      echo "✅ Claude セッション開始 (5時間有効)"
    else
      echo "❌ Claude セッション開始失敗"
      # ファイルが存在する場合は削除（念のため）
      rm -f "$CLAUDE_SESSION_FILE"
    fi
  fi
}

# ターミナル起動時に自動実行
start_claude_session
# エイリアス
alias cs='check_claude_session || start_claude_session'