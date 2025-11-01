import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_insights_app/main.dart';

void main() {
  testWidgets('Weather app loads with welcome screen', (WidgetTester tester) async {
    // Lance l'app avec un thème par défaut
    await tester.pumpWidget(const MyApp(initialThemeMode: ThemeMode.light));
    
    // Vérifie que le titre de l'app est présent
    expect(find.text('🌤️ Weather Insights'), findsOneWidget);
    
    // Vérifie le message de bienvenue
    expect(find.text('Welcome! Enter a city to get weather insights.'), findsOneWidget);
    
    // Vérifie que le champ de recherche existe
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('Search field accepts input', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(initialThemeMode: ThemeMode.light));
    
    // Trouve le TextField
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);
    
    // Entre du texte
    await tester.enterText(textField, 'Abidjan');
    await tester.pump();
    
    // Vérifie que le texte est entré
    expect(find.text('Abidjan'), findsOneWidget);
    
    // Vérifie que le bouton clear apparaît
    expect(find.byIcon(Icons.clear), findsOneWidget);
  });

  testWidgets('Clear button clears the text field', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(initialThemeMode: ThemeMode.light));
    
    // Entre du texte
    await tester.enterText(find.byType(TextField), 'Paris');
    await tester.pump();
    
    // Appuie sur le bouton clear
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();
    
    // Vérifie que le texte est effacé
    expect(find.text('Paris'), findsNothing);
  });

  testWidgets('Theme switcher toggles between light and dark mode', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(initialThemeMode: ThemeMode.light));
    
    // Vérifie que l'icône dark_mode est présente (mode light actif)
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    
    // Tap sur le bouton de thème
    await tester.tap(find.byIcon(Icons.dark_mode));
    await tester.pumpAndSettle();
    
    // Vérifie que l'icône a changé pour light_mode (mode dark actif)
    expect(find.byIcon(Icons.light_mode), findsOneWidget);
  });
}