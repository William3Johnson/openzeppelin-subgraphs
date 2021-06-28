# #!/usr/bin/env bash

function test() {
  modules=("$@")

  mkdir -p generated
  tmp=`mktemp -p generated`

  {
    printf '{'
    printf '"output": "%s",' "$tmp."
    printf '"datasources": ['
    printf '{'
    printf '"address": "0x0000000000000000000000000000000000000000",'
    printf '"module": ['
    {
      for module in "${modules[@]}";
      do
        printf '"%s",' "`basename $module .yaml`"
      done
    } | sed '$s/,$//'
    printf ']'
    printf '}'
    printf ']'
    printf '}'
  } | jq > $tmp

  npx generator --path $tmp --export-subgraph --export-schema || exit $?
  npx graph codegen $tmp.subgraph.yaml || exit $?
  npx graph build $tmp.subgraph.yaml || exit $?

  rm $tmp $tmp.schema.graphql $tmp.subgraph.yaml
}



shopt -s nullglob
modules=(src/datasources/*.yaml)

if [ $# -eq 0 ];
then
  for module in ${modules[@]};
  do
      echo "Test module `basename $module .yaml`"
      test $module
    done;

    echo "Test all modules"
    test ${modules[@]}
else
  test $@
fi
