import { Test, TestingModule } from '@nestjs/testing';
import { GoodbyeService } from './goodbye.service';

describe('GoodbyeService', () => {
  let service: GoodbyeService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [GoodbyeService],
    }).compile();

    service = module.get<GoodbyeService>(GoodbyeService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
