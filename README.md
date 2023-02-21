# Cottura! [![Maintainability](https://api.codeclimate.com/v1/badges/77aa114ea3a6302893fb/maintainability)](https://codeclimate.com/github/Aukown1003/cottura/maintainability)
<p align="center"><img src="https://user-images.githubusercontent.com/115121908/219905237-c744a716-9592-4503-ad98-7e6640934eb6.png" alt="Cottura_logo" width="30%" height="30%" ></p>

## サイト概要

### サイトテーマ
投稿、閲覧の出来るレシピサイトです。ユーザーはレシピを投稿したり、他のユーザーが投稿したレシピを見たりする事が出来ます。
またレシピに対してレビューを投稿したり、お気に入り登録を行う事もできます。
<p align="center"><img src="https://user-images.githubusercontent.com/115121908/219905418-4ff5c49c-09a6-4c10-9939-aba4ee5b2fd7.png" alt="index画面"></p>

### テーマを選んだ理由
生活の中で自炊をすることが多々ありますが、以下のような課題を感じています。
- 作る料理が固定化がされモチベーションが下がる
- 作り方を忘れてしまう為、レシピを残しておきたいが、公開はしたくない
- レシピサイトを使用する際、分量を作りたい量に合わせて再計算するのが大変である

特に献立のレパートリーに悩むのは、参考資料にもあるように料理をする人にとっては共通の悩み事であると考えます。
>参考資料 [アイランド株式会社 コロナ禍における家庭料理の変化に関するアンケート調査](https://www.ai-land.co.jp/press/p-ailand/9959/)

>参考資料 [クックパッド株式会社 料理に関するアンケート結果](https://cf.cpcdn.com/info/assets/wp-content/uploads/20140306000000/pr130723-survey.pdf)

またレシピサイトの調査では、サイトを利用する理由について、「新しいメニューの開発」についで、「毎日の献立の参考にするため」が挙げられています。
>参考資料 [株式会社ドゥ・ハウス「レシピサイト」に関する調査結果](https://www.dohouse.co.jp/datacolle/rs20200218/)

日々の献立で使用するので有れば、限られた時間の中で調理を行わなければならない為、時間の記載が重要です。
しかしそれらがレシピ詳細を開くまでわからない事や、そもそも記載が無いなど、ニーズに答えられて無いのでは無いかと感じました。

そこで上記課題を解決できれば、レシピサイトを活用するユーザーの役に立つと考え、今回このアプリケーションの開発を行いました。

### ターゲットユーザ
- レシピを検索したい人
- 自分の作成した料理のレシピを投稿して共有したい人
- レシピを記録したいが公開はしたくない人

### 主な利用シーン
- レシピを投稿する
  - レシピの投稿
  - アレンジした料理を非公開で投稿
- レシピを閲覧する
  - タグを用いた絞り込みで目当てのレシピを検索
  - 気に入ったレシピを保存
  - 作ってみたレシピにレビューを行う
  - 分量を変更して今ある材料に合わせたレシピの表示

### 機能一覧
- ログイン機能
- レシピ投稿機能
- 検索機能
- レビュー機能
- レスポンシブデザイン


## 設計書
- ER図

<img width="1077" alt="ER図" src="https://user-images.githubusercontent.com/115121908/219905208-3f49ef9d-2a23-4254-810d-91effb6b9192.png">

- [テーブル定義書](https://docs.google.com/spreadsheets/d/1jnGbXNi4KXIugBe_R0kpUMbWws8Fr0oqK7ycwsBHSDc/edit#gid=856357510)
- [アプリケーション詳細設計](https://docs.google.com/spreadsheets/d/1AUkGpHbqGblt1CAEtsyFpFhF_2Sv1VkEG0Ie9eaWd5I/edit#gid=0)

## 開発環境
- OS：Linux(CentOS)
- 言語：HTML,CSS,JavaScript,Ruby,SQL
- フレームワーク：Ruby on Rails
- JSライブラリ：jQuery
- IDE：Cloud9

## 使用素材
- [pixabay(画像)](https://pixabay.com/ja/ "pixabay")
- [illust-ac(画像)](https://www.ac-illust.com/ "illust-ac")
- [IFN(アイコン)](https://illustration-free.net/ "IFN")
- [Canva(ロゴ)](https://www.canva.com/ "Canva")