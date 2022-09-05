import { Module } from '@nestjs/common';
import { HelloHandler } from './hello-handler.controller';
import { HelloService } from './hello.service';

@Module({
  imports: [],
  controllers: [HelloHandler],
  providers: [HelloService],
})
export class AppModule {}
