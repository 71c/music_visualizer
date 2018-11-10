import ddf.minim.Minim;
import ddf.minim.AudioPlayer;
import ddf.minim.analysis.FFT;
import ddf.minim.analysis.WindowFunction;

Minim minim;
AudioPlayer player;
FFT fft;


PImage pg;
int bufferSizeUsed;
int bufferStep;
float amp = 25;

ArrayList<PImage> images = new ArrayList<PImage>();

int BASS_MAX_WINDOW = 3;
float bassTotal = 0;
ArrayList<Float> bassSamples = new ArrayList<Float>();

int lastBeatTime = 0;

boolean infoTextOn = true;

String infoText = "";

void setup() {
  size(1024, 800, P2D);
  
  minim = new Minim(this);
  //player = minim.loadFile("Last Life.mp3", 2048);
  //player = minim.loadFile("04 Secondary Complications (Original Mix).mp3", 2048);
  //player = minim.loadFile("olive.mp3", 2048);
  player = minim.loadFile("all_i_have.mp3", 2048);
  //player = minim.loadFile("Mii Channel Music.mp3", 2048);
  //player = minim.loadFile("Beethoven's 5th Symphony.mp3", 2048);
  //player = minim.loadFile("glish.mp3", 2048);
  
  //player = minim.loadFile("Rob Newman's Neuropolis (Series 1, Ep 1).mp3", 2048);
  
  
  
  fft = new FFT(player.bufferSize(), player.sampleRate());
  
  bufferSizeUsed = player.bufferSize() / 2;
  bufferStep = 1;
  
  images.add(generateNoiseHorizontal(width, height, 9, new float[] {0, 0, 0}));
  images.add(generateNoiseHorizontal(width, height, 9, new float[] {0, 0, 0}));
  images.add(generateNoiseHorizontal(width, height, 9, new float[] {0, 0, 0}));
  thread("addImages");
  pg = images.remove(0);
  
  //player.cue(140000); // for Olive, skips to the drums
  //player.play();
  
  fft.window(FFT.HAMMING);
}

void draw() {
  background(0);
  fft.forward(player.mix);
  
  // 35 to 80 & threshold=185 works well with Olive
  // 25 to 90 & threshold=158 works well with Olive
  float beatAmt = fft.calcAvg(35, 80);
  
  float spectrumWeight = 0.65;
  
  for(int i = 0; i < bufferSizeUsed; i += bufferStep) {
    int x1 = int(map(i, 0, bufferSizeUsed, 0, width));
    int x2 = int(map(i + bufferStep, 0, bufferSizeUsed, 0, width));
    
    // equal weight
    //drawSlice(pg, x1, (log(fft.getBand(i) + 1) + player.mix.get(i)) * amp + amp * 4, x2);
    // arbitrary weights
    drawSlice(pg, x1, (log(fft.getBand(i) + 1) * spectrumWeight + player.mix.get(i) * (1 - spectrumWeight)) * 2 * amp + amp * 4, x2);
    
    
    //float a = log(fft.getBand(i) + 1);
    //float b = player.mix.get(i);
    //float aNew = a * a / (a + abs(b));
    //float bNew = b * abs(b) / (a + abs(b));
    //drawSlice(pg, x1, (aNew + bNew) * amp + amp * 4, x2);
  }
  
  //println(frameRate);
  
  // use around 200 to do more often, 300 or 367 or so to do better bpm detect.
  // or 900 for every second or so
  // beatAmt threshold works at around 230 for Secondary Complications, Last Life, and Glish, All I Have.
  // tbh Glish seems to work with just about anything
  // beatAmt threshold works at around 115 for Cold Earth
  

  bassTotal += beatAmt;
  bassSamples.add(beatAmt);
  if (bassSamples.size() > BASS_MAX_WINDOW) {
    bassTotal -= bassSamples.remove(0);
  }
  float avgBass = bassTotal / bassSamples.size();
  //if (frameCount % 3 == 0)
  //  println(avgBass);
  
  // threshold=95 (-->79 actually), timeChange >= 900, 35 to 80, hamming     works with Olive
  //                                                                         also works with Glish! But with the 900 the quicker beats aren't captured
  float threshold = 200;
  
  int timeChange = millis() - lastBeatTime;
  if (timeChange >= 367 && avgBass > threshold) {
    lastBeatTime = millis();
    pg = images.remove(0);    
  }
  
  if (infoTextOn)
    text(infoText, 26, 42);
    
  ellipse(40, avgBass + 100, 10, 10);
  line(0, threshold + 100, width, threshold + 100);
}


void addImages() {
  float amt = 0.03;
  while (true) {
    while (images.size() < 17) {
      images.add(generateNoiseHorizontal(width, height, random(7) + 5.5, new float[] {random(amt) - amt / 2, random(amt) - amt / 2, random(amt) - amt / 2}));
    }
    delay(3000);
  }
}


void keyPressed() {
  if (key == CODED) {
    if (keyCode == RIGHT) {
      player.skip(5000);
    } else if (keyCode == LEFT) {
      player.skip(-5000);
    }
  } else {
    if (key == 'i') {
      infoTextOn ^= true;
    } else if ("123".contains(key + "")) {
      player.pause();
      if (key == '1')
        player = minim.loadFile("glish.mp3", 2048);
      else if (key == '2')
        player = minim.loadFile("olive.mp3", 2048);
      player.play();
    } else if (player.isPlaying()) {
      player.pause();
    } else if (player.position() == player.length()) {
      player.rewind();
      player.play();
    } else {
      player.play();
    }
  }
}
