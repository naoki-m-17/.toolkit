# ==========================================
# Homebrew Node.js ガードレール
#
# [目的]
# Homebrew経由で意図しないNode.jsがシステムにインストールされるのを防ぎ、
# fnmで管理しているクリーンな開発環境との競合を未然に回避する。
#
# [機能]
# 1. brew install 実行時にパッケージの依存関係をディープスキャン
# 2. 隠れたNode.js/JavaScript依存を検知した場合に警告を表示
# 3. ユーザーの明示的な同意があるまでインストール処理を中断
# ==========================================

brew() {
  # "install" コマンドかつ "--cask" が指定されていない場合のみチェックを実行
  if [[ "$1" == "install" ]] && [[ "$*" != *"--cask"* ]]; then
    local pkg="${@: -1}"
    
    echo "🔍 Scanning deep metadata and scripts for '$pkg'..."
    
    # 依存関係ツリー、パッケージ説明、JSONメタデータを取得して隠れた依存を調査
    local deps=$(command brew deps --include-build "$pkg" 2>/dev/null)
    local desc=$(command brew desc "$pkg" 2>/dev/null)
    local formula=$(command brew info --json=v2 "$pkg" 2>/dev/null)

    local all_info="${deps} ${desc} ${formula}"
    
    # node, npm, yarn, javascript のキーワードが含まれるか判定
    if echo "$all_info" | grep -Ei "node|npm|yarn|javascript" > /dev/null; then
      # Node.js 環境が検知された場合の警告
      echo -e "\033[1;33m⚠️  CRITICAL: Node.js/JS environment detected for '$pkg'.\033[0m"
      echo -e "This may conflict with your fnm environment by installing Homebrew-managed Node.js."
      echo -e "Recommendation: Use 'pnpm add -g' or 'brew install --cask' instead."
      echo -e "Do you want to proceed anyway? (y/N): \c"
    else
      # Node.js 依存が見つからなかった場合の成功メッセージ
      echo -e "\033[1;32m✅ Check complete. No hidden Node/JS found for '$pkg'.\033[0m"
      echo -e "Do you want to install it? (y/N): \c"
    fi

    # ユーザー入力を待機
    read -r answer
    if [[ "$answer" != [yY] ]]; then
      echo "Canceled."
      return 1
    fi
  fi

  # 実際の brew コマンドを実行
  command brew "$@"
}