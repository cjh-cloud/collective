import { Module } from '@nestjs/common';
import { CacheInterceptor, CacheModule } from '@nestjs/cache-manager';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { APP_INTERCEPTOR } from '@nestjs/core';

@Module({
  imports: [CacheModule.register({
    isGlobal: true,
    // ttl: 5, // seconds // setting TTL seems to not let it cache???
    max: 10, // maximum number of items in cache
  })],
  controllers: [AppController],
  providers: [AppService,
    {
      provide: APP_INTERCEPTOR,
      useClass: CacheInterceptor, // 1. Global caching
    }
  ],
})
export class AppModule { }
