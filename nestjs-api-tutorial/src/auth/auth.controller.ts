import { Controller, Post, Body, ParseIntPipe } from "@nestjs/common";
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

    @Post('signin')
    singin() {
        return this.authService.signin();
    }
}