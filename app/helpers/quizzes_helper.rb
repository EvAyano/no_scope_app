module QuizzesHelper
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
  end
  