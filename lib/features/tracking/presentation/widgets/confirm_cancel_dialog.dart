import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/order_details/order_details_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_strings.dart';
import '../view_model/order_details/order_details_cubit.dart';
import '../view_model/order_details/order_details_events.dart';

class ConfirmCancelDialog extends StatelessWidget {
  final OrderDetailsState state;
  final OrderEntity order;
  const ConfirmCancelDialog({
    super.key,
    required this.state,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppStrings.confirmCancelOrderTitle.tr()),
      content: Text(AppStrings.confirmCancelOrderMessage.tr()),
      actions: [
        TextButton(
          onPressed: state.canselOrderState.isLoading
              ? null
              : () => Navigator.pop(context),
          child: Text(AppStrings.cancel.tr()),
        ),
        TextButton(
          onPressed: state.canselOrderState.isLoading
              ? null
              : () {
                  context.read<OrderDetailsCubit>().doEvent(
                    RevertOrderToPendingEvent(order.id),
                  );
                },
          child: state.canselOrderState.isLoading
              ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(AppStrings.confirm.tr()),
        ),
      ],
    );
  }
}
