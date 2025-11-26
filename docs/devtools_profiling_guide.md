# Flutter DevTools Profiling Guide

## Quick Start

### 1. Launch Your App in Profile Mode

```bash
# Run in profile mode (optimized but debuggable)
flutter run --profile

# Or for specific device
flutter run --profile -d <device-id>
```

> **Note:** Never profile in debug mode - it's 10x slower than production!

### 2. Open DevTools

**Option A: Automatic (Recommended)**

```bash
# DevTools will auto-open in browser when you run:
flutter run --profile
```

**Option B: Manual**

```bash
# In a separate terminal:
flutter pub global activate devtools
flutter pub global run devtools
```

Then visit: `http://localhost:9100`

---

## Performance Profiling Checklist

### 🎯 CPU Profiling

**What to Look For:**

- Functions taking >16ms (causes frame drops)
- Unnecessary rebuilds
- Heavy computations on UI thread

**Steps:**

1. Open DevTools → **Performance** tab
2. Click **Record** button
3. Interact with your app (scroll, navigate, animate)
4. Click **Stop**
5. Analyze flame chart

**Red Flags:**

```
❌ build() called 100+ times per second
❌ JSON parsing on main thread
❌ Image decoding blocking UI
```

**Your App Specific:**

- Test precipitation animation (map timeline)
- Scroll through 7-day forecast
- Switch between cities rapidly

---

### 🧠 Memory Profiling

**What to Look For:**

- Memory leaks (constantly increasing)
- Large object allocations
- Retained widgets after navigation

**Steps:**

1. DevTools → **Memory** tab
2. Click **Snapshot** before action
3. Perform action (navigate, load data)
4. Click **Snapshot** after
5. Compare snapshots

**Red Flags:**

```
❌ Memory grows from 50MB → 200MB after navigation
❌ Old screens still in memory
❌ Image cache growing unbounded
```

**Your App Specific:**

- Navigate: Home → Map → Home (check for leaks)
- Load 10 different cities (check cache growth)
- Play precipitation animation (check frame allocations)

---

### 📊 Widget Rebuild Profiling

**What to Look For:**

- Widgets rebuilding unnecessarily
- Missing `const` constructors
- ValueNotifier listeners not disposed

**Steps:**

1. DevTools → **Performance** → **More Actions** → **Track Widget Rebuilds**
2. Interact with app
3. Check rebuild count

**Optimization Tips:**

```dart
// ❌ Bad: Rebuilds entire tree
setState(() => _counter++);

// ✅ Good: Only rebuilds specific widget
ValueNotifier<int> counter = ValueNotifier(0);
ValueListenableBuilder<int>(
  valueListenable: counter,
  builder: (context, value, child) => Text('$value'),
)

// ✅ Best: Use const where possible
const SizedBox(height: 20)
```

---

### 🖼️ Rendering Performance

**What to Look For:**

- Frames taking >16ms (60fps) or >8ms (120fps)
- Rasterization issues
- Shader compilation jank

**Steps:**

1. DevTools → **Performance** → **Frame Rendering**
2. Look for red/yellow bars (dropped frames)
3. Click on slow frames to see details

**Common Issues:**

```dart
// ❌ Expensive: Rebuilds gradient every frame
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(...), // Recreated each build
  ),
)

// ✅ Better: Cache gradient
static const _gradient = LinearGradient(...);
Container(
  decoration: BoxDecoration(gradient: _gradient),
)
```

---

## Automated Performance Tests

### Create Performance Test File

```dart
// test/performance/home_screen_performance_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:weather_insights_app/main.dart';

void main() {
  testWidgets('Home screen scrolling performance', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Measure scroll performance
    await tester.fling(
      find.byType(SingleChildScrollView),
      const Offset(0, -500),
      1000,
    );

    // Check for dropped frames
    final binding = tester.binding;
    expect(binding.hasScheduledFrame, isFalse);
  });
}
```

### Run Performance Tests

```bash
flutter test test/performance/
```

---

## Performance Benchmarks (Your App)

### Target Metrics

| Metric        | Target | Current | Status  |
| ------------- | ------ | ------- | ------- |
| App Launch    | <2s    | ?       | ⏳ Test |
| City Search   | <500ms | ?       | ⏳ Test |
| Map Load      | <1s    | ?       | ⏳ Test |
| Animation FPS | 60fps  | ?       | ⏳ Test |
| Memory (Idle) | <100MB | ?       | ⏳ Test |

### How to Measure

```bash
# 1. Launch time
flutter run --profile --trace-startup --profile
# Check: I/flutter (xxxxx): Time to first frame: XXXms

# 2. Build size
flutter build apk --analyze-size
flutter build ios --analyze-size

# 3. FPS during animation
# Use DevTools Performance tab while playing precipitation animation
```

---

## Common Performance Issues in Your App

### 1. Precipitation Map Animation

**Potential Issue:** Loading multiple map tiles rapidly

**Check:**

```dart
// lib/screens/map_screen.dart
// Ensure tiles are cached
TileLayer(
  urlTemplate: '...',
  tileProvider: CancellableNetworkTileProvider(), // ✅ Already using!
)
```

### 2. Weather Icon Loading

**Already Fixed!** ✅

```dart
// lib/widgets/animated_weather_card.dart
CachedNetworkImage(...) // ✅ Using cached images
```

### 3. Forecast Chart Rendering

**Check:**

```dart
// lib/widgets/forecast_chart.dart
// Ensure chart doesn't rebuild unnecessarily
class ForecastChart extends StatelessWidget {
  const ForecastChart({super.key, required this.dailyForecast}); // ✅ const constructor

  @override
  Widget build(BuildContext context) {
    // Consider using RepaintBoundary for expensive charts
    return RepaintBoundary(
      child: LineChart(...),
    );
  }
}
```

---

## DevTools Profiling Session Script

**15-Minute Profiling Session:**

```bash
# 1. Start app in profile mode
flutter run --profile

# 2. Open DevTools (auto-opens in browser)

# 3. CPU Profiling (5 min)
#    - Record → Navigate through all screens → Stop
#    - Look for functions >16ms
#    - Check: build(), paint(), layout()

# 4. Memory Profiling (5 min)
#    - Snapshot → Load 5 cities → Snapshot → Compare
#    - Check: Memory growth, retained objects
#    - Force GC and check if memory returns to baseline

# 5. Frame Rendering (5 min)
#    - Play precipitation animation
#    - Scroll forecast list rapidly
#    - Look for red/yellow bars (dropped frames)

# 6. Export Results
#    - Click "Export" in DevTools
#    - Save timeline.json
#    - Share with team or review later
```

---

## Quick Fixes for Common Issues

### Issue: Dropped Frames During Scroll

```dart
// Add RepaintBoundary around expensive widgets
RepaintBoundary(
  child: WeatherCard(...),
)
```

### Issue: Memory Growing Unbounded

```dart
// Limit cache size
CachedNetworkImage(
  imageUrl: url,
  maxHeightDiskCache: 1000,
  maxWidthDiskCache: 1000,
  memCacheHeight: 200,
  memCacheWidth: 200,
)
```

### Issue: Slow JSON Parsing

```dart
// Move to isolate
import 'dart:isolate';

Future<WeatherModel> parseWeatherInBackground(String json) async {
  return await Isolate.run(() {
    return WeatherModel.fromJson(jsonDecode(json));
  });
}
```

---

## Automated Profiling Script

Create this helper script:

```bash
#!/bin/bash
# scripts/profile.sh

echo "🚀 Starting performance profiling..."

# Clean build
flutter clean
flutter pub get

# Run in profile mode
echo "📱 Launching app in profile mode..."
flutter run --profile --trace-startup &

# Wait for app to start
sleep 10

echo "✅ DevTools should be open in your browser"
echo "📊 Perform these actions:"
echo "   1. Navigate through all screens"
echo "   2. Load multiple cities"
echo "   3. Play precipitation animation"
echo "   4. Scroll forecast lists"
echo ""
echo "⏱️  Record for 2-3 minutes, then export timeline"
```

Make executable:

```bash
chmod +x scripts/profile.sh
./scripts/profile.sh
```

---

## Summary: Your Action Items

1. **Run profiling session** (15 minutes)

   ```bash
   flutter run --profile
   ```

2. **Check these specific areas:**

   - ✅ Map animation (precipitation overlay)
   - ✅ Forecast chart rendering
   - ✅ City search/switching
   - ✅ Memory after 10 city loads

3. **Document findings** in a new file:

   ```
   docs/performance_report.md
   ```

4. **Mark task complete** once you've:
   - Run one profiling session
   - Identified any bottlenecks (or confirmed none exist)
   - Documented results

---

## Expected Results (Your App)

Based on your code review, **you should see:**

✅ **Good Performance:**

- Proper dispose() methods (no memory leaks)
- Cached images (fast loading)
- Cancellable tile provider (smooth maps)
- Efficient state management (ValueNotifier)

⚠️ **Potential Issues to Check:**

- Precipitation animation frame rate
- Memory growth after loading many cities
- Chart rendering performance

**My Prediction:** Your app is already well-optimized! 🎉

DevTools profiling is more about **confirming** good performance than finding major issues.
