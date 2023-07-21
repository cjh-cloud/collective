import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { EntityManager, Repository } from 'typeorm';
import { CreateCommentDto } from './dto/create-comment.dto';
import { CreateItemDto } from './dto/create-item.dto';
import { CreateTagDto } from './dto/create-tag.dto';
import { UpdateItemDto } from './dto/update-item.dto';
import { Comment } from './entities/comments.entity';
import { Item } from './entities/item.entity';
import { Listing } from './entities/listing.entity';
import { Tag } from './entities/tag.entity';

@Injectable()
export class ItemsService {
  constructor(
    @InjectRepository(Item)
    private readonly itemsRepository: Repository<Item>, // this is so find uses item table?
    private readonly entityManager: EntityManager
  ) { }

  async create(createItemDto: CreateItemDto) {
    const listing = new Listing({
      ...createItemDto.listing,
      rating: 0,
    })
    const tags = createItemDto.tags.map(
      (CreateTagDto) => new Tag(CreateTagDto),
    );
    const item = new Item({
      ...createItemDto,
      comments: [], // No comments when we initially create item
      listing,
      tags,
    });
    await this.entityManager.save(item);
    // return 'This action adds a new item';
  }

  async findAll() {
    return this.itemsRepository.find();
    // return `This action returns all items`;
  }

  async findOne(id: number) {
    // return this.itemsRepository.findOneBy({ id });
    return this.itemsRepository.findOne({
      where: { id },
      relations: { listing: true, comments: true, tags: true }, // Tell TypeORM to populate this relation
    })
    // return `This action returns a #${id} item`;
  }

  async update(id: number, updateItemDto: UpdateItemDto) {
    // // return `This action updates a #${id} item`;
    // const item = await this.itemsRepository.findOneBy({ id });
    // item.public = updateItemDto.public;
    // const comments = updateItemDto.comments.map(
    //   (createCommentDto) => new Comment(createCommentDto),
    // );
    // item.comments = comments;
    // await this.entityManager.save(item);

    // Transaction
    await this.entityManager.transaction(async (entityManager) => {
      const item = await this.itemsRepository.findOneBy({ id });
      item.public = updateItemDto.public;
      const comments = updateItemDto.comments.map(
        (createCommentDto) => new Comment(createCommentDto),
      );
      item.comments = comments;
      await entityManager.save(item);

      throw new Error(); // Will cause transaction to not be persisted, and will be rolled back.

      // say we want to generate a unqiue tag for this item
      const tagContent = `${Math.random()}`;
      const tag = new Tag({ content: tagContent });
      await entityManager.save(tag);
    });
  }

  async remove(id: number) {
    // return `This action removes a #${id} item`;
    return this.itemsRepository.delete(id);
  }
}
