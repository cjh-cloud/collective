import { ForbiddenException, Injectable } from "@nestjs/common";
import { PrismaService } from "src/prisma/prisma.service";
import { AuthDto } from "./dto";
import * as argon from "argon2";
import { Prisma } from '@prisma/client';

@Injectable()
export class AuthService {
    constructor(private prisma: PrismaService) {

    }
    async signup(dto: AuthDto) {
        // Generate the password hash
        const hash = await argon.hash(dto.password);

        try {
            // Save the new user in the db
            const user = await this.prisma.user.create({
                data: {
                    email: dto.email,
                    hash,
                },
                // So we don't return the password hash
                // select: {
                //     id: true,
                //     email: true,
                //     createdAt: true,
                // }
            });

            delete user.hash;

            // Return the saved user
            return user;

        } catch (error) {
            if (error instanceof Prisma.PrismaClientKnownRequestError) {
                if (error.code === "P2002") {
                    throw new ForbiddenException(
                        'Credentials taken',
                    );
                }
            }
            throw error;
        }
    }

    async signin(dto: AuthDto) {
        // find user by email
        const user = await this.prisma.user.findUnique({
            where: {
                email: dto.email
            }
        })
        // if user does not exist, throw exception - Guard condition
        if (!user) throw new ForbiddenException('Credentials incorrect');

        // compare passwords
        const pwMatches = await argon.verify(user.hash, dto.password);
        // if password incorrect, throw exception - Guard condition
        if (!pwMatches) throw new ForbiddenException('Credentials incorrect');

        // send back the user
        delete user.hash;
        return user;
    }
}