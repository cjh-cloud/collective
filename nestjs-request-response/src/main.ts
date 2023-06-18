import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
// import { HttpExceptionFilter } from './filters/https-exception.filter';
// import { AuthGuard } from './guards/auth.guard';
// import { FreezePipe } from './pipes/freeze.pipe';
// import { AuthenticationMiddleware } from './middleware/authentication.middleware';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  // app.use(new AuthenticationMiddleware()) // could pass in middleware here, but we don't have access to DI RequestService?
  // app.useGlobalGuards(new AuthGuard); // 1. If you have dependencies injected like middleware, this won't work too well
  // app.useGlobalInterceptors(new LoggingInterceptor()); // 1. Can't inject dependencies automaticall
  // app.useGlobalPipes(new FreezePipe()); // 1. Fine if no dependencies
  // app.useGlobalFilters(new HttpExceptionFilter()); 1. Would work here, but not if there were DI
  await app.listen(3000);
}
bootstrap();
