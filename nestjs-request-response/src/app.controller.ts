import { Body, Controller, Get, Post, UseGuards, UseInterceptors, UsePipes } from '@nestjs/common';
import { AppService } from './app.service';
import { AuthGuard } from './guards/auth.guard';
import { FreezePipe } from './pipes/freeze.pipe';
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

  @Post()
  // @UsePipes(FreezePipe) // 3. Pipe at controller level, can do this instead of in Body, not sure of difference
  // @UseGuards(FreezePipe) // Guard gets applied to all args in @Body, useful if many args
  examplePost(@Body(new FreezePipe()) body: any) { // Can pass in any number of pipes into the body call
    body.test = 32;
  }
}
