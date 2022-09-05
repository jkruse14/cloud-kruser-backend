import { copyFileSync, mkdirSync, readdirSync, writeFileSync } from 'fs';
import { camel, pascal, slug } from 'to-case';
import { resolve } from 'path';

async function main(): Promise<void> {
  const name = process.argv[2];
  const pascalName = pascal(name);
  const slugName = slug(name);
  const camelName = camel(name);

  if (!name) {
    throw new Error('Must provide a name for your lambda');
  }

  process.chdir('./scripts/create-lambda');

  const spec = `import { Test, TestingModule } from '@nestjs/testing';
import { ${pascalName}Service } from './${slugName}.service';

describe('${pascalName}Service', () => {
  let service: ${pascalName}Service;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [${pascalName}Service],
    }).compile();

    service = module.get<${pascalName}>(${pascalName}Service);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
`;

  const handler = `import { Injectable } from '@nestjs/common';
import { AbstractLambdaHandler } from '../../../lambda/abstract-lambda-handler';

export interface ${pascalName}Input {}

export type ${pascalName}Output = {
  message: string;
};

@Injectable()
export class ${pascalName}Handler extends AbstractLambdaHandler<
  ${pascalName}Input,
  ${pascalName}Output
> {
  constructor(
    @Inject(${pascalName}Service) private readonly ${camelName}: ${pascalName},
  ) {}
  public async handle(input: ${pascalName}Input): Promise<${pascalName}Output> {}
}
`;

  const lambdaModule = `import { Module } from '@nestjs/common';
import { ${pascalName}Handler } from './${slugName}.handler';
import { ${pascalName}Service } from './${slugName}.service';

@Module({
  imports: [],
  controllers: [${pascalName}Handler],
  providers: [${pascalName}Service],
})
export class AppModule {}
`;

  const service = `import { Injectable } from '@nestjs/common';

@Injectable()
export class ${pascalName}Service {}
`;

  const main = `import { NestFactory } from '@nestjs/core';
import { AppModule } from './${slugName}.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  await app.listen(3000);
}
bootstrap();
`;

  const files = {
    spec,
    handler,
    service,
    lambdaModule,
    main,
  };

  const dir = `../../src/lambdas/${name}/src`;
  const testDir = `../../src/lambdas/${name}/test`;
  mkdirSync(resolve(__dirname, dir), { recursive: true });
  mkdirSync(resolve(__dirname, testDir), { recursive: true });
  for (const file of Object.keys(files)) {
    switch (file) {
      case 'spec':
        writeFileSync(
          resolve(__dirname, `${dir}/${slugName}.service.spec.ts`),
          files[file],
        );
        break;
      case 'handler':
        writeFileSync(
          resolve(__dirname, `${dir}/${slugName}.handler.ts`),
          files[file],
        );
        break;
      case 'service':
        writeFileSync(
          resolve(__dirname, `${dir}/${slugName}.service.ts`),
          files[file],
        );
        break;
      case 'lambdaModule':
        writeFileSync(
          resolve(__dirname, `${dir}/${slugName}.module.ts`),
          files[file],
        );
        break;
      case 'main':
        writeFileSync(resolve(__dirname, `${dir}/main.ts`), files[file]);
        break;
    }
  }
  for (const file of readdirSync(resolve(`${__dirname}/standard-files`))) {
    copyFileSync(
      resolve(__dirname, `./standard-files/${file}`),
      resolve(`${dir}`, `../${file}`),
    );
  }
}

main();
