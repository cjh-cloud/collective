import { Controller, Post, Body, ParseIntPipe, HttpCode, HttpStatus } from "@nestjs/common";
import { AuthService } from "./auth.service";
import { AuthDto } from "./dto";

@Controller('auth')
export class AuthController {
    constructor(private authService: AuthService) {

    }

    // POST /auth/signup
    @Post('signup')
    signup(
        @Body() dto: AuthDto
        // @Body('email') email: string,
        // @Body('password', ParseIntPipe) password: string
    ) {
        return this.authService.signup(dto);
    }

    @HttpCode(HttpStatus.OK)
    @Post('signin')
    singin(@Body() dto: AuthDto) {
        return this.authService.signin(dto);
    }
}