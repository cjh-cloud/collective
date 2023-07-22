import { AbstractEntity } from "../../database/abstract.entity";
import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity()
export class Listing extends AbstractEntity<Listing> {
  // @PrimaryGeneratedColumn()
  // id: number;

  @Column()
  description: string;

  @Column()
  rating: number;

  // constructor(listing: Partial<Listing>) {
  //   Object.assign(this, listing);
  // }
}