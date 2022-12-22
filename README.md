# mackerel-agent-conf-scaffold

Mackerel Agentの設定ファイル[mackerel-agent.conf](https://mackerel.io/ja/docs/entry/spec/agent)をGit管理するGitリポジトリの雛形です。

Mackerel Agentホスト上に簡単にデプロイするためのスクリプトdeploy.shも用意しています。

> **Note**  
> 以下、mackerel-agent.confの設置ディレクトリを **/etc/mackerel-agent** と仮定しています。
> もしこれと異なる場合は、パスを読み替えてください。また、deploy.shの以下の行を変更してくだい：
> ```bash:deploy.sh
> mackerel_agent_conf_directory="/etc/mackerel-agent"
> ```

## 目次

* [デプロイ方法](#デプロイ方法)
  * [0. 前提条件](#0-前提条件)
  * [1. デプロイ](#1-デプロイ)
  * [2. /etc/mackerel-agent-confディレクトリを、gitの`safe.directory`に追加する](#2-etcmackerel-agent-confディレクトリをgitのsafedirectoryに追加する)
  * [3. 自分のリモートGitリポジトリを`git push`先として登録する](#3-自分のリモートGitリポジトリをgit-push先として登録する)
* [mackerel-agent.confファイルの更新フロー](#mackerel-agentconfファイルの更新フロー)
* [Git管理するファイルを増やすとき](#Git管理するファイルを増やすとき)
* [mackerel-agent.confファイルを、リモートGitリポジトリの最新の状態にする](#mackerel-agentconfファイルをリモートGitリポジトリの最新の状態にする)

## デプロイ方法

このリポジトリの中身を/etc/mackerel-agent配下に移すことで、

* mackerel-agent.confの配置
* /etc/mackerel-agentディレクトリのGitリポジトリ化

を同時に行います。

### 0. 前提条件

Mackerel Agentをインストールして使うホストが、以下を満たしている必要があります：

* gitがインストールされている
* /etc/mackerel-agentディレクトリが作成されている
* /etc/mackerel-agentディレクトリがGitリポジトリになって**いない**（.gitディレクトリが存在し**ない**）
* /etc/mackerel-agentディレクトリ配下に、以下のファイルを置いて**いない**：
  * mackerel-agent.conf
  * deploy.sh
  * README.md
  * LICENSE

これらの条件を満たしていない場合、deploy.shは処理を中止します。

### 1. デプロイ

このGitリポジトリを、Mackerel Agentホスト上の任意の場所に`git clone`します：

```bash
git clone https://github.com/shu-i-chi/mackerel-agent-conf-scaffold.git mackerel-agent-conf
```

`git clone`してきたリポジトリ内のdeploy.shを実行します：

```bash
./mackerel-agent-conf/deploy.sh
```

[0. 前提条件](#0-前提条件)が満たされていない場合、エラー表示が出ます。
対応の後、もう一度deploy.shを実行し直してください。

`🎉Mission accomplished!`が表示されたら完了です。

`git clone`してできたディレクトリは、不要なので削除されています。

### 2. /etc/mackerel-agent-confディレクトリを、gitの`safe.directory`に追加する

/etcの所有者はrootなので、一般ユーザとして`git`コマンドを実行するために、/etc/mackerel-agent-confディレクトリをgitの`safe.directory`に追加します：

```bash
git config --global --add safe.directory /etc/mackerel-agent
```

### 3. 自分のリモートGitリポジトリを`git push`先として登録する

/etc/mackerel-agentディレクトリに移動します：

```bash
cd /etc/mackerel-agent
```

このディレクトリは、手順[1. デプロイ](#1-デプロイ)にてGitリポジトリになっています。

`git push`の宛先を、自分の（空の）リモートGitリポジトリに変更します：

```bash
git remote set-url origin <your-remote-git-repository-url>
```

設定変更が成功しているかどうかを確認するには、`git remote -v`をしてください。

> **Warning**  
> mackerel-agent.confにはAPIキーを直接記述するため、 **リモートGitリポジトリの公開範囲には細心の注意を払ってください** 。

## mackerel-agent.confファイルの更新フロー

> **Note**  
> [デプロイ方法](#デプロイ方法)の手順が完了しているものとします。

通常のGitのフローと同じです。

1. /etc/mackerel-agentディレクトリに移動する

  ```bash
  cd /etc/mackerel-agent
  ```

2. /etc/mackerel-agent/mackerel-agent.confファイルを直接編集する

3. 変更した /etc/mackerel-agent/mackerel-agent.confファイルを`git add`＆`git commit`する

4. リモートGitリポジトリに`git push`する

## Git管理するファイルを増やすとき

新しいファイルをコミットしてGit管理するファイルを増やす場合は、deploy.shの以下の行も編集してください：

```bash:deploy.sh
deployed_files=("mackerel-agent.conf" "deploy.sh" "README.md" "LICENSE")
```

新しいファイル名をダブルクォート`"`で囲み、半角スペース` `区切りで追加します。

例（ファイルnew-file-1とnew-file-2を追加）：

```bash:deploy.sh
deployed_files=("mackerel-agent.conf" "deploy.sh" "README.md" "LICENSE" "new-file-1" "new-file-2")
```

また、このREADME.mdの[0. 前提条件](#0-前提条件)の部分にも、ファイル名を忘れずに追記してください。

## mackerel-agent.confファイルを、リモートGitリポジトリの最新の状態にする

> **Note**  
> [デプロイ方法](#デプロイ方法)の手順が完了しているものとします。

自分の既存のリモートGitリポジトリの内容を反映させる手順です。

/etc/mackerel-agentディレクトリに移動します：

```bash
cd /etc/mackerel-agent
```

`main`ブランチに変更します：

```bash
git checkout main
```

`git pull`します：

```
git pull
```

> **Warning**  
> コミットしていない変更や、ファイル変更のコンフリクトがある場合は、当然`git pull`に失敗します。
> 原因を解消してから、再度`git pull`してください。
