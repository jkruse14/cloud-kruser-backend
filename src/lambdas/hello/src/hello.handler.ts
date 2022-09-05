import { Injectable } from '@nestjs/common';
import { AbstractLambdaHandler } from '../../../lambda/abstract-lambda-handler';

export interface HelloInput {
  name?: string;
}

export type HelloOutput = {
  message: string;
};

@Injectable()
export class HelloHandler extends AbstractLambdaHandler<
  HelloInput,
  HelloOutput
> {
  public async handle(input: HelloInput): Promise<HelloOutput> {
    console.log(`Hello, ${input.name}!`);
    return {
      message: `Hello, ${input.name}!`,
    };
  }
}
