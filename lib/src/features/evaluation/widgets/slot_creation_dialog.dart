// lib/src/features/evaluation/widgets/slot_creation_dialog.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:peer42/src/core/services/slot_booking_service.dart';

class SlotCreationDialog extends StatefulWidget {
  @override
  State<SlotCreationDialog> createState() => _SlotCreationDialogState();
}

class _SlotCreationDialogState extends State<SlotCreationDialog> {
  final EvaluationSlotService _slotService = EvaluationSlotService();
  
  DateTime _selectedDate = DateTime.now().add(Duration(hours: 1));
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _initializeDefaultTimes();
  }

  void _initializeDefaultTimes() {
    final now = DateTime.now();
    final roundedTime = _slotService.roundToNearest15Minutes(now.add(Duration(hours: 1)));
    
    _selectedDate = DateTime(roundedTime.year, roundedTime.month, roundedTime.day);
    _startTime = TimeOfDay(hour: roundedTime.hour, minute: roundedTime.minute);
    _endTime = TimeOfDay(
      hour: roundedTime.add(Duration(hours: 1)).hour,
      minute: roundedTime.minute,
    );
  }

  DateTime get _beginDateTime {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );
  }

  DateTime get _endDateTime {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );
  }

  void _validateSlot() {
    setState(() {
      _validationError = _slotService.validateSlotTiming(_beginDateTime, _endDateTime);
    });
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 14)),
      helpText: 'Select evaluation date',
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
        _validateSlot();
      });
    }
  }

  Future<void> _selectStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _startTime,
      helpText: 'Select start time',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    
    if (time != null) {
      // Round to nearest 15 minutes
      final roundedTime = _roundTimeToNearest15Minutes(time);
      setState(() {
        _startTime = roundedTime;
        
        // Auto-adjust end time to be at least 30 minutes later
        final endDateTime = _endDateTime;
        final newStartDateTime = _beginDateTime;
        if (endDateTime.isBefore(newStartDateTime.add(Duration(minutes: 30)))) {
          final newEndTime = newStartDateTime.add(Duration(minutes: 30));
          _endTime = TimeOfDay(hour: newEndTime.hour, minute: newEndTime.minute);
        }
        
        _validateSlot();
      });
    }
  }

  Future<void> _selectEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _endTime,
      helpText: 'Select end time',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    
    if (time != null) {
      // Round to nearest 15 minutes
      final roundedTime = _roundTimeToNearest15Minutes(time);
      setState(() {
        _endTime = roundedTime;
        _validateSlot();
      });
    }
  }

  TimeOfDay _roundTimeToNearest15Minutes(TimeOfDay time) {
    final minutes = time.minute;
    final roundedMinutes = ((minutes / 15).round() * 15) % 60;
    final hourAdjustment = minutes >= 45 && roundedMinutes == 0 ? 1 : 0;
    
    return TimeOfDay(
      hour: (time.hour + hourAdjustment) % 24,
      minute: roundedMinutes,
    );
  }

  void _createSlot() {
    _validateSlot();
    
    if (_validationError == null) {
      Navigator.of(context).pop({
        'beginAt': _beginDateTime,
        'endAt': _endDateTime,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duration = _endDateTime.difference(_beginDateTime);
    
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.schedule, color: theme.primaryColor),
                SizedBox(width: 12),
                Text(
                  'Create Evaluation Slot',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 24),
            
            // Date Selection
            _buildSectionTitle('Date'),
            SizedBox(height: 8),
            _buildDateSelector(),
            
            SizedBox(height: 20),
            
            // Time Selection
            _buildSectionTitle('Time'),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildTimeSelector('Start', _startTime, _selectStartTime)),
                SizedBox(width: 16),
                Expanded(child: _buildTimeSelector('End', _endTime, _selectEndTime)),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Duration Display
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer, color: theme.primaryColor, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Duration: ${duration.inMinutes} minutes',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16),
            
            // Validation Error
            if (_validationError != null) ...[
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _validationError!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],
            
            // Info Box
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Slot Guidelines',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Minimum duration: 30 minutes\n'
                    '• Times are rounded to 15-minute intervals\n'
                    '• Slot must be at least 30 minutes in the future\n'
                    '• Maximum 2 weeks in advance',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _validationError == null ? _createSlot : null,
                  child: Text('Create Slot'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(Icons.calendar_today),
        title: Text(DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate)),
        trailing: Icon(Icons.arrow_drop_down),
        onTap: _selectDate,
      ),
    );
  }

  Widget _buildTimeSelector(String label, TimeOfDay time, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        subtitle: Text(
          time.format(context),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(Icons.access_time),
        onTap: onTap,
      ),
    );
  }
}