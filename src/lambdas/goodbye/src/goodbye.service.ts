import { Injectable } from '@nestjs/common';

@Injectable()
export class GoodbyeService {
  sendGoodbye(name: string): string {
    return `Good bye, ${name}!`;
  }
}
