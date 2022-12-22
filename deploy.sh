#!/bin/bash

mackerel_agent_conf_directory="/etc/mackerel-agent"

deployed_files=("mackerel-agent.conf" "deploy.sh" "README.md" "LICENSE")

# ---

c_ok="\e[32m"  # 成功時の色
c_err="\e[31m" # 失敗時の色
c_hl="\e[33m"  # ハイライト（'H'igh'L'ight）の色

c_off="\e[m"   # 色リセット

# ---

echo "Start deployment."

# git cloneしてきたGitリポジトリの中（＝このdeploy.shと同じディレクトリ）に移動

cd $(dirname $0)
echo "Moved to $(pwd)."

# 1. ${mackerel_agent_conf_directory}の存在チェック

if [ ! -d "${mackerel_agent_conf_directory}" ]; then
  echo -e "[1/5] ${c_err}ERROR${c_off} There is no ${c_hl}${mackerel_agent_conf_directory}${c_off} directory."
  exit 1
fi

echo -e "[1/5] ${c_ok}OK${c_off} ${c_hl}${mackerel_agent_conf_directory}${c_off} exists."

# 2. ファイルチェック

disallowed_files=()
missing_files=()

for deployed_file in ${deployed_files[@]}; do
  deployed_file_fullpath="${mackerel_agent_conf_directory}/${deployed_file}"

  if [ -f "${deployed_file_fullpath}" ]; then
    disallowed_files+=("${deployed_file_fullpath}")
  fi

  if [ ! -f "./${deployed_file}" ]; then
    missing_files+=("${deployed_file}")
  fi
done

## 2-1. ${mackerel_agent_conf_directory}の中身チェック

if [ -d "${mackerel_agent_conf_directory}/.git" ]; then
  echo -e "[2/5] ${c_err}ERROR${c_off} ${c_hl}${mackerel_agent_conf_directory}${c_off} is already a Git repository."
  exit 1
fi

if [ "${#disallowed_files[@]}" -gt 0 ]; then
  echo -e "[2/5] ${c_err}ERROR${c_off} Remove files listed below from ${c_hl}${mackerel_agent_conf_directory}${c_off}:"

  for disallowed_file in ${disallowed_files[@]}; do
    echo "  x ${disallowed_file}"
  done

  exit 1
fi

## 2-2. このリポジトリ内に、必要なファイルが全て揃っているかをチェック

if [ ! -d "./.git" ]; then
  echo -e "[2/5] ${c_err}ERROR${c_off} Missing .git directory in this directory (${c_hl}$(pwd)${c_off})."
  exit 1
fi

if [ "${#missing_files[@]}" -gt 0 ]; then
  echo -e "[2/5] ${c_err}ERROR${c_off} Missing files listed below in thie directory (${c_hl}$(pwd)${c_off}):"

  for missing_file in ${missing_files[@]}; do
    echo "  ? ${missing_file}"
  done

  exit 1
fi

echo -e "[2/5] ${c_ok}OK${c_off} File checks completed."

# 3. このリポジトリ内のファイル・ディレクトリを${mackerel_agent_conf_directory}配下に移動

echo -e "[3/5] Move files from ${c_hl}$(pwd)${c_off} to ${c_hl}${mackerel_agent_conf_directory}${c_off}:"

for deployed_file in ${deployed_files[@]}; do
  sudo mv "./${deployed_file}" ${mackerel_agent_conf_directory}

  deployed_file_basename=$(basename ${deployed_file})
  echo "  * ${deployed_file} -> ${mackerel_agent_conf_directory}/${deployed_file_basename}"
done

sudo mv "./.git/" ${mackerel_agent_conf_directory}
echo "  * .git/ -> ${mackerel_agent_conf_directory}/.git/"

# 4. 3のファイル・ディレクトリ移動がうまくできているかどうかをチェック

deployment_failed_files=()

for deployed_file in ${deployed_files[@]}; do
  if [ ! -f "${mackerel_agent_conf_directory}/${deployed_file}" ]; then
    deployment_failed_files+=("${deployed_file}")
  fi

  if [ ! -d "${mackerel_agent_conf_directory}/.git" ]; then
    deployment_failed_files+=(".git/")
  fi
done

if [ "${#deployment_failed_files[@]}" -gt 0 ]; then
  echo -e "[4/5] ${c_err}ERROR${c_off} Moving files listed below failed:"

  for deployment_failed_file in ${deployment_failed_files[@]}; do
    echo "  x ${deployment_failed_file}"
  done

  exit 1
fi

echo -e "[4/5] ${c_ok}OK${c_off} All files have been successfully moved."

# 5. このディレクトリを削除（掃除）

git_cloned_directory=$(pwd)

cd ..
rm -rf ${git_cloned_directory}

if [ -d "${git_cloned_directory}" ]; then
  echo -e "[5/5] ${c_err}ERROR${c_off} Removing ${c_hl}${git_cloned_directory}${c_off} failed."
fi

echo -e "[5/5] ${c_ok}OK${c_off} Removed ${c_hl}${git_cloned_directory}${c_off}."

echo "🎉Mission accomplished!"
