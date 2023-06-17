import { Controller, Get, UseGuards } from '@nestjs/common';
import { AppService } from './app.service';
import { AuthGuard } from './guards/auth.guard';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) { }

  @Get()
  @UseGuards(AuthGuard) // 2. Guard at the controller level (not global)
  getHello(): string {
    return this.appService.getHello();
  }
}
