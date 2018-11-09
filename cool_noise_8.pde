PImage generateNoise(int w, int h, float deviation, boolean isGaussian, float[] bias) {
  float[][][] arr = new float[h][w][3];
  PImage img = createImage(w, h, RGB);
  img.loadPixels();
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      for (int i = 0; i < 3; i++) {
        arr[y][x][i] = constrain(
            (x == 0
              ? (y == 0 ? 127 : arr[y - 1][x][i])
              : (y == 0 ? arr[y][x - 1][i] : (arr[y][x-1][i] + arr[y - 1][x][i]) / 2)
            ) + ((isGaussian ? randomGaussian() : random(3.464) - 1.732) + bias[i] ) * deviation,
            0, 256
        );
      }
      img.pixels[y * w + x] = color(arr[y][x][0], arr[y][x][1], arr[y][x][2]);
    }
  }
  img.updatePixels();
  return img;
}

PImage generateNoise(int w, int h, float deviation) {
  return generateNoise(w, h, deviation, false, new float[] {0, 0, 0});
}

void drawSlice(PImage source, int startX, float startY, int stopX) {
  float deltaX = stopX - startX;
  copy(source, int(startX), 0, int(deltaX), source.height, int(startX), int(startY), int(deltaX), source.height);
}

PImage generateNoiseHorizontal(int w, int h, float deviation, boolean isGaussian, float[] bias) {
  int dimension = ceil((w + h) / sqrt(2));
  PImage img = generateNoise(dimension, dimension, deviation, isGaussian, bias);
  PGraphics pg = createGraphics(w, h);
  pg.beginDraw();
  pg.translate(-h / 2, h / 2);
  pg.rotate(-QUARTER_PI);
  pg.image(img, 0, 0);
  pg.endDraw();
  return pg.get();
}

PImage generateNoiseHorizontal(int w, int h, float deviation, float[] bias) {
  return generateNoiseHorizontal(w, h, deviation, false, bias);
}
