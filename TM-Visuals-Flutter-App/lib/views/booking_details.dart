/*
import 'package:flutter/material.dart';
import 'package:photography_flutter_application/models/booking_list_model.dart';
import 'package:photography_flutter_application/views/bookings.dart';

class BookingDetailsListScreen extends StatelessWidget {
  final BookingListModel booking;

  const BookingDetailsListScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Booking Details",
          style: TextStyle(color: Colors.orange),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 46, 46, 46),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "<BookingID>  ",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        Text(
                          booking.status,
                          style: TextStyle(
                            color: booking.status == "Approved"
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      color: Color.fromARGB(31, 104, 103, 103),
                      height: 24,
                    ),

                    const Text(
                      'Client:',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      booking.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      "Service:",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.service,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 14),
                    const Text(
                      'Venue Address:',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.venue,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      'Time:',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.time,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Date :',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.date,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Invoices",
                          style: TextStyle(color: Colors.white),
                        ),
                        InkWell(
                          onTap: () {
                            // Your add functionality goes here!
                          },
                          child: const Text(
                            "Add",
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {},
                          child: const Text(
                            textAlign: TextAlign.center,
                            "View",
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Payment Records",
                          style: TextStyle(color: Colors.white),
                        ),
                        InkWell(
                          onTap: () {},
                          child: const Text(
                            textAlign: TextAlign.center,
                            "Add",
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {},
                          child: const Text(
                            "View",
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Content Links",
                          style: TextStyle(color: Colors.white),
                        ),
                        InkWell(
                          onTap: () {},
                          child: const Text(
                            textAlign: TextAlign.center,
                            "Add",
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {},
                          child: const Text(
                            "View",
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    BookingStatusDropdown(initialStatus: booking.status),
                    const SizedBox(height: 16),

                    const Divider(color: Colors.white, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow,
                          ),
                          onPressed: () {},
                          child: const Text(
                            "EDIT",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingsScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "SAVE",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingsScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "CANCEL",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.orange,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 26),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book, size: 26),
            label: "Bookings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month, size: 26),
            label: "Calendar",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 26),
            label: "Profile",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore, size: 26),
            label: "Explore",
          ),
        ],
      ),
    );
  }
}

class BookingStatusDropdown extends StatefulWidget {
  final String initialStatus;

  const BookingStatusDropdown({super.key, required this.initialStatus});

  @override
  State<BookingStatusDropdown> createState() => _BookingStatusDropdownState();
}

class _BookingStatusDropdownState extends State<BookingStatusDropdown> {
  late String selectedStatus;

  final List<String> statuses = ["Pending", "Approved", "Awaiting Deposit"];

  @override
  void initState() {
    super.initState();
    selectedStatus = statuses.contains(widget.initialStatus)
        ? widget.initialStatus
        : statuses.first;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedStatus,
      dropdownColor: const Color.fromARGB(255, 46, 46, 46),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: "Booking Status",
        labelStyle: const TextStyle(color: Colors.orange),
        filled: true,
        fillColor: Colors.black,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.orange),
        ),
      ),
      items: statuses.map((status) {
        return DropdownMenuItem<String>(value: status, child: Text(status));
      }).toList(),
      onChanged: (newStatus) {
        if (newStatus != null) {
          setState(() {
            selectedStatus = newStatus;
          });
        }
      },
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/booking_list_model.dart';
import '../services/Formatters.dart';
import '../viewmodels/bookingList_viewmodel.dart';
import '../services/bookingStatusChip.dart';

class BookingDetailScreen extends StatelessWidget {
  const BookingDetailScreen({super.key, required this.bookingId});
  final String bookingId;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BookingsViewModel>();
    final b = vm.bookingById(bookingId);

    if (b == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('This booking is no longer available.')),
      );
    }

    final theme = Theme.of(context);
    final busy = vm.isBusy(b.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Booking')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  b.displayName,
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              BookingStatusChip(b.status),
            ],
          ),
          if (b.status == BookingStatus.pending) ...[
            const SizedBox(height: 8),
            _HoldBanner(booking: b),
          ],
          const _SectionTitle('Event'),
          _Row(
            Icons.camera_alt_outlined,
            'Service',
            b.serviceName ?? 'Not given',
          ),
          _Row(
            Icons.celebration_outlined,
            'Event type',
            b.eventType.isEmpty ? 'Not given' : b.eventType,
          ),
          _Row(Icons.group_outlined, 'People', '${b.numberOfPeople}'),
          _Row(
            Icons.place_outlined,
            'Location',
            b.location.isEmpty ? 'Not given' : b.location,
          ),
          _Row(Icons.payments_outlined, 'Budget', fmtMoney(b.budget)),
          const _SectionTitle('When'),
          if (b.blocks.isEmpty)
            const Text('No time slots are attached to this booking.'),
          for (final block in b.blocks)
            _Row(
              Icons.event,
              fmtDayLong(block.date),
              '${block.start}–${block.end}  (${_hours(block.minutes)})',
            ),
          const _SectionTitle('Requirements'),
          Text(
            b.requirements.isEmpty
                ? 'The client didn\'t add any.'
                : b.requirements,
          ),
          const _SectionTitle('Client'),
          _Row(
            Icons.mail_outline,
            'Email',
            b.clientEmail ?? 'Not given',
            copy: b.clientEmail,
          ),
          _Row(
            Icons.phone_outlined,
            'Phone',
            b.clientPhone ?? 'Not given',
            copy: b.clientPhone,
          ),
          const _SectionTitle('Request'),
          _Row(Icons.schedule, 'Submitted', fmtDateTime(b.createdAt)),
          _Row(Icons.update, 'Last changed', fmtDateTime(b.updatedAt)),
          _Row(
            Icons.gavel_outlined,
            'Terms',
            b.termsAccepted ? 'Accepted' : 'Not accepted',
          ),
        ],
      ),
      bottomNavigationBar: _ActionBar(booking: b, busy: busy),
    );
  }

  static String _hours(int minutes) {
    final h = minutes ~/ 60, m = minutes % 60;
    if (m == 0) return h == 1 ? '1 hour' : '$h hours';
    return h == 0 ? '$m min' : '${h}h ${m}m';
  }
}

class _HoldBanner extends StatelessWidget {
  const _HoldBanner({required this.booking});
  final BookingList booking;

  @override
  Widget build(BuildContext context) {
    final exp = booking.holdExpiresAt;
    final text = exp == null
        ? 'Waiting for your decision. These slots are held for this client.'
        : exp.isBefore(DateTime.now())
        ? 'The hold on these slots ran out ${timeAgo(exp)}. Confirming works only if nobody else took them.'
        : 'These slots are held until ${fmtDateTime(exp)}.';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFD9A406).withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.hourglass_top, size: 18, color: Color(0xFFD9A406)),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 8),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );
}

class _Row extends StatelessWidget {
  const _Row(this.icon, this.label, this.value, {this.copy});
  final IconData icon;
  final String label;
  final String value;
  final String? copy; // when set, shows a copy button

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(child: Text(value)),
          if (copy != null && copy!.isNotEmpty)
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: copy!));
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text('Copied $label')));
              },
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Icon(
                  Icons.copy,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Actions
// ---------------------------------------------------------------------------

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.booking, required this.busy});
  final BookingList booking;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final b = booking;
    final buttons = <Widget>[];

    if (b.canDecline) {
      buttons.add(
        Expanded(
          child: OutlinedButton(
            onPressed: busy ? null : () => _decline(context, b),
            child: const Text('Decline'),
          ),
        ),
      );
    }
    if (b.canConfirm) {
      buttons.add(
        Expanded(
          child: FilledButton(
            onPressed: busy ? null : () => _confirm(context, b),
            child: busy
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Confirm booking'),
          ),
        ),
      );
    }
    if (b.canCancel) {
      buttons.add(
        Expanded(
          child: OutlinedButton(
            onPressed: busy ? null : () => _cancel(context, b),
            child: const Text('Cancel booking'),
          ),
        ),
      );
    }
    if (b.canComplete) {
      buttons.add(
        Expanded(
          child: FilledButton(
            onPressed: busy ? null : () => _complete(context, b),
            child: const Text('Mark completed'),
          ),
        ),
      );
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            for (var i = 0; i < buttons.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              buttons[i],
            ],
          ],
        ),
      ),
    );
  }

  // ---- each action: ask, run, report ----

  Future<void> _confirm(BuildContext context, BookingList b) async {
    final vm = context.read<BookingsViewModel>();
    final ok = await _ask(
      context,
      title: 'Confirm this booking?',
      body:
          '${b.displayName} will be told that ${fmtBlocks(b.blocks, max: 3)} is confirmed.',
      action: 'Confirm booking',
    );
    if (ok && context.mounted) await _report(context, vm.confirm(b));
  }

  Future<void> _decline(BuildContext context, BookingList b) async {
    final vm = context.read<BookingsViewModel>();
    final reason = await _askReason(
      context,
      title: 'Decline this request?',
      body:
          'The slots open up again and ${b.displayName} is told. You can add a reason.',
      action: 'Decline request',
    );
    if (reason != null && context.mounted)
      await _report(context, vm.decline(b, reason: reason));
  }

  Future<void> _cancel(BuildContext context, BookingList b) async {
    final vm = context.read<BookingsViewModel>();
    final reason = await _askReason(
      context,
      title: 'Cancel this booking?',
      body:
          'The slots open up again and ${b.displayName} is told. You can add a reason.',
      action: 'Cancel booking',
    );
    if (reason != null && context.mounted)
      await _report(context, vm.cancel(b, reason: reason));
  }

  Future<void> _complete(BuildContext context, BookingList b) async {
    final vm = context.read<BookingsViewModel>();
    final ok = await _ask(
      context,
      title: 'Mark as completed?',
      body: 'Use this once the shoot is done.',
      action: 'Mark completed',
    );
    if (ok && context.mounted) await _report(context, vm.complete(b));
  }

  Future<void> _report(
    BuildContext context,
    Future<ActionResult> pending,
  ) async {
    final r = await pending;
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(r.message)));
  }

  Future<bool> _ask(
    BuildContext context, {
    required String title,
    required String body,
    required String action,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Back'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(action),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  /// Returns the typed reason ('' if left empty) or null if the admin backed out.
  Future<String?> _askReason(
    BuildContext context, {
    required String title,
    required String body,
    required String action,
  }) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(body),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              maxLength: 300,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Back'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text(action),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }
}
