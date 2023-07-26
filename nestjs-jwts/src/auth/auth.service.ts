import { Injectable } from '@nestjs/common';
import { PrismaService } from 'src/prisma/prisma.service';
import { AuthDto } from './dto';
import * as bcrypt from 'bcrypt';
import { Tokens } from './types';
import { JwtService } from '@nestjs/jwt';

@Injectable()
export class AuthService {
  constructor(private prisma: PrismaService, private jwtService: JwtService) {

  }

  hashData(data: string) {
    return bcrypt.hash(data, 10);
  }

  // args is info we want to put in JWT
  async getTokens(userId: number, email: string) {
    const [at, rt] = await Promise.all([
      this.jwtService.signAsync(
        {
          sub: userId,
          email,
        },
        {
          secret: 'at-secret', // match with at.strategy.ts
          expiresIn: 60 * 15, // 15 mins
        }
      ),
      this.jwtService.signAsync(
        {
          sub: userId,
          email,
        },
        {
          secret: 'rt-secret', // match with at.strategy.ts
          expiresIn: 60 * 60 * 24 * 7, // 1 week
        }
      ),
    ]);

    return {
      access_token: at,
      refresh_token: rt,
    }
  }

  // Returns Promise of type Tokens that we defined
  async signupLocal(dto: AuthDto): Promise<Tokens> {
    const hash = await this.hashData(dto.password);
    const newUser = await this.prisma.user.create({
      data: {
        email: dto.email,
        hash,
      }
    });

    const tokens = await this.getTokens(newUser.id, newUser.email);

    return tokens;
  }


  signinLocal() { }
  logout() { }
  refreshTokens() { }
}
