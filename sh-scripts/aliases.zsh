# ==========================================
# Gemini CLI
#
# [目的]
# 依存関係を汚染させない専用の隔離環境を利用し、
# 開発プロジェクトのパスを維持したまま安全にAIアシスタントを起動する。
#
# [機能]
# 1. Node v22を適用した隔離ディレクトリへの自動切り替え
# 2. 起動時のカレントディレクトリを保持し、終了時や中断時はそのパスへ戻る
# 3. 実行ディレクトリを維持した状態で、隔離環境内のバイナリを叩く
# ==========================================

alias gemini='(){
    local PROJECT_PATH="$PWD"
    trap "cd $PROJECT_PATH" EXIT INT
    cd ~/src/.toolkit/nodetools-22 || return
    fnm exec -- sh -c "cd $PROJECT_PATH && ~/src/.toolkit/nodetools-22/node_modules/.bin/gemini --include-directories ~/src/.toolkit/llm-context"
}'


# ==========================================
# Firebase CLI (Safe Execution)
#
# [目的]
# グローバル環境を汚染せずに Firebase Tools を実行する。
# プロジェクトごとのバージョン固定を尊重しつつ、環境外での誤用も防ぐ。
#
# [機能]
# 1. npx を経由し、プロジェクト内の node_modules を最優先で参照
# 2. ローカルに存在しない場合は一時的に取得・実行し、永続的な汚染を回避
# 3. バージョン不整合によるデプロイミスなどのリスクを低減
# ==========================================
alias firebase='npx firebase-tools'


# ==========================================
# その他
# ==========================================

alias p='pnpm'