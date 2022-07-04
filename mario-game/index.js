// import platform from './img/platform.png';


const canvas = document.querySelector('canvas');
const c = canvas.getContext('2d'); // 2d game canvas context

canvas.width = 1024; // window.innerWidth;
canvas.height = 576 // window.innerHeight;

const gravity =  1; //0.5;

class Player {
  constructor() {
    this.speed = 10;
    this.position = {
      x: 100,
      y: 100
    }
    this.velocity = {
      x: 0,
      y: 1
    }
    this.width = 30;
    this.height = 30;
  }

  draw() {
    c.fillStyle = 'red';
    c.fillRect(this.position.x, this.position.y, this.width, this.height);
  }

  update() {
    this.draw();
    this.position.y += this.velocity.y;
    this.position.x += this.velocity.x;

    if (this.position.y + this.height + this.velocity.y <= canvas.height)
      this.velocity.y += gravity;
    // else this.velocity.y = 0; // we want the player to fall in gaps now that we have platforms
    
  }
}

class Platform {
  constructor({x, y, image}) {
    this.position = {
      x, // same as x: x
      y,
    }
    this.image = image;
    this.width = image.width;
    this.height = image.height;

  }

  draw() {
    c.drawImage(this.image, this.position.x, this.position.y);
    // c.fillRect(this.position.x, this.position.y, this.width, this.height);
  }
}

// No colision detection list Platform class above
class GenericObject {
  constructor({x, y, image}) {
    this.position = {
      x, // same as x: x
      y,
    }
    this.image = image;
    this.width = image.width;
    this.height = image.height;

  }

  draw() {
    c.drawImage(this.image, this.position.x, this.position.y);
    // c.fillRect(this.position.x, this.position.y, this.width, this.height);
  }
}

// Images
const platform = './img/platform.png';

// const platform = new Image();
// platform.src = './img/platform.png'
const platformImage = createImage(platform)
platformImage.width = 580;
platformImage.height = 125;

const hills = './img/hills.png';
const background = './img/background.png';

const platformSmallTall = './img/platformSmallTall.png';
const platformSmallTallImage = createImage(platformSmallTall);
platformSmallTallImage.width = 291;
platformSmallTallImage.height = 227;

console.log(platform.width);

function createImage(imageSrc) {
  const image = new Image();
  image.src = imageSrc;
  return image;
}

// !
let player = new Player();
let platforms = [

];
let genericObjects = [

]

const keys = {
  right: {
    pressed: false
  },
  left: {
    pressed: false
  }
} // this is for both types of pcs that send multi events on keydown, or only one

let scrollOffset = 0; // how far have our platforms scrolled off screen

function init() {
  // !
  player = new Player();
  platforms = [
    new Platform({x: platformImage.width *4 + 300 - 2 + platformImage.width - platformSmallTallImage.width, y: 270, image: createImage(platformSmallTall)}),
    new Platform({x: -1, y: 470, image:platformImage}),
    new Platform({x: platformImage.width - 3, y: 470, image: platformImage}),
    new Platform({x: platformImage.width *2 + 100, y: 470, image: platformImage}),
    new Platform({x: platformImage.width *3 + 300, y: 470, image: platformImage}),
    new Platform({x: platformImage.width *4 + 300 - 2, y: 470, image: platformImage}),
    new Platform({x: platformImage.width *5 + 700 - 2, y: 470, image: platformImage})
  ];
  genericObjects = [
    new GenericObject({
      x: -1,
      y: -1,
      image: createImage(background)
    }),
    new GenericObject({
      x: -1,
      y: -1,
      image: createImage(hills)
    })
  ]

  // keys = {
  //   right: {
  //     pressed: false
  //   },
  //   left: {
  //     pressed: false
  //   }
  // } // this is for both types of pcs that send multi events on keydown, or only one

  scrollOffset = 0; // how far have our platforms scrolled off screen
}

function animate() {
  requestAnimationFrame(animate);
  c.fillStyle = 'white';
  c.fillRect(0, 0, canvas.width, canvas.height);
  // c.clearRect(0, 0, canvas.width, canvas.height); // clear the canvas

  genericObjects.forEach(genericObject => {
    genericObject.draw();
  })

  platforms.forEach(platform => {
    platform.draw();
  });

  player.update(); // draw player last

  // player can't move past a certain point, and background starts scrolling
  if (keys.right.pressed && player.position.x < 400) {
    player.velocity.x = player.speed;
  } else if ((keys.left.pressed && player.position.x > 100) 
    || (keys.left.pressed && scrollOffset === 0 && player.position.x > 0) // can't move left past level start
  ) {
    player.velocity.x = -player.speed;
  } else {
    player.velocity.x = 0;

    if(keys.right.pressed) {
      scrollOffset += player.speed;

      // Move scene
      platforms.forEach(platform => {
        platform.position.x -= player.speed;
      });
      genericObjects.forEach(genericObject => {
        genericObject.position.x -= player.speed * 0.66;
      });
    } else if (keys.left.pressed && scrollOffset > 0) {
      scrollOffset -= player.speed;

      // Move scene
      platforms.forEach(platform => {
        platform.position.x += player.speed;
      });
      genericObjects.forEach(genericObject => {
        genericObject.position.x += player.speed * 0.66;
      });
    }
  }

  // platform rectangular colision detection
  platforms.forEach(platform => {
    if (player.position.y + player.height <= platform.position.y && 
      player.position.y + player.height + player.velocity.y >= platform.position.y &&
      player.position.x + player.width >= platform.position.x &&
      player.position.x <= platform.position.x + platform.width) 
    {
      player.velocity.y = 0;
    }
  });

  // win condition
  if (scrollOffset > platformImage.width * 5 + 400 - 2) {
    console.log('you win');
  }

  // lose condition
  if (player.position.y > canvas.height) {
    console.log('you lose');
    init(); // initalise everything
  }
}

init();
animate();

// event listeners
window.addEventListener('keydown', ({ keyCode }) => {
  switch (keyCode) {
    case 65: // a
      console.log('left');
      // player.velocity.x -= 1;
      keys.left.pressed = true;
      break;
    case 83: // s
      console.log('down');
      break;
    case 68: // d
      console.log('right');
      // player.velocity.x += 1;
      keys.right.pressed = true;
      break;
    case 87: // w
      console.log('up');
      player.velocity.y -= 25; // canvas y starts at 0 and increases downwards
      break;
  }
});

window.addEventListener('keyup', ({ keyCode }) => {
  switch (keyCode) {
    case 65: // a
      console.log('left');
      // player.velocity.x = 0;
      keys.left.pressed = false;
      break;
    case 83: // s
      console.log('down');
      break;
      case 68: // d
      console.log('right');
      // player.velocity.x = 0;
      keys.right.pressed = false;
      break;
    case 87: // w
      console.log('up');
      // player.velocity.y -= 20; // canvas y starts at 0 and increases downwards
      break;
  }
});

console.log(canvas);