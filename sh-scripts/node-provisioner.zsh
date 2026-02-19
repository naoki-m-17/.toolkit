# ==========================================
# Node.js & Package Manager (fnm + Corepack)
#
# [目的]
# 開発者がディレクトリを移動するだけで、一切のコマンドを打たずに
# 「正しいNode」と「正しいpnpm」が揃っている状態をプロビジョニングする。
#
# [機能]
# 1. プロジェクト固有のNode.jsバージョンへの自動切り替え
# 2. 未インストールの場合は自動的にセットアップ
# 3. パッケージマネージャ(pnpm)の有効化と実行パスの保証
# ==========================================

# Corepackの自動ダウンロードを許可 (fnm初期化より前)
export COREPACK_ENABLE_DOWNLOAD_PROMPT=0
# fnm の Node 格納先（fnm初期化より前）
export FNM_DIR="$HOME/.local/share/fnm"

# fnmの初期化
eval "$(fnm env)"

# 自動インストール & 切り替え & Corepack有効化の関数
_node_auto_provision() {
  local version_file
  if [[ -f .node-version ]]; then
    version_file=".node-version"
  elif [[ -f .nvmrc ]]; then
    version_file=".nvmrc"
  fi

  if [[ -n "$version_file" ]]; then
    local version=$(cat "$version_file" | tr -d '[:space:]')
    
    # Node.js ランタイムの解決
    if [[ ! "$(fnm ls 2>/dev/null)" = *"$version"* ]]; then
      echo "⚡️ Node $version not found. Starting auto-install..."
      fnm install "$version"
      echo "✅ Node $version setup completed."
    fi
    
    # 実行コンテキストの切り替え
    fnm use "$version" >/dev/null 2>&1
    echo "🚀 Switched runtime to Node $version."
    
    # パッケージマネージャの整合性確認
    if ! command -v pnpm > /dev/null 2>&1; then
      echo "💎 pnpm not found. Enabling via Corepack..."
      corepack enable pnpm >/dev/null 2>&1
      echo "✅ Linked pnpm to execution path via Corepack."
    else
      echo "🔗 Established pnpm resolution route via Corepack."
    fi
  else
    # プロジェクト外（グローバルコンテキスト）
    local current_version=$(node -v 2>/dev/null)
    echo "😐 Using fnm default (Node $current_version)."
  fi
}

# ディレクトリ移動フックに登録
autoload -U add-zsh-hook
add-zsh-hook chpwd _node_auto_provision
_node_auto_provision