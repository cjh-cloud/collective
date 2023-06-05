import { Module } from "@nestjs/common";
// import { PrismaModule } from "src/prisma/prisma.module"; // Not required now that Prisma module is Global
import { AuthController } from "./auth.controller";
import { AuthService } from "./auth.service";

@Module({
    // imports: [PrismaModule],
    controllers: [AuthController],
    providers: [AuthService],
})
export class AuthModule {

}