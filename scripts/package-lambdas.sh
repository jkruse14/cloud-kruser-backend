APP_DIR="$PWD"
for d in ./src/lambdas/*/ ; do
  cd $d
  echo "Packaging $PWD"
  yarn install --frozen-lockfile
  yarn build
  zip -r -q lambda.zip .
  cd $APP_DIR
done