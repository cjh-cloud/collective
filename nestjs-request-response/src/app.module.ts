import { MiddlewareConsumer, Module, NestModule, RequestMethod } from '@nestjs/common';
// import { APP_GUARD } from '@nestjs/core';
import { AppController } from './app.controller';
import { AppService } from './app.service';
// import { AuthGuard } from './guards/auth.guard';
import { AuthenticationMiddleware } from './middleware/authentication.middleware';
import { RequestService } from './request.service';

@Module({
  imports: [],
  controllers: [AppController],
  providers: [AppService, RequestService,
    // {provide: APP_GUARD,
    // useClass: AuthGuard}, // 3. Global guard that allows dependency injection
  ],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(AuthenticationMiddleware).forRoutes("*");
    // .forRoutes({ path: "/path", method: RequestMethod.GET }); // middleware would only be applied to these routes
  }
}
