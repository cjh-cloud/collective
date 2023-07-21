// Repository? How we interact with the DB?

import { AbstractEntity } from "src/database/abstract.entity";
import { Column, Entity, JoinColumn, JoinTable, ManyToMany, OneToMany, OneToOne, PrimaryGeneratedColumn } from "typeorm";
import { Comment } from "./comments.entity";
import { Listing } from "./listing.entity";
import { Tag } from "./tag.entity";

@Entity()
export class Item extends AbstractEntity<Item>{
  // @PrimaryGeneratedColumn() // Auto increment id
  // id: number;

  @Column()
  name: string;

  @Column({ default: true })
  public: boolean;

  @OneToOne(() => Listing, { cascade: true })
  @JoinColumn() // Used to specify owner, required for one to one
  listing: Listing

  // One Item with Many Comments
  @OneToMany(() => Comment, (comment) => comment.item, { cascade: true })
  comments: Comment[]

  @ManyToMany(() => Tag, { cascade: true })
  @JoinTable() // Required for many to many
  tags: Tag[]

  // Pass some of the properties and constructor will auto assign
  // constructor(item: Partial<Item>) {
  //   Object.assign(this, item);
  // }
}
