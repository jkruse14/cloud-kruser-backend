TOP_DIR=$(pwd)
for d in ./packages/*/
do
  IFS="/"
  read -a lambdaArr <<< "$d"
  lambda=${lambdaArr[2]}
  echo "looking for lambda ${lambda}"
  pwd
  if [ -f "./packages/${lambda}/dist/${lambda}/src/index.js" ]; then
    echo "found lambda ${lambda}"
    cd ./packages/${lambda}/dist
    zip -r ./${lambda}.zip .
    mv ./${lambda}.zip ../lambda.zip
    cd "${TOP_DIR}"
  fi
done

# rm -rf .yarn/cache
# yarn install --production
# zip -r ./lambda.zip .
