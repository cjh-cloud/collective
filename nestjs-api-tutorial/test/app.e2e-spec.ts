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
      });
    });
  });

  describe('User', () => {
    describe('Get me', () => { });

    describe('Edit user', () => { });
  });

  describe('Bookmark', () => {
    describe('Create bookmark', () => { });

    describe('Get bookmarks', () => { });

    describe('Get bookmark by id', () => { });

    describe('Edit bookmark', () => { });

    describe('Delete bookmark', () => { });
  });
});
