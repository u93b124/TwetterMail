#TwitterMail

##Overview
* Ruby1.92.
* インターネットに接続できる環境

##Feature
* Twitter上の特定の複数アカウントからキーワードにマッチしたツイートがあった場合、指定のアドレスに配信する

##Requirements
* ruby1.9.2がインストールされていること
* Windows OS
* インターネットに常時接続できる環境
* gmailアカウントを保有すること
* 送信先の携帯電話メールアドレスを所有すること（NTT Docomoなど）

##Getting Start
* gem install oauth
* gem install action_mailer
* gem 'mail-iso-2022-jp'

##Usage
rubyのインストールディレクトリが、c:\ruby である場合  

c:\ruby\ruby TwitterMail.rb  

で実行

