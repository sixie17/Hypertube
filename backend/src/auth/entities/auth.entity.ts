import { Column, Entity, JoinTable, ManyToMany, PrimaryColumn } from 'typeorm';

//example user
@Entity('user')
export class User {
  @PrimaryColumn()
  id: string;

  @Column()
  mail: string;

  @Column()
  username: string;

  @ManyToMany(() => User, (user: User) => user.friends, {
    cascade: ['insert', 'update'],
  })
  @JoinTable()
  friends: User[];
}
