import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true, // Will strip out extra keys in the request body that we are not defined in the dto for safety
  })); // For dto class?
  await app.listen(3333);
}
bootstrap();
