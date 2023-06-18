import { MiddlewareConsumer, Module, NestModule, RequestMethod, Scope } from '@nestjs/common';
import { APP_INTERCEPTOR, APP_PIPE } from '@nestjs/core';
// import { APP_GUARD } from '@nestjs/core';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { LoggingInterceptor } from './interceptors/logging.interceptor';
// import { AuthGuard } from './guards/auth.guard';
import { AuthenticationMiddleware } from './middleware/authentication.middleware';
// import { FreezePipe } from './pipes/freeze.pipe';
import { RequestService } from './request.service';

@Module({
  imports: [],
  controllers: [AppController],
  providers: [AppService, RequestService,
    // {provide: APP_GUARD,
    // useClass: AuthGuard}, // 3. Global guard that allows dependency injection
    {
      provide: APP_INTERCEPTOR,
      scope: Scope.REQUEST,
      useClass: LoggingInterceptor, // 3. Global interceptor, needs to be scoped to request (what else can it be scoped to?)
    },
    // {
    //   provide: APP_PIPE,
    //   useClass: FreezePipe, // 2. Global pipe & can inject dependencies
    // }
  ],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(AuthenticationMiddleware).forRoutes("*");
    // .forRoutes({ path: "/path", method: RequestMethod.GET }); // middleware would only be applied to these routes
  }
}
