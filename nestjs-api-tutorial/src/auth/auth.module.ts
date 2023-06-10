import { Module } from "@nestjs/common";
import { JwtModule } from "@nestjs/jwt";
// import { PrismaModule } from "src/prisma/prisma.module"; // Not required now that Prisma module is Global
import { AuthController } from "./auth.controller";
import { AuthService } from "./auth.service";
import { JwtStrategy } from "./strategy";

@Module({
    // imports: [PrismaModule],
    imports: [JwtModule.register({})], // refresh token usually goes in the {}
    controllers: [AuthController],
    providers: [AuthService, JwtStrategy],
})
export class AuthModule {

}