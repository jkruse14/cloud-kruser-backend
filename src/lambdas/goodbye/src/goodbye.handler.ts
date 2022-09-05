import { Injectable } from '@nestjs/common';
import { AbstractLambdaHandler } from '../../../lambda/abstract-lambda-handler';

export interface GoodbyeInput {
  name: string;
}

export type GoodbyeOutput = {
  message: string;
};

@Injectable()
export class GoodbyeHandler extends AbstractLambdaHandler<
  GoodbyeInput,
  GoodbyeOutput
> {
  constructor(
    @Inject(GoodbyeService) private readonly goodbyeService: GoodbyeService,
  ) {}
  public async handle(input: GoodbyeInput): Promise<GoodbyeOutput> {
    return this.goodbyeService.sendGoodbye(input.name);
  }
}
