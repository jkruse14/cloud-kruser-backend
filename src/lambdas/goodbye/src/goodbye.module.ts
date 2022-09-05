import { Module } from '@nestjs/common';
import { GoodbyeHandler } from './goodbye.handler';
import { GoodbyeService } from './goodbye.service';

@Module({
  imports: [],
  controllers: [GoodbyeHandler],
  providers: [GoodbyeService],
})
export class AppModule {}
