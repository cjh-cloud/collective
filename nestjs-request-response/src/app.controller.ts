import { Controller, Get, UseGuards, UseInterceptors } from '@nestjs/common';
import { AppService } from './app.service';
import { AuthGuard } from './guards/auth.guard';
// import { LoggingInterceptor } from './interceptors/logging.interceptor';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) { }

  @Get()
  @UseGuards(AuthGuard) // 2. Guard at the controller level (not global)
  // @UseInterceptors(LoggingInterceptor) // 2. Interceptor at controller level (not global, route by route basis)
  getHello(): string {
    return this.appService.getHello();
  }
}
