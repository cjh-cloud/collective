// import { Test, TestingModule } from '@nestjs/testing';
// import { INestApplication } from '@nestjs/common';
// import * as request from 'supertest';
// import { AppModule } from './../src/app.module';

// describe('AppController (e2e)', () => {
//   let app: INestApplication;

//   beforeEach(async () => {
//     const moduleFixture: TestingModule = await Test.createTestingModule({
//       imports: [AppModule],
//     }).compile();

//     app = moduleFixture.createNestApplication();
//     await app.init();
//   });

//   it('/ (GET)', () => {
//     return request(app.getHttpServer())
//       .get('/')
//       .expect(200)
//       .expect('Hello World!');
//   });
// });

import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import * as pactum from 'pactum';
import { PrismaService } from '../src/prisma/prisma.service';
import { AppModule } from '../src/app.module';
import { AuthDto } from '../src/auth/dto/auth.dto';
import { EditUserDto } from 'src/user/dto';

describe('App e2e', () => {
  let app: INestApplication;
  let prisma: PrismaService

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    // Emulate server
    app = moduleRef.createNestApplication();
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
      }),
    );

    await app.init(); // Start server
    await app.listen(3333);

    prisma = app.get(PrismaService);
    await prisma.cleanDb();
    pactum.request.setBaseUrl('http://localhost:3333');
  });

  afterAll(() => {
    app.close();
  })

  describe('Auth', () => {
    const dto: AuthDto = {
      email: 'test@gmail.com',
      password: '1234',
    }

    describe('Signup', () => {
      it('should thow if email empty', () => {
        return pactum
          .spec()
          .post('/auth/signup',)
          .withBody({
            password: dto.password,
          })
          .expectStatus(400);
      });
      it('should thow if password empty', () => {
        return pactum
          .spec()
          .post('/auth/signup',)
          .withBody({
            email: dto.email,
          })
          .expectStatus(400);
      });
      it('should thow if no body provided', () => {
        return pactum
          .spec()
          .post('/auth/signup',)
          .expectStatus(400);
      });
      it('should signup', () => {
        return pactum
          .spec()
          .post('/auth/signup',)
          .withBody(dto)
          .expectStatus(201);
        // .inspect() // to see body chain
      });
    });

    describe('Signin', () => {
      let accessToken: string
      it('should thow if email empty', () => {
        return pactum
          .spec()
          .post('/auth/signin',)
          .withBody({
            password: dto.password,
          })
          .expectStatus(400);
      });
      it('should thow if password empty', () => {
        return pactum
          .spec()
          .post('/auth/signin',)
          .withBody({
            email: dto.email,
          })
          .expectStatus(400);
      });
      it('should thow if no body provided', () => {
        return pactum
          .spec()
          .post('/auth/signin',)
          .expectStatus(400);
      });
      it('should signup', () => {
        return pactum
          .spec()
          .post('/auth/signin',)
          .withBody(dto)
          .expectStatus(200)
          .stores('userAt', 'access_token');
      });
    });
  });

  describe('User', () => {
    describe('Get me', () => {
      it('should get current user', () => {
        return pactum
          .spec()
          .get('/users/me',)
          .withHeaders({
            Authorization: "Bearer $S{userAt}"
          })
          .expectStatus(200)
      });
    });

    describe('Edit user', () => {
      it('should edit user', () => {
        const dto: EditUserDto = {
          firstName: "first",
          email: "edit@gmail.com",
        }
        return pactum
          .spec()
          .patch('/users',)
          .withHeaders({
            Authorization: "Bearer $S{userAt}"
          })
          .withBody(dto)
          .expectStatus(200)
          .expectBodyContains(dto.firstName)
          .expectBodyContains(dto.email);
      })
    });
  });

  describe('Bookmark', () => {
    describe('Create bookmark', () => { });

    describe('Get bookmarks', () => { });

    describe('Get bookmark by id', () => { });

    describe('Edit bookmark by id', () => { });

    describe('Delete bookmark by id', () => { });
  });
});
