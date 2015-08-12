Phase.2
=======

* 一通りの access view を実装する
* application の描画を整える




core
----

* [ ] sinon
	* [ ] 引数がわからない呼び出しをどう stub 化するか

application
-----------

* [ ] electron
	* [ ] electron-updater
	* [ ] gulp-electron
	* [ ] なぜか落ちる現象の解明
* [ ] livereload 的なもの
* [ ] browserify?

* リファクタリング
	- [ ] view を独立したコンポーネントにする
    - [ ] pane を動的に構成する
	- [ ] レンダラープロセスから、ファイルアクセスをメインプロセスに移動する
	- [ ] mainViewModel.constructor の引数でpane数を指定してpaneを作成する
		* [ ] setElemをイベント駆動 (onReady的な)にする
	- [ ] 順番が前後しても正常に動くようにする
	- [ ] 全ペインに UUID を発行する
	- editor -> preview のつなぎ込みをもうちょっとマシにする
		* [ ] class の外に散らばってるロジックを class におさめる
		* [ ] panes.get() の決め打ちをなくす
	- pane0/pane1 をそれぞれ決め打ちしてる状況をやめる
* [ ] 足回りに遅延処理を導入する
	- [ ] 検索インデックス作成
* [ ] FmIndex#decodeAll

* [ ] split bar
    - [ ] pane と pane の間に bar を作成する
    - [ ] barを動かせるようにする
* [ ] tab キーの挙動を変える
* [ ] エディタの末尾でスペースやtabを入力しても駄目な現象の解明
* [ ] カーソル上下で、タイトル・本文を移動できるようにする
* [ ] 初期フォーカス設定

* [ ] ステータスバー
	* [ ] エラーをステータスバーに表示する
	* [ ] オープンしてるファイルの情報を表示する
* [ ] preview view の word-wrap を有効にする
* タブ
	- [ ] タブの見た目を整える
	- [ ] タブを閉じるボタン
	- [ ] タブを閉じるときにうまく preview を更新する
	- [ ] タブをDnDで移動する
	- [ ] 新規タブボタンを tab bar に表示する
* access view を強化する
	- [ ] カーソル
	- [x] ダブルクリック
	- [x] 編集ボタン
	- [ ] 表示する情報を増やす
	- [x] スクロールするだけの量ができた時に対応がうまくいってるか？
	- [x] 検索
* [ ] close tab で、dirty 状態の時ダイアログを出す
* [ ] 閉じたタブを開く を実装する
* [ ] window resize 情報をセーブ / ロード
* [ ] テンポラリ保存


* アプリケーション名変更
* css
	- [ ] preview 用
* [ ] 絵文字対応
* [ ] code highlight

* [ ] システムダイアログ
	- [ ] font-selector
	- [ ] close tab

