#!/bin/bash
task=$1

function releaseNoteInspection() {
  deploy_apps=$(yq e '.deploy' .github/project.yaml)
  extracted=$( echo $deploy_apps | cut -d "[" -f2 | cut -d "]" -f1 )
  trimmed=${extracted//[[:blank:]]/}
  IFS=',' read -ra apps <<< "$trimmed"
  for app in "${apps[@]}"
  do
    if [ -e ".github/release_notes/$app.md" ]; then
      printf "... [release-inspection] release note for app[%s] is found." "$app"
    else
      printf "... [release-inspection] release note for app[%s] is not found." "$app"
      exit 2
    fi
  done
}

# shellcheck disable=SC2120
function releaseTagInspection {
  if [[ $2 != $3 ]]; then
    local IFS=.
    local i ver1=($2) ver2=($3)

    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
      ver1[i]=0
    done

    for ((i=0; i<${#ver1[@]}; i++))
    do
      if [[ -z ${ver2[i]} ]]; then
        ver2[i]=0
      fi

      if ((10#${ver1[i]} > 10#${ver2[i]})); then
        echo "Next version should not be lower than the current one! Stopping the workflow."
        exit 1
      fi
    done
  fi
}


if [[ -n $task ]] && [[ $task == "releaseNotes" ]]; then
  printf "... [release-inspection] checking release notes for the deploying apps. \r\n"
  releaseNoteInspection
fi

if [[ -n $task ]] && [[ $task == "releaseTags" ]]; then
  printf "... [release-inspection] checking release tags for the deploying apps. \r\n"
  releaseTagInspection
fi