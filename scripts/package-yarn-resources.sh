rm nodejs.zip
yarn cache clear
yarn workspaces focus --production
zip -r nodejs.zip .pnp.cjs .pnp.loader.mjs ./.yarn -x "./.yarn/plugins/*" "./.yarn/releases/*" "./.yarn/sdks/*" "./.yarn/unplugged/*" "./.yarn/.DS_Store"