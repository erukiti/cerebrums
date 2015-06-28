phase. 1
--------

* 最低限の Rx.Observable な足回り
	- [ ] application に合った repository
* 最低限の application
	- [x] markdown リアルタイムプレビュー
	- [ ] アクセスビュー (recent)

----

* とりあえずアクセスビューは、cmd+O と ESC で切り替え。tab は作らない
* 


core
----

* [ ] sinon
	* [x] mock を stub に置き換え
	* [ ] 引数がわからない呼び出しをどう stub 化するか
* [ ] rxfs を調査する (というか作り直す？)
* [ ] msgpack で書き直す

application
-----------

* [ ] electron
	* [x] electron 対応
	* [ ] electron-updater
	* [ ] gulp-electron
	* [ ] なぜか落ちる現象の解明
* [ ] livereload 的なもの
* [ ] browserify?
* [x] webrx
* [ ] view
	* [x] editor view
	* [x] preview view
	* [ ] access view
	* [ ] view を独立したコンポーネントにする
* layout
    * [ ] split bar
        * [ ] 移動可能にする
    * [ ] pane を動的に構成する
	* [ ] layout manager
		* [ ] 縦
		* [ ] 横 (main)
* [ ] ステータスバー
* [ ] tab キーの挙動を変える
* アプリケーション名変更
* メニュー
* ショートカットキー
* css
	- [x] reset
	- preview 用
* [ ] web
* [ ] 絵文字対応

* [ ] システムダイアログ
	- [ ] font-selector
