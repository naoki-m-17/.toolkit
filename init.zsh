# init.zsh の絶対パスを1度だけ取得
local BASE_DIR="${0:A:h}/sh-scripts"

# sh-scripts 内をロード
[[ -f "$BASE_DIR/aliases.zsh" ]]   && source "$BASE_DIR/aliases.zsh"
[[ -f "$BASE_DIR/brew-node-guard.zsh" ]]   && source "$BASE_DIR/brew-node-guard.zsh"
[[ -f "$BASE_DIR/node-provisioner.zsh" ]]   && source "$BASE_DIR/node-provisioner.zsh"
[[ -f "$BASE_DIR/terminal-ui.zsh" ]]   && source "$BASE_DIR/terminal-ui.zsh"