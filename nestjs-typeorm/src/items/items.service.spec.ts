import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { EntityManager, Repository } from 'typeorm';
import { Item } from './entities/item.entity';
import { ItemsService } from './items.service';

describe('ItemsService', () => {
  let service: ItemsService;
  let itemsRepository: Repository<Item>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ItemsService,
        { // Allow test to find repository
          provide: getRepositoryToken(Item), // Item because that's what we pass in Repository in items.service constructor
          useValue: { // mock value
            find: jest.fn(),
          },
        },
        { // Allow test to find Entity
          provide: EntityManager,
          useValue: {},
        }
      ],
    }).compile();

    service = module.get<ItemsService>(ItemsService);
    itemsRepository = module.get<Repository<Item>>(getRepositoryToken(Item));
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  test('findAll', async () => {
    await service.findAll();
    expect(itemsRepository.find).toHaveBeenCalled();
  })
});
