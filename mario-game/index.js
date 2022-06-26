const canvas = document.querySelector('canvas');
const c = canvas.getContext('2d'); // 2d game canvas context

canvas.width = window.innerWidth;
canvas.height = window.innerHeight;

const gravity = 0.5;

class Player {
  constructor() {
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
    else this.velocity.y = 0;
    
  }
}

class Platform {
  constructor() {
    this.position = {
      x: 200,
      y: 100
    }
    this.width = 200;
    this.height = 20;
  }

  draw() {
    c.fillStyle = 'blue';
    c.fillRect(this.position.x, this.position.y, this.width, this.height);
  }
}

// !
const player = new Player();
const platform = new Platform();
const keys = {
  right: {
    pressed: false
  },
  left: {
    pressed: false
  }
} // this is for both types of pcs that send multi events on keydown, or only one

function animate() {
  requestAnimationFrame(animate);
  c.clearRect(0, 0, canvas.width, canvas.height); // clear the canvas
  player.update();
  platform.draw();

  if (keys.right.pressed) {
    player.velocity.x = 5;
  } else if (keys.left.pressed) {
    player.velocity.x = -5
  } else player.velocity.x = 0

  // platform rectangular colision detection
  if (player.position.y + player.height <= platform.position.y && 
    player.position.y + player.height + player.velocity.y >= platform.position.y &&
    player.position.x + player.width >= platform.position.x &&
    player.position.x <= platform.position.x + platform.width) 
  {
    player.velocity.y = 0;
  }
}

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
      player.velocity.y -= 20; // canvas y starts at 0 and increases downwards
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
      player.velocity.y -= 20; // canvas y starts at 0 and increases downwards
      break;
  }
});

console.log(canvas);