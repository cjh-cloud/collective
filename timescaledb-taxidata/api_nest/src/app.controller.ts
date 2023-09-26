import { Controller, Get, Param } from '@nestjs/common';
import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) { }

  @Get("/:date")
  getHello(@Param("date") date: string): Promise<string> {
    return this.appService.getHello(date);
  }
}
