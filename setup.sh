#!/bin/bash

mackerel_agent_conf_dir="/etc/mackerel-agent"

copied_files=("mackerel-agent.conf" "setup.sh" "README.md" "LICENSE")
copied_dirs=("custom_metrics_plugins" "check_plugins")

# ---

now_iso8601="$(TZ=JST-9 date --iso-8601='seconds')"

setup_logfiles_dir="setup_logs"
setup_logfile="${setup_logfiles_dir}/setup-$(TZ=JST-9 date -d ${now_iso8601} '+%Y%m%d-%H%M%S').log"

# ---

# DO NOT EDIT

original_repository_url="https://github.com/shu-i-chi/mackerel-agent-conf-scaffold.git"

c_ok="\e[32m" # Color for success (green)
c_ng="\e[31m" # Color for failure (red)
c_hl="\e[33m" # Color for highlight (yellow)
c_st="\e[35m" # Color for strong (magenta)
c_off="\e[m"  # Reset Color

# ---

# Returns 0 if the variable is set, else returns 1.
check_if_variable_set() {
  local variable_name="$1"
  test -n "${!variable_name}"
}

# Creates ${setup_logfile} if it does not exist.
#
# @note Exits with code 1 when mkdir ${setup_logfiles_dir} or touch ${setup_logfile} failed.
create_setup_logfile_if_not_exist() {
  check_if_variable_set "setup_logfiles_dir" || exit 1 
  check_if_variable_set "setup_logfile" || exit 1

  local failed=0

  if [ ! -d "${setup_logfiles_dir}" ]; then
    mkdir -p "${setup_logfiles_dir}" || failed=1

    if [ "${failed}" -eq 1 ]; then
      echo -e "[ ${c_ng}NG${c_off} ] Execute this script (${c_hl}$0${c_off}) with a user who can mkdir ${c_hl}${setup_logfiles_dir}${c_off}." 1>&2
      echo ""

      exit 1
    fi
  fi

  if [ ! -f "${setup_logfile}" ]; then
    touch "${setup_logfile}" || failed=1

    if [ "${failed}" -eq 1 ]; then
      echo -e "[ ${c_ng}NG${c_off} ] Execute this script (${c_hl}$0${c_off}) with a user who can touch ${c_hl}${setup_logfile}${c_off}." 1>&2
      echo ""

      exit 1
    fi
  fi
}

# Prints string on STDOUT and also in ${setup_logfile}.
#
# @note Call this function after a check if script variable ${setup_logfile} is set.
# @note sed removes ASCII escape codes of terminal color control sequences.
# @see https://genzouw.com/entry/2023/02/09/090044/3229/
logprint() {
  create_setup_logfile_if_not_exist

  local message="$1"

  # display message on STDOUT
  echo -e "${message}"

  # log
  echo -e "${message}" | sed -E "s/\x1b\[([0-9]{1,3}((;[0-9]{1,3})*)?)?[mGK]//g" >> "${setup_logfile}"
}

# Prints string on STDERR and also in ${setup_logfile}. (e for error.)
#
# @note Call this function after a check if script variable ${setup_logfile} is set.
# @note sed removes ASCII escape codes of terminal color control sequences.
# @see https://genzouw.com/entry/2023/02/09/090044/3229/
elogprint() {
  create_setup_logfile_if_not_exist

  local message="$1"

  # display message on STDERR
  echo -e "${message}" 1>&2

  # log
  echo -e "${message}" | sed -E "s/\x1b\[([0-9]{1,3}((;[0-9]{1,3})*)?)?[mGK]//g" >> "${setup_logfile}"
}

# Exits with code 1 displaying the setup logfile path.
#
# @note Call this function when exited by errors.
# @example
#
#   elogprint "[ NG ] Failed to copy foobar."
#   error_exit
#
error_exit() {
  logprint ""
  logprint "Setup logfile: ${c_hl}${setup_logfile}${c_off}"
  echo ""

  exit 1
}

# ---

#
# 1. Check this script
#

# Check if all the variables in this script are set

script_variables=(
  "mackerel_agent_conf_dir" "copied_files" "copied_dirs" "now_iso8601" "setup_logfiles_dir" "setup_logfile"
)

unset_script_variables=()

for script_variable in "${script_variables[@]}"; do
  check_if_variable_set "${script_variable}" || unset_script_variables+=("${script_variable}")
done

if [ "${#unset_script_variables[@]}" -gt 0 ]; then
  echo -e "[ ${c_ng}NG${c_off} ] Variables listed below are unset in ${c_hl}$0${c_off}:" 1>&2

  for unset_script_variable in "${unset_script_variables[@]}"; do
    echo -e "         x ${unset_script_variable}" 1>&2
  done
  
  echo ""

  exit 1
fi

#
# 2. Check if git is installed
#

git --version > /dev/null 2>&1

if [ $? -ne 0 ]; then
  echo -e "[ ${c_ng}NG${c_off} ] Install ${c_hl}git${c_off} on this host." 1>&2
  echo ""

  exit 1
fi

#
# 3. Move to this directory
#

# Move to this directory

cd $(dirname "$0")

# Overwrite ${setup_logfiles_dir} and ${setup_logfile}

setup_logfiles_dir="$(pwd)/${setup_logfiles_dir}"
setup_logfile="$(pwd)/${setup_logfile}"

#
# 4. Preparation
#

# Create ${setup_logfile}

create_setup_logfile_if_not_exist

# Set ${current_user}

current_user="$(whoami)"

# Print start messages

echo ""
logprint "Start setup of ${c_hl}${mackerel_agent_conf_dir}${c_off}."
logprint "  Executed by: ${c_hl}${current_user}${c_off}"
logprint "  Executed at: ${c_hl}$(TZ=JST-9 date -d ${now_iso8601} '+%Y-%m-%d-%H:%M:%S %Z')${c_off}"
logprint ""

#
# 5. Check if this directory is a Git repository
#

if [ ! -d "./.git" ]; then
  elogprint "[ ${c_ng}NG${c_off} ] This directory (${c_hl}$(pwd)${c_off}) is not a Git repository."
  error_exit
fi

#
# 6. Check if all the required files/directories exist
#

## copied_files

missing_files=()

for required_file in "${copied_files[@]}"; do
  if [ ! -f "./${required_file}" ]; then
    missing_files+=("${required_file}")
  fi
done

## copied_dirs

missing_dirs=()

for required_dir in "${copied_dirs[@]}"; do
  if [ ! -d "./${required_dir}" ]; then
    missing_dirs+=("${required_dir}")
  fi
done

# error or continue

missing_files_size="${#missing_files[@]}"
missing_dirs_size="${#missing_dirs[@]}"

if [ "${missing_files_size}" -gt 0 ] || [ "${missing_dirs_size}" -gt 0 ]; then
  elogprint "[ ${c_ng}NG${c_off} ] Some files/directories listed below are missing in this repository (${c_hl}$(pwd)${c_off}):"
  
  if [ "${missing_files_size}" -gt 0 ]; then
    elogprint "         Files:"

    for missing_file in "${missing_files[@]}"; do
      elogprint "           ? ${missing_file}"
    done
  fi

  if [ "${missing_dirs_size}" -gt 0 ]; then
    elogprint "         Directories:"

    for missing_dir in "${missing_dirs[@]}"; do
      elogprint "           ? ${missing_dir}/"
    done
  fi

  error_exit
fi

#
# 7. Check if ${mackerel_agent_conf_dir} exists
#

if [ ! -d "${mackerel_agent_conf_dir}" ]; then
  elogprint "[ ${c_ng}NG${c_off} ] There is no ${c_hl}${mackerel_agent_conf_dir}${c_off} directory."
  error_exit
else
  logprint "[ ${c_ok}OK${c_off} ] ${c_hl}${mackerel_agent_conf_dir}${c_off} exists."
fi

#
# 8. Check if ${mackerel_agent_conf_dir} is not a Git repository
#

if [ -d "${mackerel_agent_conf_dir}/.git" ]; then
  elogprint "[ ${c_ng}NG${c_off} ] ${c_hl}${mackerel_agent_conf_dir}${c_off} directory is already a Git repository."
  error_exit
else
  logprint "[ ${c_ok}OK${c_off} ] ${c_hl}${mackerel_agent_conf_dir}${c_off} is not a Git repository."
fi

#
# 9. Check if all the ${copied_files} and ${copied_dirs} do not exist in ${mackerel_agent_conf_dir}
#

## copied_files

already_existing_copied_files=()

for copied_file in "${copied_files[@]}"; do
  target_file="${mackerel_agent_conf_dir}/${copied_file}"

  if [ -f "${target_file}" ]; then
    already_existing_copied_files+=("${copied_file}")
  fi
done

## copied_dirs

already_existing_copied_dirs=()

for copied_dir in "${copied_dirs[@]}"; do
  target_dir="${mackerel_agent_conf_dir}/${copied_dir}"

  if [ -d "${target_dir}" ]; then
    already_existing_copied_dirs+=("${copied_dir}")
  fi
done

# error or continue

already_existing_copied_files_size="${#already_existing_copied_files[@]}"
already_existing_copied_dirs_size="${#already_existing_copied_dirs[@]}"

if [ "${already_existing_copied_files_size}" -gt 0 ] || [ "${already_existing_copied_dirs_size}" -gt 0 ]; then
  elogprint "[ ${c_ng}NG${c_off} ] Some files/directories listed below already exist in ${c_hl}${mackerel_agent_conf_dir}${c_off}:"

  if [ "${already_existing_copied_files_size}" -gt 0 ]; then
    elogprint "         Files:"

    for already_existing_copied_file in "${already_existing_copied_files[@]}"; do
      elogprint "           - ${already_existing_copied_file}"
    done
  fi

  if [ "${already_existing_copied_dirs_size}" -gt 0 ]; then
    elogprint "         Directories:"

    for already_existing_copied_dir in "${already_existing_copied_dirs[@]}"; do
      elogprint "           - ${already_existing_copied_dir}/"
    done
  fi

  error_exit
else
  logprint "[ ${c_ok}OK${c_off} ] All the files/directories listed below do not exist in ${c_hl}${mackerel_agent_conf_dir}${c_off}:"

  logprint "         Files:"

  for copied_file in "${copied_files[@]}"; do
    logprint "           - ${copied_file}"
  done

  logprint "         Directories:"

  for copied_dir in "${copied_dirs[@]}"; do
    logprint "           - ${copied_dir}"
  done
fi

#
# 10. chown ${mackerel_agent_conf_dir} by current user
#

chown_command="sudo chown ${current_user} ${mackerel_agent_conf_dir}"

{ eval "${chown_command}" ; status_chown=$? ; } \
  1> >(tee -a "${setup_logfile}") \
  2> >(tee -a "${setup_logfile}" 1>&2)

if [ "${status_chown}" -ne 0 ]; then
  elogprint "[ ${c_ng}NG${c_off} ] Failed to ${c_hl}${chown_command}${c_off}."
  error_exit
else
  logprint "[ ${c_ok}OK${c_off} ] Succeeded to ${c_hl}${chown_command}${c_off}."
fi

#
# 11. Add .git/ to ${copied_dirs}
#

copied_dirs+=(".git")

#
# 12. Copy ${copied_files} and ${copied_dirs} onto ${mackerel_agent_conf_dir}
#

logprint "[INFO] Copy files/directories onto ${c_hl}${mackerel_agent_conf_dir}${c_off}:"

logprint "         Files:"

for copied_file in "${copied_files[@]}"; do
  { cp "${copied_file}" "${mackerel_agent_conf_dir}" ; status_cp_file=$? ; } \
    1> >(tee -a "${setup_logfile}") \
    2> >(tee -a "${setup_logfile}" 1>&2)

  if [ "${status_cp_file}" -ne 0 ]; then
    elogprint "           x ${c_ng}failed to copy${c_off}: ${copied_file}"
  else
    logprint "           copied: ${copied_file}"
  fi
done

logprint "         Directories:"

for copied_dir in "${copied_dirs[@]}"; do
  { cp -r "${copied_dir}" "${mackerel_agent_conf_dir}" ; status_cp_dir=$? ; } \
    1> >(tee -a "${setup_logfile}") \
    2> >(tee -a "${setup_logfile}" 1>&2)

  if [ "${status_cp_dir}" -ne 0 ]; then
    elogprint "           x ${c_ng}failed to copy${c_off}: ${copied_dir}/"
  else
    logprint "           copied: ${copied_dir}/"
  fi
done

#
# 13. Check if all the ${copied_files} and ${copied_dirs} copied successfully onto ${mackerel_agent_conf_dir}
#

failed_files=()

for copied_file in "${copied_files[@]}"; do
  if [ ! -f "${mackerel_agent_conf_dir}/${copied_file}" ]; then
    failed_files+=("${copied_file}")
  fi
done

failed_dirs=()

for copied_dir in "${copied_dirs[@]}"; do
  if [ ! -d "${mackerel_agent_conf_dir}/${copied_dir}" ]; then
    failed_dirs+=("${copied_dir}")
  fi
done

# error or continue

if [ "${#failed_files[@]}" -gt 0 ] || [ "${#failed_dirs[@]}" -gt 0 ]; then
  elogprint "[ ${c_ng}NG${c_off} ] Failed to copy some files/directories listed below onto ${c_hl}${mackerel_agent_conf_dir}${c_off}:"

  elogprint "         Files:"

  for failed_file in "${failed_files[@]}"; do
    elogprint "           x ${failed_file}"
  done

  elogprint "         Directories:"

  for failed_dir in "${failed_dirs[@]}"; do
    elogprint "           x ${failed_dir}"
  done

  error_exit
else
  logprint "[ ${c_ok}OK${c_off} ] All the files/directories listed below are successfully copied onto ${c_hl}${mackerel_agent_conf_dir}${c_off}:"

  logprint "         Files:"

  for copied_file in "${copied_files[@]}"; do
    logprint "           o ${copied_file}"
  done

  logprint "         Directories:"

  for copied_dir in "${copied_dirs[@]}"; do
    logprint "           o ${copied_dir}"
  done
fi

#
# 14. Delete this directory
#

git_cloned_directory="$(pwd)"

cd ..
rm -rf "${git_cloned_directory}" | tee -a "${setup_logfile}" 1>&2

if [ -d "${git_cloned_directory}" ]; then
  elogprint "[ ${c_ng}NG${c_off} ] Failed to delete ${c_hl}${git_cloned_directory}${c_off}."
  error_exit
else
  echo -e "[ ${c_ok}OK${c_off} ] Successfully deleted ${c_hl}${git_cloned_directory}${c_off}."
fi

#
# 15. Finished!
#

echo ""
echo "🎉Mission accomplished!"
echo ""

#
# 16. Show guidance
#

cd "${mackerel_agent_conf_dir}"
remote_repository_url="$(git remote get-url origin)"

if [ "${remote_repository_url}" = "${original_repository_url}" ]; then
  echo -e " ┌────────────────────────────────────────────────────────────────────────────────────────────┐"
  echo ""
  echo -e "   First setup git cloned from ${c_hl}${original_repository_url}${c_off}?"
  echo ""
  echo "  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "
  echo ""
  echo -e "   ${c_st}Change your remote Git repository as yours.${c_off}"
  echo "     cd ${mackerel_agent_conf_dir}"
  echo "     git remote -v  # Check the current settings"
  echo ""
  echo "     git remote set-url origin <your-remote-git-repository-url>"
  echo "     git remote -v  # Check the modification"
  echo ""
  echo -e "   Edit ${mackerel_agent_conf_dir}/${c_hl}README.md${c_off} and commit if needed."
  echo "     cd ${mackerel_agent_conf_dir}"
  echo "     vi README.md"
  echo ""
  echo -e "   After modifications, ${c_hl}git push${c_off} your modification commits."
  echo "     cd ${mackerel_agent_conf_dir}"
  echo "     git status  # git commit if uncommitted modifications exist"
  echo ""
  echo "     git remote -v  # Check if your correct remote Git repository is set"
  echo "     git push"
  echo ""
  echo -e " └────────────────────────────────────────────────────────────────────────────────────────────┘"
  echo ""
fi

cd - > /dev/null

echo -e " ┌────────────────────────────────────────────────────────────────────────────────────────────┐"
echo ""
echo -e "   About ${c_hl}${mackerel_agent_conf_dir}${c_off}:"
echo ""
echo "  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "
echo ""
echo "   It is already a Git repository."
echo "     cd ${mackerel_agent_conf_dir}"
echo "     git status"
echo "     git log --oneline --graph"
echo ""
echo -e "   The owner user is ${c_hl}${current_user}${c_off}."
echo "     ls -l $(dirname ${mackerel_agent_conf_dir}) | grep $(basename ${mackerel_agent_conf_dir})"
echo ""
echo -e " └────────────────────────────────────────────────────────────────────────────────────────────┘"
echo ""
