import { CACHE_MANAGER } from '@nestjs/cache-manager';
import { Inject, Injectable } from '@nestjs/common';
import { Cache } from 'cache-manager';

@Injectable()
export class AppService {
  constructor(@Inject(CACHE_MANAGER) private readonly cacheManager: Cache) { }

  async getHello(): Promise<string> {
    await this.cacheManager.set('cached_item', { key: 32 }, 10); // 10 is the TTL
    // await this.cacheManager.del('cached_item');
    // await this.cacheManager.reset();
    const cachedItem = await this.cacheManager.get('cached_item');
    console.log(cachedItem);
    return 'Hello World!';
  }
}
