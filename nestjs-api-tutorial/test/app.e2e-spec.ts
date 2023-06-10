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
import { AppModule } from '../src/app.module';

describe('App e2e', () => {
  let app: INestApplication;

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
  });

  afterAll(() => {
    app.close();
  })

  it.todo('should pass');
  it.todo('should pass 2');
});
