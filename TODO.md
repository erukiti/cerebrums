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
* [ ] livereload 的なもの
* [ ] browserify?
* [ ] coffee script の行番号がズレる現象の究明

* リファクタリング
	- [ ] view を独立したコンポーネントにする
    - [ ] pane を動的に構成する
	- [ ] ファイルアクセスをメインプロセスに移動する
	- [ ] mainViewModel.constructor の引数でpane数を指定してpaneを作成する
		* [ ] setElemをイベント駆動 (onReady的な)にする
	- [ ] 順番が前後しても正常に動くようにする
	- editor -> preview のつなぎ込みをもうちょっとマシにする
		* [ ] class の外に散らばってるロジックを class におさめる
		* [ ] panes.get() の決め打ちをなくす
	- pane0/pane1 をそれぞれ決め打ちしてる状況をやめる
* [ ] 足回りに遅延処理を導入する
	- [ ] 検索インデックス作成
* [ ] FmIndex#decodeAll

* [ ] split barを動かせるようにする
* [ ] tab キーの挙動を変える
* [ ] エディタの末尾でスペースやtabを入力しても駄目な現象の解明
* [ ] カーソル上下で、タイトル・本文を移動できるようにする
* [ ] 初期フォーカス設定
* [ ] 外部CSS

* タブ
	- [ ] タブの見た目を整える
	- [ ] タブを閉じるときにうまく view / preview を更新する
	- [ ] タブをDnDで移動する
	- [ ] 新規タブボタンを tab bar に表示する
	- [ ] タブ表示をスクロールするように変更
* access view を強化する
	- [ ] カーソルを上下に移動できるようにする
	- [ ] コンテキストメニュー
* [ ] エラーをステータスバーに表示する
* [ ] オープンしてるファイルの情報を表示する
* [ ] window resize 情報をセーブ / ロード
* [ ] テンポラリ保存
* [ ] 閉じた ViewModel の始末

* アプリケーション名変更
* css
	- [ ] preview 用
* [ ] 絵文字対応
* [ ] code highlight
* [ ] リストの [ ] に対応する？

* [ ] システムダイアログ
	- [ ] font-selector
