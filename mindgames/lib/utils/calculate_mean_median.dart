double calculateMedian(List<double> data) {
  data.sort();

  int middleIndex = data.length ~/ 2;

  if (data.length % 2 == 1) {
    return data[middleIndex];
  } else {
    return (data[middleIndex - 1] + data[middleIndex]) / 2;
  }
}

double calculateMean(List<double> data) {
  double sum = 0;

  for (var item in data) {
    sum += item;
  }

  double average = sum / data.length;

  return average;
}
