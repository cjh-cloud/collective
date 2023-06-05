import { Global, Module } from '@nestjs/common';
import { PrismaService } from './prisma.service';

@Global() // Makes module global, needs to be in app.module.ts to work
@Module({
  providers: [PrismaService],
  exports: [PrismaService], // So that Auth service can import it
})
export class PrismaModule { }
