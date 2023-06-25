import {
  CacheInterceptor,
  CacheKey,
  CacheTTL
} from '@nestjs/cache-manager';
import { Controller, Get, UseInterceptors } from '@nestjs/common';
import { AppService } from './app.service';

// @UseInterceptors(CacheInterceptor) // Multiple requests means the console.log in service is only printed once // 1. Caching on controller
@Controller()
export class AppController {
  constructor(private readonly appService: AppService) { }

  @Get()
  @CacheKey('some_route')
  // @CacheTTL(60)
  async getHello(): Promise<string> {
    return this.appService.getHello();
  }
}
