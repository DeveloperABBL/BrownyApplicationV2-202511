import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:browny_applications_new/core/data/remote/models/response/working_machine_data.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';

class CustomerServicesWorkingModel {
  final int machineId;
  final String machineImage;
  final ContentLocalizeData name;
  final String remainingTime;
  final String finishTime;

  CustomerServicesWorkingModel({
    required this.machineId,
    required this.machineImage,
    required this.name,
    required this.remainingTime,
    required this.finishTime,
  });

  factory CustomerServicesWorkingModel.fromWorkingMachineResponse(
    WorkingMachineData data, {
    String? locale = 'th',
  }) {
    return CustomerServicesWorkingModel(
      machineId: data.id ?? -1,
      machineImage: data.machineImage.orEmpty,
      name: data.name ?? ContentLocalizeData(),
      remainingTime: data.remainingTime.orEmpty,
      finishTime: data.finishDatatime.orEmpty,
    );
  }

  Duration get remainingTimeDuration {
    if (remainingTime.isEmpty) {
      return Duration.zero;
    }
    // แปลง remainingTime ("00:13:27") เป็น Duration
    final timeParts = remainingTime.split(':');
    if (timeParts.length == 3) {
      return Duration(
        hours: int.parse(timeParts[0]),
        minutes: int.parse(timeParts[1]),
        seconds: int.parse(timeParts[2]),
      );
    } else {
      return Duration.zero;
    }
  }
}
