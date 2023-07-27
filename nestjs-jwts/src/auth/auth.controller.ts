import { Body, Controller, HttpCode, HttpStatus, Post, Req, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { Request } from 'express';

import { AuthService } from './auth.service';
import { AuthDto } from './dto';
import { Tokens } from './types';

@Controller('auth')
export class AuthController {

  constructor(private authService: AuthService) {

  }

  // Should return a promis of type Tokens which we defined
  @Post('local/signup')
  @HttpCode(HttpStatus.CREATED)
  signupLocal(@Body() dto: AuthDto): Promise<Tokens> {
    return this.authService.signupLocal(dto);
  }

  @Post('local/signin')
  @HttpCode(HttpStatus.OK)
  signinLocal(@Body() dto: AuthDto): Promise<Tokens> {
    return this.authService.signinLocal(dto);
  }

  @UseGuards(AuthGuard('jwt')) // strategy is 'jwt' in at.strategy.ts
  @Post('logout')
  @HttpCode(HttpStatus.OK)
  logout(@Req() req: Request) {
    const user = req.user;
    return this.authService.logout(user['sub']); // sub was id, but that didn't exist
  }

  @UseGuards(AuthGuard('jwt-refresh')) // strategy is 'jwt-refresh' in at.strategy.ts
  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  refreshTokens() {
    // return this.authService.refreshTokens();
  }
}
