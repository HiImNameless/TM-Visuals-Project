import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photography_flutter_application/models/service_list_model.dart';
import 'package:photography_flutter_application/views/service_details.dart';

void main() {
  testWidgets('service details displays persisted service information', (
    tester,
  ) async {
    final service = ServicesListModel(
      id: 'service-1',
      serviceName: 'Wedding photography',
      description: 'Photography for weddings',
      dateTime: '2025-01-02',
      availability: 'Available',
    );

    await tester.pumpWidget(
      MaterialApp(home: ServiceDetailsView(service: service)),
    );

    expect(find.text('Service Details'), findsOneWidget);
    expect(find.text('Wedding photography'), findsOneWidget);
    expect(find.text('Photography for weddings'), findsOneWidget);
    final availabilitySwitch = tester.widget<SwitchListTile>(
      find.byType(SwitchListTile),
    );
    expect(availabilitySwitch.value, isTrue);
    expect(find.byTooltip('Delete service'), findsOneWidget);
  });
}
