import { Injectable, Inject } from '@nestjs/common';
import { AbstractLambdaHandler } from '../../abstract-lambda-handler';
import { GoodbyeService } from './goodbye.service';

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
  ) {
    super();
  }
  public async handle(input: GoodbyeInput): Promise<GoodbyeOutput> {
    const message = await this.goodbyeService.sendGoodbye(input.name);
    return { message };
  }
}
