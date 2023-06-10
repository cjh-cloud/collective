import { AuthGuard } from "@nestjs/passport";

export class JwtGuard extends AuthGuard('jwt') { // jwt links to jwt.strategy.ts
    constructor() {
        super();
    }
}