import 'package:flutter/material.dart';

import '../../../app/di/app_scope.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/domain/delivery_address.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../shared/widgets/section_header.dart';
import 'delivery_address_form.dart';

/// Set or update where orders are delivered: who receives them, how to reach
/// them, and the address a courier reads. Pops with `true` once saved, so a
/// checkout that sent the member here knows to carry on.
class DeliveryAddressScreen extends StatefulWidget {
  const DeliveryAddressScreen({super.key});

  @override
  State<DeliveryAddressScreen> createState() => _DeliveryAddressScreenState();
}

class _DeliveryAddressScreenState extends State<DeliveryAddressScreen> {
  DeliveryAddressForm? _form;
  bool _isSaving = false;

  DeliveryAddressStore get _store => AppScope.of(context).deliveryAddress;

  /// Opens on what is saved, or on the member's own name; the scope is not
  /// reachable before dependencies are.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _store.load();
    _form ??= DeliveryAddressForm(
      existing: _store.address,
      memberName: AppScope.of(context).member.summary?.name ?? '',
    );
  }

  @override
  void dispose() {
    _form?.dispose();
    super.dispose();
  }

  String get _title => _form!.isNew ? 'Add address' : 'Update address';

  /// The address lands in the store at once and is written through; a write
  /// the server refuses is said here, and the address stays for the session.
  Future<void> _save() async {
    final address = _form!.submit();
    if (address == null || _isSaving) return;
    setState(() => _isSaving = true);
    final navigator = Navigator.of(context);
    final overlay = Overlay.of(context);
    final outcome = await _store.save(address);
    if (!mounted) return;
    outcome.fold(
      (_) => AppToast.success(context, 'Delivery address saved'),
      (error) => AppToast.failureOn(overlay, error),
    );
    setState(() => _isSaving = false);
    if (outcome.isSuccess) navigator.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final form = _form!;

    return AppScaffold(
      child: ListView(
        padding: AppSpacing.pageInset,
        children: [
          ScreenHeader(title: _title),
          const Gap(AppSpacing.md),
          ListenableBuilder(
            listenable: form,
            builder: (context, _) =>
                _AddressFields(form: form, onSave: _save, isSaving: _isSaving),
          ),
        ],
      ),
    );
  }
}

/// The form in two cards, the way a checkout asks: the person first, then
/// the place — province down to the door, the way an address is looked up.
class _AddressFields extends StatelessWidget {
  const _AddressFields({
    required this.form,
    required this.onSave,
    required this.isSaving,
  });

  static const List<AddressField> _contact = [
    AddressField.fullName,
    AddressField.mobile,
    AddressField.email,
  ];

  static const List<AddressField> _place = [
    AddressField.province,
    AddressField.city,
    AddressField.barangay,
    AddressField.postalCode,
    AddressField.street,
    AddressField.purok,
    AddressField.landmark,
  ];

  final DeliveryAddressForm form;
  final VoidCallback onSave;
  final bool isSaving;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SectionHeader(title: 'Contact'),
      const Gap(AppSpacing.sm),
      _FieldCard(form: form, fields: _contact),
      const Gap(AppSpacing.md),
      const SectionHeader(title: 'Address'),
      const Gap(AppSpacing.sm),
      _FieldCard(form: form, fields: _place, onLastSubmitted: onSave),
      const Gap(12),
      Text(
        'The courier calls this number and reads this address — make sure '
        'both are right before you order.',
        style: AppTypography.figtree(
          size: 11.5,
          color: context.palette.textFaint,
        ),
      ),
      const Gap(12),
      AppButton(label: 'Save address', onPressed: onSave, isLoading: isSaving),
    ],
  );
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({
    required this.form,
    required this.fields,
    this.onLastSubmitted,
  });

  final DeliveryAddressForm form;
  final List<AddressField> fields;

  /// Runs when the last field's keyboard action fires — the save, on the
  /// card that ends the form.
  final VoidCallback? onLastSubmitted;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (index, field) in fields.indexed) ...[
          if (index > 0) const Gap(12),
          _Field(
            form: form,
            field: field,
            onSubmitted: index == fields.length - 1 ? onLastSubmitted : null,
          ),
        ],
      ],
    ),
  );
}

/// One field, with the keyboard and icon its content asks for.
class _Field extends StatelessWidget {
  const _Field({required this.form, required this.field, this.onSubmitted});

  final DeliveryAddressForm form;
  final AddressField field;

  /// Set only on the field that ends the form.
  final VoidCallback? onSubmitted;

  static IconData _iconOf(AddressField field) => switch (field) {
    AddressField.fullName => Icons.person_outline_rounded,
    AddressField.mobile => Icons.phone_iphone_rounded,
    AddressField.email => Icons.mail_outline_rounded,
    AddressField.province => Icons.map_outlined,
    AddressField.city => Icons.location_city_rounded,
    AddressField.barangay => Icons.holiday_village_outlined,
    AddressField.postalCode => Icons.markunread_mailbox_outlined,
    AddressField.street => Icons.home_outlined,
    AddressField.purok => Icons.signpost_outlined,
    AddressField.landmark => Icons.push_pin_outlined,
  };

  static TextInputType? _keyboardOf(AddressField field) => switch (field) {
    AddressField.mobile => TextInputType.phone,
    AddressField.email => TextInputType.emailAddress,
    AddressField.postalCode => TextInputType.number,
    _ => null,
  };

  static String _hintOf(AddressField field) => switch (field) {
    AddressField.mobile => '09XX XXX XXXX',
    AddressField.email => 'name@example.com',
    AddressField.postalCode => '4 digits',
    AddressField.purok => 'Optional',
    AddressField.landmark => 'Optional — near the chapel, blue gate',
    _ => field.label,
  };

  void _submit(String _) => onSubmitted!();

  @override
  Widget build(BuildContext context) => AppTextField(
    label: field.label,
    controller: form.controllerOf(field),
    hint: _hintOf(field),
    leadingIcon: _iconOf(field),
    keyboardType: _keyboardOf(field),
    style: AppTextFieldStyle.inset,
    textInputAction: onSubmitted == null
        ? TextInputAction.next
        : TextInputAction.done,
    requiredNote: field.isRequired ? null : 'optional',
    errorText: form.errorOf(field),
    onChanged: (_) => form.onChanged(field),
    onSubmitted: onSubmitted == null ? null : _submit,
  );
}
