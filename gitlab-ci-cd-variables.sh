#!/bin/bash
# create variables from a json file
# usage: create_variables.sh <json_file>
export GROUP_ID=
export GITLAB_TOKEN=
# check if we have a valid json file
if ! [[ -f "$1" ]]; then
  echo "Please provide a valid json file"
  exit 1
fi

# iterate over the json file and create variables for each entry
for row in $(jq -r '.[] | @base64' "$1"); do
  _jq() {
    echo ${row} | base64 --decode | jq -r ${1}
  }

  variable_type=$(_jq '.variable_type')
  key=$(_jq '.key')
  value=$(_jq '.value')
  protected=$(_jq '.protected')
  masked=$(_jq '.masked')

  # create the variable using the gitlab api
  curl --request POST --header "PRIVATE-TOKEN: $GITLAB_TOKEN" --form "key=$key" --form "value=$value" --form "protected=$protected" --form "masked=$masked" --form "variable_type=$variable_type" "https://gitlab.com/api/v4/groups/$GROUP_ID/variables" > /dev/null 2>&1
  # print some output for debugging purposes
  echo "$variable_type variable created: $key=$value"
done
