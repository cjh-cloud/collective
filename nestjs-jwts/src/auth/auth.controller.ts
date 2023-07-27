import { Body, Controller, HttpCode, HttpStatus, Post, UseGuards } from '@nestjs/common';
import { GetCurrentUser, GetCurrentUserId, Public } from 'src/common/decorators';
import { RtGuard } from 'src/common/guards';

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

  @Public() // decorator to set isPublic to true
  @Post('local/signin')
  @HttpCode(HttpStatus.OK)
  signinLocal(@Body() dto: AuthDto): Promise<Tokens> {
    return this.authService.signinLocal(dto);
  }

  // @UseGuards(AtGuard) // strategy is 'jwt' in at.strategy.ts
  @Post('logout')
  @HttpCode(HttpStatus.OK)
  logout(@GetCurrentUserId() userId: number) {
    // const user = req.user; // not needed, replaced with decorator
    return this.authService.logout(userId); // sub was id, but that didn't exist, sub is in the JWT token
  }

  @UseGuards(RtGuard) // strategy is 'jwt-refresh' in at.strategy.ts, will block if you send the access token instead of the refresh token, as an example
  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  refreshTokens(
    @GetCurrentUserId() userId: number,
    @GetCurrentUser('refreshToken') refreshToken: string) {
    // const user = req.user;
    return this.authService.refreshTokens(userId, refreshToken);
    // return this.authService.refreshTokens();
  }
}
