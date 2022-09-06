import { Module } from '@nestjs/common';
import { HelloHandler } from './hello.handler';
import { HelloService } from './hello.service';

@Module({
  imports: [],
  controllers: [HelloHandler],
  providers: [HelloService],
})
export class AppModule {}
