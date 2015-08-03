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
* [ ] view
	* [ ] view を独立したコンポーネントにする
* layout
    * [ ] split bar
        * [ ] barを動かせるようにする
    * [ ] pane を動的に構成する
	* [ ] layout manager
		* [x] 縦
		* [ ] 横
* [ ] ステータスバー
	* [ ] エラーをステータスバーに表示する
	* [ ] オープンしてるファイルの情報を表示する
* [x] tab キーの挙動を変える
* [ ] エディタの末尾でスペースやtabを入力しても駄目な現象の解明
* [ ] カーソル上下で、タイトル・本文を移動できるようにする
* [ ] preview view の word-wrap を有効にする
* タブ
	- [ ] タブの見た目を整える
	- [ ] タブを閉じるボタン
	- [ ] タブをDnDで移動する
	- [ ] 新規タブ / command+T
	- [x] アクセスから開く時に新規タブで開く
* [ ] レンダラープロセスから、ファイルアクセスをメインプロセスに移動する
	- [ ] 


* [ ] mainViewModel.constructor の引数でpane数を指定してpaneを作成する
	- [ ] setElemをイベント駆動 (onReady的な)にする
* [ ] 順番が前後しても正常に動くようにする
* [ ] 初期フォーカス設定
* [ ] cmd+O
	* [ ] なければ AccessViewModel を作る
	* [ ] あれば AccessViewModel に切り替える
* [ ] 複数の preview / access を作れるようにする
* [ ] 全ペインに UUID を発行する
* [ ] editor -> preview のつなぎ込みをもうちょっとマシにする
	* [ ] class の外に散らばってるロジックを class におさめる
	* [ ] panes.get() の決め打ちをなくす
* [ ] access view にカーソルを用意する / シングルクリック・ダブルクリック

* アプリケーション名変更
* css
	- [ ] preview 用
* [ ] 絵文字対応
* [ ] code highlight

* [ ] システムダイアログ
	- [ ] font-selector
