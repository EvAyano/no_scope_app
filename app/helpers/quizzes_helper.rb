module QuizzesHelper
   #テスト中に一時表示する正誤結果のラベル
    def quiz_option_class(choice)
      if choice == @question.word.term
        #正解の選択肢
        @question.user_answer == choice ? "correct-answer" : "correct-answer-dotted"
      elsif choice == @question.user_answer
        #プレイヤーが選んだ不正解の選択肢
        "incorrect-answer"
      else
        #その他の選択肢
        ""
      end
    end

    #クイズ結果ページの正誤ラベル色（pc、モバイル）
    def quiz_result_class_for_pc(question)
      question.correct ? 'result-correct' : 'result-incorrect'
    end
    
    def quiz_result_class_for_mobile(question)
      question.correct ? 'correct-result' : 'incorrect-result'
    end
  end
  