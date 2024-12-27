# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

QuizQuestion.destroy_all

Word.destroy_all

words = Word.create([
  { term: "Ace", definition: "一人で敵全員を倒すこと", explanation: "作成中", game_name: "general" },
  { term: "ADS", definition: "エイムダウンサイト、照準をのぞき込むこと", explanation: "対義語:腰撃ち(hip shooting)", game_name: "general" },
  { term: "Anchor", definition: "守りの際に特定の場所に留まり、敵のエリアへの侵入を防ぐプレイヤー", explanation: "元々は船のイカリを意味するが、のちに綱引きで一番後ろにいる屈強で体重が思い選手のことをそう呼ぶようになった。その後リレーの最終走者を指す意味になる。", game_name: "general" },
  { term: "Anti-Eco", definition: "相手がエコラウンドであるラウンド", explanation: "相手の武器が弱いので距離を取って戦ったり数で攻めることが多い", game_name: "general" },
  { term: "Bait", definition: "見方を囮に敵をおびき寄せる戦術", explanation: "「エサ」という意味。ベイトを行うプレイヤーのことを「baiter（ベイター）」と呼ぶ", game_name: "general" },
  { term: "Blind", definition: "敵の視界を奪うこと", explanation: "スカイのフラッシュなど", game_name: "general" },
  { term: "Bonus Round", definition: "ラウンド1とラウンド2で勝ったチームが弱い武器で挑むラウンド", explanation: "1ラウンドで勝って、2ラウンドでピストルより強い武器で勝利した後の3ラウンド目のこと。敵がアサルトライフルなどを持っていても勝てば敵のお金がなくなる。負けても3ラウンド目は2ラウンド目の武器を使用したので4ラウンド目のためのお金がある。", game_name: "general" },
  { term: "Boost", definition: "チームメイトを高い場所に乗せること", explanation: "自分の上に乗ってもらって、普通は乗ることができない高所に登る行為。ブースティング行為とは異なる。", game_name: "general" },
  { term: "Callout", definition: "マップ上の特定の場所を指す用語", explanation: "保留", game_name: "general" },
  { term: "Clutch", definition: "人数不利な厳しい状況から勝利を収めること", explanation: "元々「つかむ」などの意味。バスケでは大事な局面で点を決める選手をクラッチシューターと呼んだりする。", game_name: "general" },
  { term: "Crossfire", definition: "複数の方向から同時に攻撃すること", explanation: "別方向から攻撃することで挟み撃ちにする", game_name: "general" },
  { term: "Cubby", definition: "小さな隠れ場所", explanation: "保留", game_name: "general" },
  { term: "Default", definition: "敵の出方を見てから戦略を決めること", explanation: "大抵の場合はマップ全体に広がり情報を取得したり、敵のアビリティを無駄に使わせたり、マップコントロールすることが目的", game_name: "general" },
  { term: "Defuse", definition: "スパイクを解除すること", explanation: "Fake defuse:解除音を出して解除するフリをすること。Ninja Defuse:アタッカー側に気づかれることなく、こっそり解除すること。", game_name: "general" },
  { term: "Double Peek", definition: "二人のプレイヤーが同時に壁などの遮蔽物から姿をあらわすこと", explanation: "同時にピークすることで一人がキルされてしまってもトレードキルができる", game_name: "general" },
  { term: "Drop", definition: "武器などをチームメイトに渡すこと", explanation: "お金が余っている人が足りない人に買ってあげる場面で使う言葉", game_name: "general" },
  { term: "Eco", definition: "節約ラウンド", explanation: "次のラウンドのために節約しよう", game_name: "general" },
  { term: "Entry", definition: "サイト内に突入すること", explanation: "サイトに最初に入る人のことをEntry Fraggerと呼ぶ", game_name: "general" },
  { term: "Entry Fragger", definition: "最初に敵と交戦する役割のプレイヤー", explanation: "保留", game_name: "general" },
  { term: "Flash", definition: "敵を一時的に目を見えなくする閃光", explanation: "間違えて味方に喰らわせてしまうと厄介なやつ", game_name: "general" },
  { term: "Force Buy", definition: "持ち金全てを使えるだけ使って装備を整えること", explanation: "敵のマッチポイントなどで後がない時などに行う", game_name: "general" },
  { term: "Frag", definition: "敵を倒すこと", explanation: "ベトナム戦争中に、敵に殺されたと見せかけるためにfragmentation grenade（破砕性手りゅう弾）を使って嫌いな上官を殺害したことから転じて、ゲームでは敵を倒すことを意味するようになったらしい", game_name: "general" },
  { term: "Full Buy", definition: "フル装備で戦うラウンド", explanation: "良い武器とシールド、アビリティを揃える。対義語:エコラウンド(eco round)", game_name: "general" },
  { term: "Half Buy", definition: "少しは購入するが、次のラウンドのためにお金を残しておくこと", explanation: "日本語では調整バイと言ったりする", game_name: "general" },
  { term: "Healer", definition: "チームメイトを回復する能力を持つ役割のひと", explanation: "回復ありがとう", game_name: "general" },
  { term: "Heaven", definition: "高所の位置", explanation: "オペレーター持ちがよく居るところ", game_name: "general" },
  { term: "Hell", definition: "低所の位置", explanation: "見える範囲が狭いのでポジション的には弱い", game_name: "general" },
  { term: "Jiggle Peek", definition: "揺れるように素早く左右に動きながらピークすること", explanation: "Jiggleが「揺れる」という意味", game_name: "general" },
  { term: "Lurk", definition: "他のチームメイト(本隊)から離れて隠れ、単独で行動すること", explanation: "「潜む」という意味。", game_name: "general" },
  { term: "Molly", definition: "燃えるエリアを作るグレネード", explanation: "踏んだらダメージを喰らうアレ", game_name: "general" },
  { term: "One-tap", definition: "一発でキルすること、あるいは一発でキルされるくらい瀕死のプレイヤーやその状態のこと", explanation: "tapが「軽く叩く」という意味。", game_name: "general" },
  { term: "OP", definition: "オペレーター、強力なスナイパーライフル。あるいは非常に強いこと。", explanation: "Operatorの略。「非常に強いこと」を意味する場合はOver Poweredの略", game_name: "general" },
  { term: "Peek", definition: "遮蔽物から姿を出すこと", explanation: "Double PeekやJiggle Peekなど種類も多くある", game_name: "general" },
  { term: "Ping", definition: "特定の場所を指示するためのマークあるいはネットワーク通信の応答速度を表す数値", explanation: "どちらの意味かは文脈で判断するしかないかも", game_name: "general" },
  { term: "Plant", definition: "爆弾を設置すること", explanation: "「植物」の意味でよく使われる単語だが、（爆弾を）仕掛けるという動詞の意味もある", game_name: "general" },
  { term: "Pre-fire", definition: "敵がいる可能性のある場所を敵が視界に入る前に撃つこと", explanation: "敵が見えた瞬間には既に射撃している状態なので強い", game_name: "general" },
  { term: "Push", definition: "攻めること", explanation: "一般的な意味の「押す」というイメージで覚えやすいかも", game_name: "general" },
  { term: "Recon", definition: "敵の位置を探るための能力", explanation: "「reconnaissance」という単語の省略バージョン。偵察という意味。", game_name: "general" },
  { term: "Rotate", definition: "別のサイトに移動すること", explanation: "日本語でプレイするときの、いわゆるローテのこと", game_name: "general" },
  { term: "Save", definition: "次のラウンドのために武器を保持すること", explanation: "ほぼ負けが確定したラウンドでオペレーターを持っているプレイヤーなどがよくやる。サイトに近寄らず、できるだけ隠れる行動", game_name: "general" },
  { term: "Smoke", definition: "視界を遮るための煙", explanation: "作成中", game_name: "general" },
  { term: "Spike", definition: "爆弾のこと", explanation: "作成中", game_name: "VALORANT" },
  { term: "Spray Control", definition: "連射時のリコイルを制御すること", explanation: "sprayが「連射する」という意味。", game_name: "general" },
  { term: "Stack", definition: "複数のプレイヤーが同じ場所に留まること", explanation: "「積む」という意味。プレイヤーを積む＝複数人で一定の箇所に居る というイメージで覚えやすいかも", game_name: "general" },
  { term: "Swing", definition: "遮蔽物から姿を出すこと。あるいは遮蔽物から大きく姿を出すこと。", explanation: "peekと同じ意味で使われたり、遮蔽物から大きく姿を出す（wide peek）の意味で使われたりする。", game_name: "general" },
  { term: "Wallbang", definition: "壁を通して敵を撃つこと", explanation: "保留", game_name: "general" }
])

puts "Created #{words.count} words."
