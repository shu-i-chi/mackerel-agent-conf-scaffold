> [!NOTE]  
> ------------------------------↓↓↓------------------------------
>
> 「[初めてのセットアップ手順](#初めてのセットアップ手順)」が完了したら、この部分は削除してください。

# mackerel-agent-conf-scaffold
 
Mackerel Agentの設定ファイル[mackerel-agent.conf](https://mackerel.io/ja/docs/entry/spec/agent)をGit管理するGitリポジトリの雛形です。
 
## 初めてのセットアップ手順
 
このリポジトリの中身を/etc/mackerel-agent配下に移すことで、
 
* mackerel-agent.confの配置
* カスタムメトリクス用スクリプトの配置（/etc/mackerel-agent/custom_metrics_scripts配下）
* /etc/mackerel-agentディレクトリのGitリポジトリ化
 
を同時に行います。
 
### 前提条件
 
Mackerel Agentをインストールして使うホストが、以下を満たしている必要があります：
 
* gitをインストール済み
* /etc/mackerel-agentディレクトリを作成済み
* /etc/mackerel-agentディレクトリがGitリポジトリになって**いない**（.gitディレクトリが存在し**ない**）
* /etc/mackerel-agentディレクトリ配下に、以下を置いて**いない**：
  * ファイル：
    * **mackerel-agent.conf**
    * setup.sh
    * README.md
    * LICENSE
  * ディレクトリ：
    * custom_metrics_scripts（カスタムメトリクス用のスクリプト置き場）
 
これらの条件を満たしていない場合、setup.shは処理を中止します。
 
> [!IMPORTANT]  
> [Mackerel Agentをインストール](https://mackerel.io/ja/docs/entry/howto/install-agent)した直後では、サンプルの/etc/mackerel-agent/mackerel-agent.confが存在しています。
> 
> この状態でsetup.shを実行しても、事故防止のためにストップするようになっていますので、このmackerel-agent.confは別ディレクトリに退避するなどした上で、setup.shを実行してください。
 
### セットアップ
 
このGitリポジトリを、Mackerel Agentホスト上の任意の場所に`git clone`します：
 
```bash
git clone https://github.com/shu-i-chi/mackerel-agent-conf-scaffold.git mackerel-agent-conf
```
 
`git clone`してきたリポジトリ内のsetup.shを実行します：
 
```bash
./mackerel-agent-conf/setup.sh
```
 
[前提条件](#前提条件)が満たされていない場合、エラー表示が出ます。
対応の後、もう一度setup.shを実行し直してください。
 
`🎉Mission accomplished!`が表示されたら完了です。
 
`git clone`してできたディレクトリは、不要なので削除されています。
 
## 自分のリモートGitリポジトリを`git push`先として登録する
 
/etc/mackerel-agentディレクトリに移動します：
 
```bash
cd /etc/mackerel-agent
```
 
このディレクトリは、手順[セットアップ](#セットアップ)にてGitリポジトリになっています。
 
`git push`の宛先を、自分の（空の）リモートGitリポジトリに変更します：
 
```bash
git remote set-url origin <your remote Git repository URL>
```
 
設定変更が成功しているかどうかを確認するには、`git remote -v`をしてください。
 
> [!WARNING]  
> mackerel-agent.confにはAPIキーを直接記述するため、 **リモートGitリポジトリの公開範囲には細心の注意を払ってください** 。
 
## このREADME.mdを編集する
 
このREADME.mdのこの部分を削除してください。
また、他の部分も自分の用途に合うように修正してください。
 
* [1. セットアップ](#1-セットアップ)冒頭の、リポジトリURL部分（`<your remote Git repository URL>`）

> [!NOTE]  
> 「[初めてのセットアップ手順](#初めてのセットアップ手順)」が完了したら、この部分は削除してください。
> ------------------------------↑↑↑------------------------------

# mackerel-agent-conf

Mackerel Agentの設定ファイル[mackerel-agent.conf](https://mackerel.io/ja/docs/entry/spec/agent)をGit管理するGitリポジトリです。

Mackerel Agentホスト上に簡単にセットアップするためのスクリプトsetup.shも用意しています。

> [!NOTE]  
> 以下、mackerel-agent.confの設置ディレクトリを **/etc/mackerel-agent** と仮定しています。
> もしこれと異なる場合は、パスを読み替えてください。また、setup.shの以下の行を変更してくだい：
> ```bash:setup.sh
> mackerel_agent_conf_dir="/etc/mackerel-agent"
> ```

## 目次

* [セットアップ方法](#セットアップ方法)
  * [0. 前提条件](#0-前提条件)
  * [1. セットアップ](#1-セットアップ)
* [mackerel-agent.confファイルの更新フロー](#mackerel-agentconfファイルの更新フロー)
* [リモートGitリポジトリの最新の状態を反映する](#リモートgitリポジトリの最新の状態を反映する)
* [Git管理するファイル・ディレクトリを増やすとき](#git管理するファイルディレクトリを増やすとき)

## セットアップ方法

このリポジトリの中身を/etc/mackerel-agent配下に移すことで、

* mackerel-agent.confの配置
* カスタムメトリクススクリプトの配置（/etc/mackerel-agent/custom_metrics_scripts配下）
* /etc/mackerel-agentディレクトリのGitリポジトリ化

を同時に行います。

### 0. 前提条件

Mackerel Agentをインストールして使うホストが、以下を満たしている必要があります：

* gitをインストール済み
* /etc/mackerel-agentディレクトリを作成済み
* /etc/mackerel-agentディレクトリがGitリポジトリになって**いない**（.gitディレクトリが存在し**ない**）
* /etc/mackerel-agentディレクトリ配下に、以下を置いて**いない**：
  * ファイル：
    * **mackerel-agent.conf**
    * setup.sh
    * README.md
    * LICENSE
  * ディレクトリ：
    * custom_metrics_scripts（カスタムメトリクス用のスクリプト置き場）

これらの条件を満たしていない場合、setup.shは処理を中止します。

> [!IMPORTANT]  
> [Mackerel Agentをインストール](https://mackerel.io/ja/docs/entry/howto/install-agent)した直後では、サンプルの/etc/mackerel-agent/mackerel-agent.confが存在しています。
> 
> この状態でsetup.shを実行しても、事故防止のためにストップするようになっていますので、このmackerel-agent.confは別ディレクトリに退避するなどした上で、setup.shを実行してください。

### 1. セットアップ

このGitリポジトリを、Mackerel Agentホスト上の任意の場所に`git clone`します：

```bash
git clone <your remote Git repository URL> mackerel-agent-conf
```

`git clone`してきたリポジトリ内のsetup.shを実行します：

```bash
./mackerel-agent-conf/setup.sh
```

[0. 前提条件](#0-前提条件)が満たされていない場合、エラー表示が出ます。
対応の後、もう一度setup.shを実行し直してください。

`🎉Mission accomplished!`が表示されたら完了です。

`git clone`してできたディレクトリは、不要なので削除されています。

## mackerel-agent.confファイルの更新フロー

> [!NOTE]  
> [セットアップ方法](#セットアップ方法)の手順が完了しているものとします。

通常のGitのフローと同じです。

1. /etc/mackerel-agentディレクトリに移動する

  ```bash
  cd /etc/mackerel-agent
  ```

2. /etc/mackerel-agent/mackerel-agent.confファイルを直接編集する

3. 変更した /etc/mackerel-agent/mackerel-agent.confファイルを`git add`＆`git commit`する

4. リモートGitリポジトリに`git push`する

## リモートGitリポジトリの最新の状態を反映する

> [!NOTE]  
> [セットアップ方法](#セットアップ方法)の手順が完了しているものとします。

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

> [!WARNING]  
> コミットしていない変更や、ファイル変更のコンフリクトがある場合は、当然`git pull`に失敗します。
> 原因を解消してから、再度`git pull`してください。

## Git管理するファイル・ディレクトリを増やすとき

新しいファイルをコミットしてGit管理するファイル・ディレクトリを増やす場合は、setup.shの以下の行も編集してください：

* ファイル：

  ```bash:setup.sh
  moved_files=("mackerel-agent.conf" "setup.sh" "README.md" "LICENSE")
  ```

* ディレクトリ：

  ```
  moved_dirs=("custom_metrics_scripts")
  ```

新しいファイル・ディレクトリ名をダブルクォート`"`で囲み、半角スペース` `区切りで追加します。

例（ファイルnew-file-1とnew-file-2を追加）：

```bash:setup.sh
moved_files=("mackerel-agent.conf" "setup.sh" "README.md" "LICENSE" "new-file-1" "new-file-2")
```

また、このREADME.mdの[0. 前提条件](#0-前提条件)の部分にも、ファイル名を忘れずに追記してください。
