export abstract class AbstractLambdaHandler<Input, Output> {
  abstract handle(input: Input): Promise<Output>;
}
