# LULU Data Visualization Charts

This directory contains chart widgets for visualizing baby growth and sleep data.

## Components

### 1. Growth Curve Chart (`growth_curve_chart.dart`)

Displays WHO standard growth curves with baby's actual growth data.

**Features:**
- Shows 5 WHO percentile lines (p3, p15, p50, p85, p97)
- Plots baby's actual measurements
- Touch interaction to show percentile at any point
- Glassmorphism design with Midnight Blue background
- Champagne Gold (#D4AF6A) for baby data line
- Lavender Mist (#9D8CD6) for p50 baseline

**Usage:**
```dart
import 'package:lulu/presentation/widgets/charts/growth_curve_chart.dart';
import 'package:lulu/data/services/growth_percentile_service.dart';

// Create data points
final growthData = [
  GrowthDataPoint(
    ageInMonths: 0,
    value: 3.5,
    dateTime: DateTime(2024, 1, 1),
  ),
  GrowthDataPoint(
    ageInMonths: 1,
    value: 4.2,
    dateTime: DateTime(2024, 2, 1),
  ),
  // ... more data points
];

// Use in widget tree
GrowthCurveChart(
  babyData: growthData,
  metric: GrowthMetric.weight,
  gender: Gender.male,
  title: '체중 성장 곡선',
  unit: 'kg',
  height: 400,
)
```

### 2. Sleep Heatmap (`sleep_heatmap.dart`)

24-hour heatmap visualization of sleep patterns over 7 or 30 days.

**Features:**
- 24-hour grid (columns = hours 0-23)
- Multiple days view (rows = dates)
- Color gradient based on sleep minutes (0-60)
- Toggle between 7-day and 30-day views
- Click cell to trigger AI analysis callback
- Color legend at bottom
- Glassmorphism design

**Usage:**
```dart
import 'package:lulu/presentation/widgets/charts/sleep_heatmap.dart';

// Create sleep data points
final sleepData = [
  SleepDataPoint(
    date: DateTime(2024, 1, 1),
    hour: 14, // 2 PM
    minutes: 45,
  ),
  SleepDataPoint(
    date: DateTime(2024, 1, 1),
    hour: 20, // 8 PM
    minutes: 60,
  ),
  // ... more data points
];

// Use in widget tree
SleepHeatmap(
  sleepData: sleepData,
  onCellTap: (date, hour) {
    // Trigger AI analysis for this time slot
    print('Analyze sleep at $date, hour $hour');
  },
  height: 500,
)
```

### 3. Growth Percentile Service (`../../data/services/growth_percentile_service.dart`)

Service for calculating growth percentiles and evaluating growth status.

**Features:**
- Calculate percentile from age and measurement
- Get measurement value at specific percentile
- Evaluate growth status (underweight, normal, overweight, etc.)
- Linear interpolation between WHO standard percentiles
- Support for weight, length, and head circumference
- Support for both genders

**Usage:**
```dart
import 'package:lulu/data/services/growth_percentile_service.dart';

final service = GrowthPercentileService();

// Calculate percentile
final percentile = service.calculatePercentile(
  ageInMonths: 6,
  value: 7.5, // kg
  metric: GrowthMetric.weight,
  gender: Gender.male,
);
print('Baby is at $percentile percentile'); // e.g., 45.2

// Get value at specific percentile
final targetWeight = service.getValueAtPercentile(
  ageInMonths: 6,
  percentile: 50,
  metric: GrowthMetric.weight,
  gender: Gender.male,
);
print('p50 weight: $targetWeight kg'); // e.g., 7.9

// Evaluate growth status
final status = service.evaluateGrowthStatus(
  ageInMonths: 6,
  value: 7.5,
  metric: GrowthMetric.weight,
  gender: Gender.male,
);
print(service.getStatusDescription(status)); // "정상"
```

## Design System

All charts follow the LULU Midnight Blue + Glassmorphism design system:

**Colors:**
- Background: Midnight Blue gradient (#1A1B3D -> #0F1029)
- Border: White with 10% opacity
- Text: White with varying opacity
- Baby data: Champagne Gold (#D4AF6A)
- p50 baseline: Lavender Mist (#9D8CD6)
- Sleep data: Lavender Purple (#8B5CF6)

**Effects:**
- Glassmorphism with backdrop blur
- Subtle shadows for depth
- Smooth gradients and transitions
- Touch interactions with visual feedback

## Dependencies

- `fl_chart: ^0.69.0` - For line charts (already in pubspec.yaml)
- WHO growth data from `lib/data/constants/who_growth_data.dart`

## Data Sources

Growth standards are based on WHO Child Growth Standards:
- https://www.who.int/tools/child-growth-standards
- Age range: 0-24 months
- Percentiles: p3, p15, p50, p85, p97
