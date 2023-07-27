import { ValidationPipe } from '@nestjs/common';
import { NestFactory, Reflector } from '@nestjs/core';
import { AppModule } from './app.module';
// import { AtGuard } from './common/guards';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.useGlobalPipes(new ValidationPipe());
  // Done in app.module.ts instead, no preference for either way...
  // const reflector = new Reflector();
  // app.useGlobalGuards(new AtGuard(reflector)); // before was just on signout
  await app.listen(3000);
}
bootstrap();
