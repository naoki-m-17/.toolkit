# クリーンで快適な開発環境を作りたい！ 

システム環境（Homebrew）、ランタイム管理（fnm）、独自スクリプトを明確に分離し、Node.js環境の純粋性を守るための構成です。

## 開発背景

Gemini CLI が Node を必要としていて、インストール先に悩んだ...

- **`brew install gemini-cli`**: brew内に自動でnodeが生成され、fnmと干渉しそう
- **（fnm配下の各nodeバージョンへ） `npm install -g gemini-cli`**: ツールのインストールがバージョン間で重複するし、どれに何入れたか迷子になりそう
- **プロジェクトごとにインストール**: package.jsonに差分が出るし、さすがにめんどくさい

## 今回の解決方法

`gemini` コマンドを叩くと、

1. **実行コンテキストの自動切り替え**: コマンド実行時のみ透過的に隔離環境（`nodetools-xx`）へスイッチし、実体バイナリを呼び出す。
2. **プロジェクト・スコープの維持**: 実行ディレクトリを元のプロジェクトに固定し、CLIの監視対象や出力を正しく保持する。
3. **安全な状態復旧（Atomic Return）**: 終了・中断時に元のディレクトリへ明示的に戻ることで、`fnm` による Node バージョンの自動復旧を確実に誘発させる。

で解決したい。

## システム全体像

```text
/ (Root)
├── /opt/homebrew/          # システムツール層（Node.js混入を brew-node-guard.zsh で阻止）
│   ├── Cellar/             # Formula実体: fnm, git, tree, libiconv ...
│   └── Caskroom/           # Cask実体: cursor, raycast, claude, slack, notion ...
└── ~
    ├── .zshrc              # .toolkit/init.zsh をロード
    ├── .local/share/
    │   ├── fnm/            # ランタイム層（fnm 本体と各 Node version 実体）
    │   └── pnpm/           # パッケージ管理層（pnpm 実体・グローバルストア）
    └── src/
        │
        ├── ⭕️ .toolkit
        │   ├── README.md
        │   ├── init.zsh    # sh-scripts 内の各モジュールをロード
        │   ├── nodetools-22/ # 隔離環境
        │   │   ├── .node-version # バージョン固定
        │   │   └── node_modules/.bin/
        │   │       └── gemini # ← 隔離環境内で実行される実体バイナリ
        │   └── sh-scripts/ # 各種ガードレール・自動化スクリプト
        │       ├── aliases.zsh          # 隔離環境でのバイナリ叩き・短縮設定
        │       ├── node-provisioner.zsh # cd 時に Node/pnpm を自動切替
        │       ├── brew-node-guard.zsh  # brew への Node 混入を防ぐガード
        │       └── terminal-ui.zsh      # Git詳細ステータスUI
        │
        ├── project-a/
        │   └── .node-version (v22) # cd 時に自動で fnm が切替
        └── project-b/
            └── .node-version (v20) # cd 時に自動で fnm が切替
```