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
	* [ ] セーブした報告をステータスバーに表示する
* [x] tab キーの挙動を変える
* [ ] エディタの末尾でスペースやtabを入力しても駄目な現象の解明
* [ ] カーソル上下で、タイトル・本文を移動できるようにする
* [ ] preview view の word-wrap を有効にする
* タブ
	- [x] タブ切り替え
	- [ ] タブの動的な追加
	- [ ] タブの見た目を整える
	- [ ] タブを閉じるボタン / command+W
	- [ ] タブをDnDで移動する
	- [ ] 新規タブ / command+T
	- [ ] アクセスから開く時に新規タブで開く
* [ ] レンダラープロセスから、ファイルアクセスをメインプロセスに移動する

* アプリケーション名変更
* css
	- [ ] preview 用
* [ ] 絵文字対応

* [ ] システムダイアログ
	- [ ] font-selector
