# Clipshort

特定のアプリケーションに依存せず、LLM やシェルとインタラクティブに対話するための macOS 用アプリケーションです。
キーボードショートカットを用いて即座に選択されたテキストに関して即座に質問することができます。

**Clipshort** – a macOS application that allows seamless interaction with LLMs and shells. You can instantly open a window using keyboard shortcuts and ask questions about the selected text.

https://github.com/user-attachments/assets/2d9a00ed-c824-4101-a4d4-19834697ecce

## インストール

1. [Releases](https://github.com/inaniwaudon/clipshort/releases/) から最新のリリースをダウンロードします。
2. ダウンロードした ZIP ファイルを解凍し、`Clipshort.app` をアプリケーション（`/Applications`）フォルダに移動します。

また、初回実行時のみ以下の操作が必要です。

1. 移動させた Clipshort をクリックして開きます。
2. 「アクセシビリティアクセス」「Accessibility API の権限が必要です」と書かれたダイアログがそれぞれ出現します。このうち「アクセシビリティアクセス」にある「システム設定を開く」ボタンをクリックします。
3. システム設定の「プライバシーとセキュリティ」→「アクセシビリティ」画面が出現するため、Clipshort に許可を与えます。
4. 「Accessibility API の権限が必要です」にある「再試行」ボタンをクリックします。
5. 適切な権限が与えられた場合、これらのダイアログは閉じられます。再びダイアログが出現した場合は、2, 3, 4　の手順を再度行ってください。上手く作動しない場合は、「アクセシビリティ」画面に存在する Clipshort の項目を一度削除してからお試しください。

> [!NOTE]
> アプリケーションが未署名であるため、「開発元が未確認のため開けません」という警告が出る場合があります。その際は、以下のリンクに従ってください。
> - [開発元が不明な Mac アプリを開く - Apple サポート](https://support.apple.com/ja-jp/guide/mac-help/mh40616/mac)

## 使用方法

1. `Ctrl + [` キーを押す、またはメニューバーのアイコンをクリックして、ウィンドウを開きます。この際、選択中のテキストがあれば、クリップボードに自動でコピーされます。
2. 入力文（プロンプトまたはコマンド）を入力した後、Shift + Enter を用いて実行します。まもなく、実行結果が表示されます。
3. `Ctrl + Q` キーを押すとウィンドウを終了します。選択中のテキストが存在すればその内容を、なければ実行結果全体をクリップボードにコピーします。

### 入力

- 先頭に `/llm` と記述した場合、LLM への問い合わせが行われます。
入力文がコロン（全角、半角）で終わる場合、クリップボードの内容を末尾に追加して問い合わせを行います（シェルコマンドの場合は無効）。
- 先頭に `/sh` と記述した場合、入力文はシェルコマンドとして実行されます。
- 先頭にその他の `/shortcut` を記述した場合、設定ファイルに記述されたショートカットが実行されます（後述）。
- 何も記述しない場合は、設定ファイルの `defaultMode` の設定に準じて実行されます（初期値では LLM への問い合わせ）。

### 設定

`/settings` と入力して実行することにより、設定用 JSON ファイル（`~/clipshortrc.json`）が開きます。JSON ファイルは、以下の通りに指定されます。

```json
{
  "shell" : {
    "bin" : "シェルのパス",
    "initial" : "ウィンドウ起動時に実行するシェルコマンド"
  },
  "defaultMode" : "デフォルトでの実行設定。llm または sh",
  "llm" : {
    "model" : "OpenAI のモデル",
    "systemPrompt" : "システムプロンプト",
    "apiKey" : "OpenAI の API キー"
  },
  "width" : ウィンドウの幅,
  "shortcut" : {
    "ショートカット名（半角英数字）": "ショートカットの内容",
  }
}
```

`shortcut` に辞書形式でショートカットを登録すると、よく使う入力文を簡単に呼び出すことが可能となります。

- ショートカットの内容には、プロンプトおよびシェルコマンドの両方を記述できます。
- ショートカットが LLM への問い合わせであり、かつショートカットの内容の末尾がコロンで終わる場合、通常の入力と同様に、クリップボードの内容を追加して問い合わせを行います。
- ショートカットの内容に `#1` が含まれる場合、その部分は入力文からショートカットコマンド（`/foo`）を除いた内容に置換されます。

ショートカットの設定例および実行例を以下に示します（`defaultMode` が `llm` であることを想定）。

```json
{
  "en": "次の文章を英訳してください：#1",
  "weather": "/sh curl -s https://weather.tsukumijima.net/api/forecast/city/140020 | jq -r '.forecasts[] | select(.dateLabel==\"今日\") | .detail.weather'"
}
```

```
> /en（良さそうに見えます というテキストを選択した状態で）
It seems good.

> /en 再度レビューいただいてもよろしいですか？
Can you review it again?

> /weather
雨か雪
```

### 動作が不安定なときは

`/exit` を実行してソフトを一度終了し、再度アプリケーションを起動してください。それでも改善しない場合は [Issues](https://github.com/inaniwaudon/clipshort/issues) までご報告ください。

## ライセンス

Copyright (c) 2024 いなにわうどん. This application is released under the MIT License, see [LICENSE](https://github.com/inaniwaudon/clipshort/blob/main/LICENSE).
