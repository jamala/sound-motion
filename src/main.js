
const THREE = require('three'); // older modules are imported like this. You shouldn't have to worry about this much
import Framework from './framework'
import Noise from './noise'
import {other} from './noise'

var noisyShape;
var analyser;
var radius = 3;

// called after the scene loads
function onLoad(framework) {
  var scene = framework.scene;
  var camera = framework.camera;
  var renderer = framework.renderer;
  var gui = framework.gui;
  var stats = framework.stats;

  var listener = new THREE.AudioListener();
  camera.add(listener);

  var sound = new THREE.Audio( listener );
  var audioLoader = new THREE.AudioLoader();
  audioLoader.load('../audio/sun.mp3', function (buffer) {
    sound.setBuffer(buffer);
    sound.setVolume(0.5);
    sound.play();
  });

  // create an AudioAnalyser, passing in the sound and desired fftSize
  analyser = new THREE.AudioAnalyser( sound, 32 );

  // LOOK: the line below is synyatic sugar for the code above. Optional, but I sort of recommend it.
  // var {scene, camera, renderer, gui, stats} = framework; 

  // initialize a simple box and material
  var box = new THREE.BoxGeometry(1, 1, 1);

  var adamMaterial = new THREE.ShaderMaterial({
    uniforms: {
      image: { // Check the Three.JS documentation for the different allowed types and values
        type: "t", 
        value: THREE.ImageUtils.loadTexture('./adam.jpg')
      }
    },
    vertexShader: require('./shaders/adam-vert.glsl'),
    fragmentShader: require('./shaders/adam-frag.glsl')
  });
  var adamCube = new THREE.Mesh(box, adamMaterial);

  

  var shape = new THREE.IcosahedronGeometry(3, 5);
  var noisyMaterial = new THREE.MeshBasicMaterial({ color: 0xff0000 })
  var noisyShape = new THREE.Mesh(shape, noisyMaterial);
  noisyShape.name = "thing";

  // set camera position
  camera.position.set(1, 1, 2);
  camera.lookAt(new THREE.Vector3(0,0,0));

  // scene.add(adamCube);
  scene.add(noisyShape);

  // edit params and listen to changes like this
  // more information here: https://workshop.chromeexperiments.com/examples/gui/#1--Basic-Usage
  gui.add(camera, 'fov', 0, 180).onChange(function(newVal) {
    camera.updateProjectionMatrix();
  });
}

// called on frame updates
function onUpdate(framework) {
  // console.log(`the time is ${new Date()}`);
  if(analyser !== undefined) {
    var shape = framework.scene.getObjectByName("thing");
    var currentAvg = analyser.getAverageFrequency();

    var low = 90, high = 140;
    var normalized = (high - currentAvg)/(high - low);
    console.log(normalized);
      // shape.material.color = new THREE.Color(0x00ff00) 
    shape.scale.set(1.0 + normalized, 1.0 + normalized, 1.0 + normalized);
    
    // shape.geometry.radius = 3 * (currentAvg/150);
  }
  // let musicVolume = analyser.getAverageFrequency();
    // noisyShape.geometry.radius = musicVolume;
  // }

  
 
}

// when the scene is done initializing, it will call onLoad, then on frame updates, call onUpdate
Framework.init(onLoad, onUpdate);

console.log('hello world');

// console.log(Noise.generateNoise());

// Noise.whatever()

// console.log(other())