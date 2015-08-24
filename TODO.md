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
* 検索の強化
	* [x] AND
	* [ ] OR
	* [ ] 大文字・小文字
* [ ] 文書内検索

* [ ] split barを動かせるようにする
* [ ] tab キーの挙動を変える
* [ ] エディタの末尾でスペースやtabを入力しても駄目な現象の解明
* [ ] カーソル上下で、タイトル・本文を移動できるようにする
* [ ] 初期フォーカス設定
* [ ] 外部CSS

* タグ / star
	* [x] ひとまず対応する
	* [x] 検索で tag: star: に対応する
	* [ ] access view で、タグ、starに対応したいかしたビューを作成する

* タブ
	- [ ] タブの見た目を整える
	- [ ] タブを閉じるときにうまく view / preview を更新する
	- [ ] タブをDnDで移動する
	- [ ] 新規タブボタンを tab bar に表示する
	- [ ] タブ表示をスクロールするように変更
* access view を強化する
	- [ ] カーソルを上下に移動できるようにする
	- [ ] コンテキストメニュー
		https://github.com/atom/electron/blob/master/docs/api/menu.md
	- [ ] リスト表示のテーブルを横に強制的に最大化する
	- [ ] タグに下線を張ってリンク機能を追加する
	- [x] ファイルサイズ情報を追加
* 設定ビュー
	- [ ] ディレクトリ設定
* [ ] エラーをステータスバーに表示する
* [ ] ステータスバーにオープンしてるファイルの情報を表示する
* [ ] window resize 情報をセーブ / ロード
* [ ] 閉じた ViewModel の始末
* [ ] Mac で文字入力がうまくいかない事例の対策
* [x] meta に format version を入れる


* アプリケーション名変更
* css
	- [ ] preview 用
* 絵文字対応
	- [ ] プレビュー画面での絵文字表示
	- [ ] 編集中の絵文字表示 or 補完
* [ ] code highlight
* [ ] リストの [ ] に対応する？

* [ ] システムダイアログ
	- [ ] font-selector
