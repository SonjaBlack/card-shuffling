int numShuffles = 8;
float probOf2 = 0.5; // percent chance of laying down two cards at once from each side of the deck. 0.0 would be a perfect riffle.
PFont f;
int leftWidth = 800, rightWidth = 250;
int numIterations = 25000, curIterations = 0;

int[][] histograms;

void setup() {
  size(1050,668);
  background(0);
  f = loadFont("ArialNarrow-18.vlw");
  textFont(f);
  histograms = new int[numShuffles+1][52];
}

void draw() {
  background(0);
  stroke(255,255,255);
  int[] cards;
  cards = new int[52];

  for(int i = 0; i < 52; i++) cards[i] = i+1;
  plot(cards, 0);
  analyze(cards, 0);
  for(int s = 1; s <= numShuffles; s++) {
    cards = shuffle(cards);
    plot(cards, s);
    analyze(cards, s);
  }
  curIterations++;
  if(curIterations == numIterations) {
    save("shuffle-"+probOf2+"-"+numIterations+".png");
    noLoop();
  }
}

int[] shuffle(int[] cards) {
  int[] temp = new int[52];
  int tempIndex = 0,   // where to put the next card into temp[]
      bottomIndex = 0, // where we're drawing from in the first half of the deck
      topIndex = 26;   // where we're drawing from in the last half of the deck. This could also be randomized a bit
  int topStart = topIndex; // A persistent version of where the cut started.
  int runLength;
  while(tempIndex < 52) {
    // It should be possible for either half of the deck to go first, so if it's the first time through this while loop, flip a coin to see if the last half gets to go first:
    if(tempIndex == 0 && random(1.0) > 0.5) {
      runLength = (random(1.0) < probOf2) ? 2 : 1; // lay down a few cards from the last half of the deck
      for(int i = 0; i < runLength; i++)
        if(topIndex < 52) {
          temp[tempIndex] = cards[topIndex];
          tempIndex++;
          topIndex++;
        }
    }
    
    runLength = (random(1.0) < probOf2) ? 2 : 1; // lay down a few cards from the first half of the deck
    for(int i = 0; i < runLength; i++)
      if(bottomIndex < topStart) {
        temp[tempIndex] = cards[bottomIndex];
        tempIndex++;
        bottomIndex++;
      }
    runLength = (random(1.0) < probOf2) ? 2 : 1; // lay down a few cards from the last half of the deck
    for(int i = 0; i < runLength; i++)
      if(topIndex < 52) {
        temp[tempIndex] = cards[topIndex];
        tempIndex++;
        topIndex++;
      }
  }
  return temp;
}

void plot(int[] cards, int s) {
  int margin = 20, gap = 20;
  int plotHeight = 52,
      plotWidth = leftWidth - (2*margin),
      dx = plotWidth/52;
  // Calculate plot origin
  int originX = margin,
      originY = margin + (s+1)*plotHeight + s*gap;
    
  // draw axes
  line(originX, originY, originX, originY - plotHeight);
  line(originX, originY, originX + plotWidth, originY);
  // label the graph
  text(""+s, 7, originY - plotHeight + 18);
  // plot the cards
  for(int i = 0; i < 52; i++)
    point(originX + (i+1)*dx, originY - (cards[i]+1));
  // Collect a crude shuffling-effectiveness measure, where higher is worse, and ideal is 0.
  int numConsecutive = 0;
  for(int i = 0; i < 51; i++)
    if(cards[i] == cards[i+1]-1)
      numConsecutive++;
  text(""+numConsecutive, leftWidth-margin-10, originY-10);  
}

void analyze(int[] cards, int s) {
  // update the histogram for s
  for(int i = 0; i < 52; i++) {
    int diff = cards[(i+1)%52]-cards[i]; 
    if(diff < 0) diff += 52;
    histograms[s][diff]++;
  }
  int maxVal = 0;
  for(int i = 0; i < 52; i++)
    maxVal = max(histograms[s][i], maxVal);
    
  // Now plot the values
  int margin = 20, gap = 20;
  int plotHeight = 52,
      plotWidth = rightWidth - (2*margin),
      dx = plotWidth/52;
  // Calculate plot origin
  int originX = leftWidth + margin,
      originY = margin + (s+1)*plotHeight + s*gap;
  line(originX, originY, originX, originY - plotHeight);
  line(originX, originY, originX + plotWidth, originY);
  // Now draw
  float vScale = float(plotHeight)/maxVal;
  boolean bogus = false;
  for(int i = 0; i < 52; i++) {
    line(originX + (i+1)*dx, originY, originX + (i+1)*dx, originY-int(vScale*histograms[s][i]));
    if(int(vScale * histograms[s][i]) > plotHeight) bogus=true;
  }
  if(bogus) {
    print("maxVal: " + maxVal + " vScale: " + vScale + " ");
    for(int i = 0; i < 52; i++) print(histograms[s][i]+" ");
    println("");      
  }
}