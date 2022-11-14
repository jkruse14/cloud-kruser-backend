if [ ! $1 ]; then
  echo "Must provide a name for the new package"
  exit
fi

NAME=$1
DIR="packages/${NAME}"
mkdir "./${DIR}"
cd ${DIR}
yarn init

touch yarn.lock

cat <<EOF > tsconfig.json
{
    "extends": "../../tsconfig.json",
    "compilerOptions": {
        "outDir": "./dist",
    }
}
EOF

cat <<EOF > tsconfig.build.json
{
    "extends": "./tsconfig.json",
    "exclude": ["node_modules", "test", "dist", "**/*spec.ts"]
}
EOF

cat <<EOF > README.md
# ${NAME}
EOF

mkdir src
cd ./src

pascalName=$(echo "${NAME//-/ }")
pascalName=$(for i in ${pascalName}; do B=`echo "${i:0:1}" | tr "[:lower:]" "[:upper:]"`; echo "${B}${i:1} "; done)
pascalName=$(echo "${pascalName//[[:space:]]/}")

cat <<EOF > handler.ts
import { AbstractLambdaHandler } from "../../lambda/src/abstract-lambda-handler";

export interface ${pascalName}Input {
  name: string;
}

export type ${pascalName}Output = {};

// @Injectable()
export class ${pascalName}Handler extends AbstractLambdaHandler<
  ${pascalName}Input,
  ${pascalName}Output
 {
  constructor() {
    super();
  }
  public async handle(input: ${pascalName}Input): Promise<${pascalName}Output> {}
}
EOF

cat <<EOF > index.js
import { ${pascalName}Handler } from "./handler";

const handler = new ${pascalName}Handler();
export const handle = async (input) => handler.handle(input);
EOF
