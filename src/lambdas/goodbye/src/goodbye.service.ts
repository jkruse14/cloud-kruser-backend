import { Injectable } from '@nestjs/common';

@Injectable()
export class GoodbyeService {
  async sendGoodbye(name: string): Promise<string> {
    return `Good bye, ${name}!`;
  }
}
