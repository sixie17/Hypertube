import { DataSource } from 'typeorm';

export const AppDataSource = new DataSource({
  type: 'postgres',
  url: process.env.DATABASE_URL,
  // Looks for compiled JS entities inside the dist folder at runtime
  entities: [__dirname + '/**/*.entity.{js,ts}'],
  // Looks for compiled JS migrations inside the dist folder
  migrations: [__dirname + '/migrations/*.{js,ts}'],
  synchronize: false, // Always false in production! Use migrations instead.
  logging: process.env.NODE_ENV !== 'production',
});
