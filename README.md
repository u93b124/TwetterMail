#TwitterMail

##Overview
* Twitterによるショップ情報を監視し、重要なツイートを即時携帯メールアドレスへ配信します。

##Feature
* Twitter上の特定の複数アカウントからキーワードにマッチしたツイートがあった場合、指定のアドレスに配信する
* 指定した時間により、夜間帯となる時間は、携帯電話ではなくＰＣメールアドレスへ配信する

##Requirements
* ruby1.9.2がインストールされていること
* Windows OS
* インターネットに常時接続できる環境
* gmailアカウントを保有すること
* 送信先の携帯電話メールアドレスを所有すること（NTT Docomoなど）
* Twitter Oauth認証キーを取得していること

##Getting Start
* メール送信SMTPアカウントを取得する（gmail推奨）
* TwitterにログインしOAuth認証キーを取得する
    * CONSUMER_KEY        = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
    * CONSUMER_SECRET     = 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
    * ACCESS_TOKEN        = 'ccccccccccccccccccccccccccccccccccccc'
    * ACCESS_TOKEN_SECRET = 'ddddddddddddddddddddddddddddddddddddd'
* 必要なgemのinstallを行う
    * gem install oauth
    * gem install action_mailer
    * gem 'mail-iso-2022-jp'
* TwitterMail.rbソースコードの修正  
    * 設定１ アプリ設定を修正
    * 設定２ 監視したいTwitterアカウントを修正
    * 設定３ Twitter OAuth認証用のキーを修正
    * 設定４ SMTPサーバのアカウントを修正  

##Usage
rubyのインストールディレクトリが、c:\ruby である場合  

c:\ruby\ruby TwitterMail.rb  

で実行  

上記コマンドをタスクスケジューラに登録し、10分毎に起動させる

