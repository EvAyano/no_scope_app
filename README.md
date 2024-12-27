# 🎯 **No Scope**

## 🌟 **アプリを作った理由**

No Scope は日本の FPS プレイヤーが気軽に海外のプレイヤーともコミュニケーションができるようになる手助けをするアプリです。"No Scope" という名前は、「スコープを覗かずに素早く的を定め撃つテクニックであり、スコープを覗く必要もないくらい素早く英語フレーズが出てくることを目指す」という思いが込められています。

## 🚀 **Starting the App**

To start the app, use the following command:

```sh
docker-compose up
```

## 📜 **Running Rails Commands (Docker)**

To run Rails commands within the Docker environment, use the following format:

```sh
docker-compose exec <app_name> bundle exec rails <rails_command>
```

Example:

```sh
docker-compose exec web bundle exec rails db:seed
```

> **Note:** The `web` app name comes from the 

docker-compose.yml

 file. There is no need to go inside the container to run these commands.

## 🛠️ **Running Commands (No Docker)**

### **Start the app**

```sh
./bin/rails server 
OR
bundle exec rails server
```

### **Start the database**

```sh
docker-compose up
```

### **Migrate the database**

```sh
bundle exec rails db:migrate
```

### **Seed the database**

```sh
bundle exec rails db:seed
```

### **Compile assets**

```sh
bundle exec rake assets:precompile
```

## ✨**機能**

1. **Word List**: FPS でよく使われる単語のリストを確認
2. **Word Quiz**: 日本語の単語から意味が一致する英単語を 4 択の中から選ぶクイズが出題される(全10問)
3. **Quiz History**: 過去に受けたクイズの結果履歴が残ります
4. **Account**: 一般的なアカウント機能
5. **Guest**: アカウントを作成せずとも Word List を閲覧したり、Word Quiz を受けることができます

## 📖  **使い方**

- **Word List**: 確認したい英単語をアルファベットのボタンでフィルターし、その意味や詳細を確認
- **Word Quiz**: FPS 用語を覚えたり、どの程度知っているか確認するためのクイズ。アカウントにログインして受けると過去のクイズ履歴一覧にログが残ります。

## 💡 **こだわり**

- **追加予定**: Engaging quizzes that make learning fun and effective.
```

