# coding: utf-8
#!/usr/bin/env ruby
################################################################################################
# Twitter　キーワード自動収集プログラム
#   概要    : 対象アカウントTweetにキーワードが含まれているか監視し、携帯メールに報告する
#   使用方法: batファイル中に [ruby 当ファイル.rb] 記述、Windowsタスクスケジューラにて起動
#   処理形態: バッチ処理（タスクスケジューラにて10分毎に設定）
#   Create  : 2011/11/22
#   Update  : 2011/12/13 Ver1.1 複数件メールされてしまうバグを修正
#           : 2013/2/3   Ver1.2 action_mailer最新版に対応
#   Ver     : 1.2
#   Autohor : Tsuyoshi Suzuki
#   Usage   : gem install action_mailer
#             gem install oauth
#             gem install mail-iso-2022-jp
#             c:\ruby\testmai.rb
################################################################################################

#############################################################################
# 初期設定                                                                  #
#############################################################################
require 'rubygems'
require 'oauth'
require 'json'
require 'nkf'
require 'kconv'
require "action_mailer"
require 'time'

# グローバル変数の初期化
$body       = ""                       # メール本文（初期値は"")
$mailflg    = 0                        # 送信判定フラグ  0:送信しない／1:送信する

# 設定１ アプリ設定を行ってください
MAIL_HEADER     = "twitter自動収集情報"    # 送信メールタイトル
KEY_WORD        = "@@@@"                   # Twitterで監視対象とするキーワード（設定してください）
CHECK_TIME      = 600                      # 監視間隔を600秒(10分)、タスクスケジューラ周期に合わせる
START_TIME      = "09:00"                  # 日中用 携帯メール時間（開始時刻）
END_TIME        = "22:00"                  # 日中用 携帯メール時間（終了時刻）
GETING_TWEET    =  5                       # １回の処理のツイート取得数上限
TO_ADDR_DAYTIME = "xxxxxx@docomo.ne.jp"    # 日中用 携帯メールアドレス
TO_ADDR_NIGHT   = "xxxxxx@yahoo.co.jp"     # 夜間用 PCメールアドレス

# 設定２　監視したいTwitterアカウント を設定してください
$user_name  = ["getchuakiba","99tan_info","sofmap_ams_tvg",
"gamers_no_gema","AkibaSofmap_hby","sofmap_ams_r18","AkibaSofmap_PCG","animateakiba"]
# げっちゅ屋／メディオ／つくもたんINFO／SofmapAM-TVG／ゲーマーズ／Sofmap1号店／
# SofmapAM-hoby／SofmapR18／Sofmap_PCG／アニメイト秋葉原


# 設定３　Twitter OAuth認証用のキー設定してください
CONSUMER_KEY        = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
CONSUMER_SECRET     = 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
ACCESS_TOKEN        = 'ccccccccccccccccccccccccccccccccccccc'
ACCESS_TOKEN_SECRET = 'ddddddddddddddddddddddddddddddddddddd'

# 設定４ SMTPサーバのアカウントを設定してください（gmail推奨）
SMTP_ADDRESS        = 'smtp.gmail.com'
SMTP_PORT           = 587
SMTP_DOMAIN         = 'gmail.com'
SMTP_USER           = 'userxxxx'
SMTP_PASS           = 'passxxxx'

consumer = OAuth::Consumer.new(
  CONSUMER_KEY,
  CONSUMER_SECRET,
  :site => 'http://twitter.com'
)

access_token = OAuth::AccessToken.new(
  consumer,
  ACCESS_TOKEN,
  ACCESS_TOKEN_SECRET
)
#############################################################################
#  メールヘッダ、本文の設定                                                 #
#############################################################################
# ActionMailerの派生クラスを定義
class HogeMailer < ActionMailer::Base

  # メールの設定
  def mail_send(toaddr, mySubject, myBody)
    
    mail(
      charset: 'ISO-2022-JP',
      to:       toaddr,
      from:     'hoge.hoge@hoge.com',
      subject:  mySubject ,
      body:     myBody.to_s
    )

  end

end
#############################################################################
#  SMTPサーバへのアクセス設定                                               #
#############################################################################
ActionMailer::Base.smtp_settings = { :address => SMTP_ADDRESS,
                                     :port => SMTP_PORT,
                                     :domain => SMTP_DOMAIN,
                                     :user_name => SMTP_USER,
                                     :password => SMTP_PASS,
                                     :authentication => :login}
#############################################################################
# メインループ処理    監視対象としたTwitterアカウントを順番に処理する       #
#############################################################################
for user_name_wk in $user_name do

  # jsonAPIを呼び出し、GETING_TWEETで指定した個数分のツイートを取得する
  $url_moji = "http://api.twitter.com/1/statuses/user_timeline.json?screen_name=" + 
              user_name_wk + "&count=#{GETING_TWEET}"

  # アクセストークンよりログインし、ツイートを取得
  response = access_token.get($url_moji)

  # 取得したjson形式のツイートを１つずつ取り出し、それが無くなるまで処理する
  JSON.parse(response.body).reverse_each do |status|
    
    # userタイムラインのstatusセクションの取得

    user = status['user']

    # キーワード を含むかどうかを検索する
    taisho_moji = NKF.nkf('-w',"#{status['text']}")      # responseをUTF-8に変換してからマッチ
    check = taisho_moji.include?(KEY_WORD)               # キーワードが含まれるかチェック

    # キーワードが含まれている場合の処理
    if check
      # 時間判定用にタイムラインの発言時刻を取得する
      hatugen_time =  Time.parse(NKF.nkf('-s', "#{status['created_at']} "))
      $now_time  = Time.now

      # 読み飛ばし判定用　check2 初期値　[0:読み飛ばしを行わない]
      check2 = 0

      # 発言時刻が600秒（10分）以前なら check2 に [1:読み飛ばし] を設定
      if $now_time - CHECK_TIME > hatugen_time
        check2 = 1
      end

      # 読み飛ばしフラグ check2 がオフならメール送信処理へ
      if check2 == 0
       # body変数にセット
        puts  $body = NKF.nkf('-s', "#{user['name']}(#{user['screen_name']}) \n #{status['created_at']}  : #{status['text']} \n")

        # メール送信用フラグのセット
        $mailflg = 1

        ##### ↓↓↓↓↓↓　以降はメール送信処理へ　↓↓↓↓↓↓ #####

      end  # if(check2)の終わり

    # キーワードが含まれない場合
    else
      # 何も処理しない
    end # if(check)の終わり

  end # do(JSON.parse)の終わり
end # for文の終わり

#############################################################################
# メール送信処理                                                            #
# 上の処理で $body 変数に格納した本文をメール送信                           #
#############################################################################

# メール本文が発生した時のみメール送信する
if $mailflg == 1

  # 日中は携帯電話のアドレスへ送信
  if $now_time > Time.parse(START_TIME) && $now_time < Time.parse(END_TIME)
    puts("KEITAI-MAIL")
    HogeMailer.mail_send(TO_ADDR_DAYTIME, MAIL_HEADER, $body).deliver

  # 夜間はＰＣメールへ送信
  else
    puts("PC-MAIL") 
    HogeMailer.mail_send(TO_ADDR_NIGHT, MAIL_HEADER, $body).deliver
  end

end



